module llm.llm_client;

import std.json;
import std.net.curl; // simple HTTP client in Phobos
import std.string;
import std.exception;
import std.stdio;

import llm.chat_context;
import llm.message;

/**
 * Minimal LLM client for chat-like completions.
 * Note: Endpoint and schema tailored for OpenAI-compatible APIs.
 */
/**
 * Canonical model identifiers supported by the client.
 */
public struct ModelIds
{
    enum string allam_2_7b = "allam-2-7b";
    enum string deepseek_r1_distill_llama_70b = "deepseek-r1-distill-llama-70b";
    enum string gemma2_9b_it = "gemma2-9b-it";
    enum string groq_compound = "groq/compound";
    enum string groq_compound_mini = "groq/compound-mini";
    enum string llama_3_1_8b_instant = "llama-3.1-8b-instant";
    enum string llama_3_3_70b_versatile = "llama-3.3-70b-versatile";
    enum string meta_llama_llama_4_maverick_17b_128e_instruct = "meta-llama/llama-4-maverick-17b-128e-instruct";
    enum string meta_llama_llama_4_scout_17b_16e_instruct = "meta-llama/llama-4-scout-17b-16e-instruct";
    enum string meta_llama_llama_guard_4_12b = "meta-llama/llama-guard-4-12b";
    enum string meta_llama_llama_prompt_guard_2_22m = "meta-llama/llama-prompt-guard-2-22m";
    enum string meta_llama_llama_prompt_guard_2_86m = "meta-llama/llama-prompt-guard-2-86m";
    enum string moonshotai_kimi_k2_instruct = "moonshotai/kimi-k2-instruct";
    enum string moonshotai_kimi_k2_instruct_0905 = "moonshotai/kimi-k2-instruct-0905";
    enum string openai_gpt_oss_120b = "openai/gpt-oss-120b";
    enum string openai_gpt_oss_20b = "openai/gpt-oss-20b";
    enum string playai_tts = "playai-tts";
    enum string playai_tts_arabic = "playai-tts-arabic";
    enum string qwen_qwen3_32b = "qwen/qwen3-32b";
    enum string whisper_large_v3 = "whisper-large-v3";
    enum string whisper_large_v3_turbo = "whisper-large-v3-turbo";
}

class LLMClient
{
    private string _baseUrl;
    private string _model;

    this(string baseUrl = "https://api.groq.com/openai/v1/", string model = ModelIds.llama_3_3_70b_versatile)
    {
        _baseUrl = baseUrl.stripRight("/");
        _model = model;
    }

    string chatCompletion(ChatContext ctx)
    {
        enforce(ctx.apiKey.length > 0, "API key is required");

        // Build request JSON
        JSONValue payload;
        payload["model"] = _model;

        JSONValue messagesJson = JSONValue.emptyArray;
        writeln("messagesJson:",messagesJson);
        stdout.flush;
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
        http.addRequestHeader("Authorization", "Bearer " ~ ctx.apiKey);
        http.addRequestHeader("Content-Type", "application/json");
        auto response = post(url, payload.toString, http);

        // Parse response and extract first message
        auto json = parseJSON(response);
        const bool hasChoicesKey = json.type == JSONType.object && ("choices" in json.object) !is null;
        const bool choicesIsArray = hasChoicesKey && json["choices"].type == JSONType.array;
        const bool hasAtLeastOne = choicesIsArray && json["choices"].array.length > 0;
        if (hasChoicesKey && hasAtLeastOne)
        {
            auto first = json["choices"].array[0];
            auto content = first["message"]["content"].str;
            return content;
        }
        return response.dup; 
    }
}


