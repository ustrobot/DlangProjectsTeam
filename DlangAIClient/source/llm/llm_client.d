module llm.llm_client;

import std.json;
import std.net.curl; // simple HTTP client in Phobos
import std.string;
import std.exception;
import std.stdio;
import std.conv;

import llm.chat_context;
import llm.message : MessageRole;

import std.encoding; // transcode
import std.utf; // validate

// Fix UTF-8 text that was mis-decoded as Windows-1252/Latin-1.
//  * It decodes the UTF-8 string into Unicode code points, then re-encodes those code points into Latin‑1 bytes, writing them into a Latin1String buffer.
//  * Practically: each code point in U+0000..U+00FF maps to a single byte with the same value; anything outside that range is not representable and will throw an EncodingException (unless you handle/allow substitution).
//  * In the mojibake fix, this yields a byte-for-byte buffer (0–255) corresponding to the displayed characters, which you then reinterpret as UTF‑8.
string fixUtf8MojibakeFromLatin1(string mojibake)
{
    // 1) Map displayed Unicode code points (U+0000..U+00FF) back to their byte values.
    Latin1String originalLatin1Bytes;
    transcode(mojibake, originalLatin1Bytes);
    // 2) Interpret those bytes as UTF-8 to recover the real text.
    auto fixed = cast(string) originalLatin1Bytes.idup;
    validate(fixed); // optional sanity check
    return fixed;
}
/**
 * Minimal LLM client for chat-like completions.
 * Note: Endpoint and schema tailored for OpenAI-compatible APIs.
 */
/**
 * Represents a model available on the server.
 */
struct ModelInfo
{
    string id;
    string name;
    string description;
    long contextLength;
    string modelType; // e.g., "chat", "embedding", "tts"

    static ModelInfo fromJSON(JSONValue json)
    {
        ModelInfo model;
        model.id = json["id"].str;
        model.name = json["object"].str; // Using object as name for display

        if ("description" in json && json["description"].type != JSONType.null_)
        {
            model.description = json["description"].str;
        }

        if ("context_length" in json)
        {
            model.contextLength = json["context_length"].integer;
        }

        if ("model_type" in json)
        {
            model.modelType = json["model_type"].str;
        }

        return model;
    }
}

// Log Requests Limit Per Day headers only if all three keys are present
const string[] rateLimitRequestKeys = [
    "x-ratelimit-limit-requests",
    "x-ratelimit-remaining-requests",
    "x-ratelimit-reset-requests"
];

// Log Tokens Limit Per Minute headers only if all three keys are present
const string[] rateLimitTokenKeys = [
    "x-ratelimit-limit-tokens",
    "x-ratelimit-remaining-tokens",
    "x-ratelimit-reset-tokens"
];

void logRateLimitHeaders(string[string] headers, const string[] keys, string label)
{
    bool allPresent = true;
    foreach (key; keys)
    {
        if ((key in headers) is null)
        {
            allPresent = false;
            break;
        }
    }
    if (allPresent)
    {
        writefln("%s remaining %s from limit %s will reset in  %s.", label,
            headers[keys[1]],
            headers[keys[0]],
            headers[keys[2]]);
    }
}

class LLMClient
{
    private string _baseUrl;
    private string _model;
    private string _apiKey;
    private ModelInfo[] _currentModelCache; // Cache models for current server only
    private bool _modelsLoaded = false; // Track if models have been loaded for current server

    this(string baseUrl, string model, string apiKey = "")
    {
        _baseUrl = baseUrl.stripRight("/");
        _model = model;
        _apiKey = apiKey;
    }

    @property string model() const
    {
        return _model;
    }

    @property void model(string newModel)
    {
        _model = newModel;
    }

    @property string baseUrl() const
    {
        return _baseUrl;
    }

    @property void baseUrl(string newBaseUrl)
    {
        if (_baseUrl != newBaseUrl)
        {
            // Clear cache when baseUrl changes to avoid using stale cached data
            clearModelCache();
            _baseUrl = newBaseUrl;
        }
    }

    @property string apiKey() const
    {
        return _apiKey;
    }

    @property void apiKey(string newApiKey)
    {
        _apiKey = newApiKey;
    }

    /**
     * Load available models from the server.
     * Returns an array of ModelInfo structs.
     * Results are cached for the current server only to avoid repeated API calls.
     */
    ModelInfo[] getAvailableModels()
    {
        // Check cache first
        if (_modelsLoaded)
        {
            writeln("LLMClient >> Using cached models for server: ", _baseUrl);
            return _currentModelCache;
        }

        if (_apiKey.length == 0)
        {
            writeln("Warning: API key not set, cannot load models");
            return [];
        }

        auto url = _baseUrl ~ "/models";

        try
        {
            auto http = HTTP();
            http.addRequestHeader("Authorization", "Bearer " ~ _apiKey);
            http.addRequestHeader("Content-Type", "application/json");

            writeln("LLMClient >> Loading models from: ", url);
            http.url = url;
            auto response = get(url, http);

            writeln("Models response: ", response);

            auto json = parseJSON(response);
            ModelInfo[] models;

            if (json.type == JSONType.object && "data" in json)
            {
                foreach (modelJson; json["data"].array)
                {
                    try
                    {
                        models ~= ModelInfo.fromJSON(modelJson);
                    }
                    catch (Exception e)
                    {
                        writeln("Warning: Failed to parse model JSON: ", e.msg);
                    }
                }
            }

            // Cache the results
            _currentModelCache = models;
            _modelsLoaded = true;
            writeln("Loaded and cached ", models.length, " models for server: ", _baseUrl);
            return models;
        }
        catch (Exception e)
        {
            writeln("Warning: Failed to load models from server: ", e.msg);
            // Cache empty array to avoid repeated failed requests
            _currentModelCache = [];
            _modelsLoaded = true;
            return [];
        }
    }

    /**
     * Clear the model cache for the current server.
     * Useful when you want to force refresh the model list.
     */
    void clearModelCache()
    {
        _currentModelCache = [];
        _modelsLoaded = false;
        writeln("LLMClient >> Model cache cleared for current server: ", _baseUrl);
    }

    /**
     * Get model IDs for use in supportedModels() replacement.
     * @deprecated Use getAvailableModels() instead for dynamic loading.
     */
    static string[] supportedModels()
    {
        writeln("Warning: supportedModels() is deprecated. Use dynamic model loading instead.");
        return [];
    }

    string chatCompletion(ChatContext ctx)
    {
        enforce(_apiKey.length > 0, "API key is required");

        // Build request JSON
        JSONValue payload;
        payload["model"] = _model;

        JSONValue messagesJson = JSONValue.emptyArray;

        // Add system message if present in ctx
        if (ctx.systemMessage.length > 0)
        {
            JSONValue sysMsg;
            sysMsg["role"] = MessageRole.SYSTEM;
            sysMsg["content"] = ctx.systemMessage;
            messagesJson.array ~= sysMsg;
        }

        foreach (msg; ctx.messages)
        {
            JSONValue m;
            m["role"] = msg.role;
            m["content"] = msg.content;
            messagesJson.array ~= m;
        }
        payload["messages"] = messagesJson;

        auto url = _baseUrl ~ "/chat/completions";

        // Perform request
        auto http = HTTP();
        http.addRequestHeader("Authorization", "Bearer " ~ _apiKey);
        http.addRequestHeader("Content-Type", "application/json");
        http.addRequestHeader("Accept", "application/json");
        http.addRequestHeader("Accept-Charset", "UTF-8");

        writeln("LLMClient >> Requesting: ", url, " with payload: ", payload.toPrettyString);
        auto response = post(url, payload.toString, http);

        writeln("Response: ", response);

        //Log reply headers
        writeln("Response Headers:");
        foreach (key, value; http.responseHeaders)
        {
            writeln(key, ": ", value);
        }

        logRateLimitHeaders(http.responseHeaders, rateLimitRequestKeys, "LLMClient >> Requests Limit Per Day");
        logRateLimitHeaders(http.responseHeaders, rateLimitTokenKeys, "LLMClient >> Tokens Limit Per Minute");

        // Parse response and extract first message
        auto json = parseJSON(response);
        writeln("LLMClient >> Response: ", json.toPrettyString);
        const bool hasChoicesKey = json.type == JSONType.object && ("choices" in json.object) !is null;
        const bool choicesIsArray = hasChoicesKey && json["choices"].type == JSONType.array;
        const bool hasAtLeastOne = choicesIsArray && json["choices"].array.length > 0;
        if (hasChoicesKey && hasAtLeastOne)
        {
            auto first = json["choices"].array[0];
            auto content = first["message"]["content"].str;
            content = fixUtf8MojibakeFromLatin1(content);
            return content;
        }
        return response.dup;
    }
}
