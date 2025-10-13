module llm.server_preset;

import std.file;
import std.path;
import std.json;
import std.stdio;
import std.algorithm;
import std.array;
import std.file : dirEntries, SpanMode, getcwd;

/**
 * Represents a server configuration preset.
 */
struct ServerPreset
{
    string name;
    string description;
    string server;
    string token;

    /**
     * Create a ServerPreset from JSON data.
     */
    static ServerPreset fromJSON(JSONValue json)
    {
        ServerPreset preset;
        preset.name = json["name"].str;
        preset.description = json["description"].str;
        preset.server = json["server"].str;
        preset.token = json["token"].str;
        return preset;
    }

    /**
     * Convert ServerPreset to JSON data.
     */
    JSONValue toJSON()
    {
        JSONValue[string] json;
        json["name"] = name;
        json["description"] = description;
        json["server"] = server;
        json["token"] = token;
        return JSONValue(json);
    }
}

/**
 * Manages server configuration presets stored as .llm-server JSON files.
 */
class ServerPresetManager
{
    private string _presetDir;
    private static const string PRESET_EXTENSION = ".llm-server";
    private static const string PRESETS_DIR = "presets";

    this(string appDir = null)
    {
        if (appDir is null)
        {
            // Default to current working directory if we can't determine executable path
            _presetDir = buildPath(getcwd(), PRESETS_DIR);
        }
        else
        {
            _presetDir = buildPath(appDir, PRESETS_DIR);
        }

        ensurePresetDir();
    }

    /**
     * Ensure the presets directory exists.
     */
    private void ensurePresetDir()
    {
        if (!exists(_presetDir))
        {
            try
            {
                mkdirRecurse(_presetDir);
            }
            catch (Exception e)
            {
                stderr.writeln("Warning: Failed to create presets directory: ", e.msg);
            }
        }
    }

    /**
     * Get all available server presets.
     */
    ServerPreset[] getAllPresets()
    {
        ServerPreset[] presets;

        if (!exists(_presetDir))
        {
            return presets;
        }

        try
        {
            foreach (entry; dirEntries(_presetDir, SpanMode.shallow))
            {
                if (entry.isFile && entry.name.endsWith(PRESET_EXTENSION))
                {
                    try
                    {
                        presets ~= loadPresetFromFile(entry.name);
                    }
                    catch (Exception e)
                    {
                        stderr.writeln("Warning: Failed to load preset file ", entry.name, ": ", e.msg);
                    }
                }
            }
        }
        catch (Exception e)
        {
            stderr.writeln("Warning: Failed to read presets directory: ", e.msg);
        }

        return presets;
    }

    /**
     * Load a specific preset by predicate.
     */
    ServerPreset getPreset(bool delegate(ServerPreset name) predicate)
    {
        // Search through all preset files to find one with matching predicate
        if (!exists(_presetDir))
        {
            throw new Exception("Preset not found by predicate in presets directory ", _presetDir);
        }

        try
        {
            foreach (entry; dirEntries(_presetDir, SpanMode.shallow))
            {
                if (entry.isFile && entry.name.endsWith(PRESET_EXTENSION))
                {
                    try
                    {
                        auto preset = loadPresetFromFile(entry.name);
                        if (predicate(preset))
                        {
                            return preset;
                        }
                    }
                    catch (Exception e)
                    {
                        // Skip invalid preset files
                        stderr.writeln("Warning: Failed to load preset file ", entry.name, ": ", e.msg);
                    }
                }
            }
        }
        catch (Exception e)
        {
            stderr.writeln("Warning: Failed to read presets directory: ", e.msg);
        }

        throw new Exception("Preset not found by predicate in presets directory ", _presetDir);
    }

    /**
     * Save a preset to file.
     */
    void savePreset(ServerPreset preset)
    {
        try
        {
            ensurePresetDir();
            string fileName = buildPath(_presetDir, preset.name ~ PRESET_EXTENSION);
            std.file.write(fileName, preset.toJSON().toPrettyString(JSONOptions.doNotEscapeSlashes));
        }
        catch (Exception e)
        {
            stderr.writeln("Warning: Failed to save preset: ", e.msg);
        }
    }

    /**
     * Delete a preset file.
     */
    void deletePreset(string name)
    {
        string fileName = buildPath(_presetDir, name ~ PRESET_EXTENSION);

        if (exists(fileName))
        {
            try
            {
                remove(fileName);
            }
            catch (Exception e)
            {
                stderr.writeln("Warning: Failed to delete preset: ", e.msg);
            }
        }
    }

    /**
     * Get the presets directory path.
     */
    @property string presetDir() const
    {
        return _presetDir;
    }

    /**
     * Load preset from a specific file path.
     */
    private ServerPreset loadPresetFromFile(string filePath)
    {
        try
        {
            string content = readText(filePath);
            JSONValue jsonData = parseJSON(content);
            return ServerPreset.fromJSON(jsonData);
        }
        catch (Exception e)
        {
            stderr.writeln("Warning: Failed to parse preset file ", filePath, ": ", e.msg);
            throw e;
        }
    }

    /**
     * Get preset names for display purposes.
     */
    string[] getPresetNames()
    {
        return getAllPresets().map!(p => p.name).array;
    }

    /**
     * Check if a preset with the given name exists.
     */
    bool presetExists(string name)
    {
        string fileName = buildPath(_presetDir, name ~ PRESET_EXTENSION);
        return exists(fileName);
    }
}
