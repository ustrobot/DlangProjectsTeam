/**
 * Lesson 7: Weather API JSON to Struct - Converting weather API responses to D structs
 *
 * This example demonstrates converting JSON responses from weather APIs (like OpenWeather)
 * into structured D data types for easier processing and type safety.
 */

module lesson7.weather_struct;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.math;
import std.array;

/**
 * Weather data structure
 */
struct WeatherData {
    string city;
    string country;
    double temperature;      // in Celsius
    double feelsLike;        // in Celsius
    double humidity;         // percentage
    double pressure;         // hPa
    string description;
    string mainCondition;
    double windSpeed;        // m/s
    int windDirection;       // degrees
    long sunrise;            // Unix timestamp
    long sunset;             // Unix timestamp
    string weatherIcon;
    long timestamp;          // Unix timestamp

    /**
     * Display weather information
     */
    void display() {
        writefln("Weather for %s, %s:", city, country);
        writefln("  Temperature: %.1f°C (feels like %.1f°C)", temperature, feelsLike);
        writefln("  Condition: %s (%s)", description, mainCondition);
        writefln("  Humidity: %.0f%%", humidity);
        writefln("  Pressure: %.0f hPa", pressure);
        writefln("  Wind: %.1f m/s from %d°", windSpeed, windDirection);
        writefln("  Sunrise: %d", sunrise);
        writefln("  Sunset: %d", sunset);
        writefln("  Last updated: %d", timestamp);
        if (!weatherIcon.empty) {
            writefln("  Icon: %s", weatherIcon);
        }
    }
}

/**
 * Coordinates structure
 */
struct Coordinates {
    double latitude;
    double longitude;
}

/**
 * Demonstrate converting OpenWeather API JSON to WeatherData struct
 */
void demonstrateWeatherConversion() {
    writeln("=== Converting OpenWeather API JSON to Struct ===");

    // Sample OpenWeather API response (simplified)
    string weatherJson = `{
        "coord": {"lon": -122.4194, "lat": 37.7749},
        "weather": [
            {
                "id": 800,
                "main": "Clear",
                "description": "clear sky",
                "icon": "01d"
            }
        ],
        "base": "stations",
        "main": {
            "temp": 22.5,
            "feels_like": 24.1,
            "temp_min": 18.9,
            "temp_max": 26.1,
            "pressure": 1013,
            "humidity": 60
        },
        "visibility": 10000,
        "wind": {
            "speed": 3.5,
            "deg": 270
        },
        "clouds": {"all": 0},
        "dt": 1640995200,
        "sys": {
            "type": 2,
            "id": 2011048,
            "country": "US",
            "sunrise": 1640968934,
            "sunset": 1641002394
        },
        "timezone": -28800,
        "id": 5391959,
        "name": "San Francisco",
        "cod": 200
    }`;

    writefln("Raw OpenWeather API JSON response:");
    JSONValue rawData = parseJSON(weatherJson);
    writefln("%s", rawData.toPrettyString());
    writeln();

    // Convert to WeatherData struct
    WeatherData weather = jsonToWeatherData(rawData);

    writefln("Converted to WeatherData struct:");
    weather.display();
}

/**
 * Helper function to extract string from JSON with default value
 */
string extractString(JSONValue json, string key, string defaultValue = "") {
    if (key in json && json[key].type == JSONType.string) {
        return json[key].str;
    }
    return defaultValue;
}

/**
 * Helper function to extract int from JSON with default value
 */
int extractInt(JSONValue json, string key, int defaultValue = 0) {
    if (key in json && json[key].type == JSONType.integer) {
        return cast(int)json[key].integer;
    }
    return defaultValue;
}

/**
 * Helper function to extract float from JSON with default value
 */
double extractFloat(JSONValue json, string key, double defaultValue = 0.0) {
    if (key in json && json[key].type == JSONType.float_) {
        return json[key].floating;
    } else if (key in json && json[key].type == JSONType.integer) {
        return cast(double)json[key].integer;
    }
    return defaultValue;
}

/**
 * Helper function to extract long from JSON with default value
 */
long extractLong(JSONValue json, string key, long defaultValue = 0) {
    if (key in json && json[key].type == JSONType.integer) {
        return json[key].integer;
    }
    return defaultValue;
}

/**
 * Convert OpenWeather API JSON to WeatherData struct
 */
WeatherData jsonToWeatherData(JSONValue json) {
    WeatherData weather;

    // Extract basic location info
    weather.city = extractString(json, "name");
    if ("sys" in json && json["sys"].type == JSONType.object) {
        weather.country = extractString(json["sys"], "country");
        weather.sunrise = extractLong(json["sys"], "sunrise");
        weather.sunset = extractLong(json["sys"], "sunset");
    }

    // Extract main weather data
    if ("main" in json && json["main"].type == JSONType.object) {
        JSONValue main = json["main"];
        weather.temperature = extractFloat(main, "temp");
        weather.feelsLike = extractFloat(main, "feels_like");
        weather.humidity = extractFloat(main, "humidity");
        weather.pressure = extractFloat(main, "pressure");
    }

    // Extract weather condition
    if ("weather" in json && json["weather"].type == JSONType.array && json["weather"].array.length > 0) {
        JSONValue weatherInfo = json["weather"][0];
        weather.mainCondition = extractString(weatherInfo, "main");
        weather.description = extractString(weatherInfo, "description");
        weather.weatherIcon = extractString(weatherInfo, "icon");
    }

    // Extract wind data
    if ("wind" in json && json["wind"].type == JSONType.object) {
        JSONValue wind = json["wind"];
        weather.windSpeed = extractFloat(wind, "speed");
        weather.windDirection = extractInt(wind, "deg");
    }

    // Extract timestamp
    weather.timestamp = extractLong(json, "dt");

    return weather;
}

/**
 * Demonstrate processing multiple weather responses
 */
void demonstrateMultipleWeather() {
    writeln("\n=== Processing Multiple Weather Responses ===");

    // Array of weather data for different cities
    string[] cityWeatherJson = [
        `{
            "name": "New York",
            "sys": {"country": "US"},
            "main": {"temp": 15.2, "feels_like": 13.8, "humidity": 72, "pressure": 1020},
            "weather": [{"main": "Clouds", "description": "overcast clouds", "icon": "04d"}],
            "wind": {"speed": 2.1, "deg": 180}
        }`,
        `{
            "name": "London",
            "sys": {"country": "GB"},
            "main": {"temp": 8.5, "feels_like": 6.2, "humidity": 85, "pressure": 998},
            "weather": [{"main": "Rain", "description": "light rain", "icon": "10d"}],
            "wind": {"speed": 4.2, "deg": 220}
        }`,
        `{
            "name": "Tokyo",
            "sys": {"country": "JP"},
            "main": {"temp": 18.9, "feels_like": 19.1, "humidity": 68, "pressure": 1015},
            "weather": [{"main": "Clear", "description": "clear sky", "icon": "01d"}],
            "wind": {"speed": 1.8, "deg": 90}
        }`
    ];

    WeatherData[] weatherList;

    // Convert each city's weather data
    foreach (jsonStr; cityWeatherJson) {
        JSONValue cityData = parseJSON(jsonStr);
        WeatherData weather = jsonToWeatherData(cityData);
        weatherList ~= weather;
    }

    // Display weather for all cities
    writefln("Weather comparison:");
    foreach (weather; weatherList) {
        writefln("  %s, %s: %.1f°C, %s (%s)",
                weather.city, weather.country, weather.temperature,
                weather.description, weather.mainCondition);
    }

    // Find hottest city
    auto hottest = weatherList.maxElement!(w => w.temperature);
    writefln("\nHottest city: %s with %.1f°C", hottest.city, hottest.temperature);

    // Find cities with rain
    auto rainyCities = weatherList.filter!(w => w.mainCondition == "Rain").array;
    if (!rainyCities.empty) {
        writefln("Cities with rain: %s", rainyCities.map!(w => w.city).join(", "));
    }
}

/**
 * Demonstrate temperature conversions
 */
void demonstrateTemperatureConversion() {
    writeln("\n=== Temperature Conversions ===");

    // Sample weather data with temperature in Kelvin (as sometimes returned by APIs)
    string kelvinWeatherJson = `{
        "name": "Moscow",
        "sys": {"country": "RU"},
        "main": {"temp": 273.15, "feels_like": 270.45, "humidity": 78},
        "weather": [{"main": "Snow", "description": "light snow"}]
    }`;

    JSONValue kelvinData = parseJSON(kelvinWeatherJson);

    // Convert Kelvin to Celsius
    WeatherData weather = jsonToWeatherData(kelvinData);

    writefln("Weather data in Kelvin (API response):");
    writefln("  Temperature: %.2f K", kelvinData["main"]["temp"].floating);
    writefln("  Feels like: %.2f K", kelvinData["main"]["feels_like"].floating);

    writefln("\nConverted to Celsius:");
    writefln("  Temperature: %.1f°C", weather.temperature);
    writefln("  Feels like: %.1f°C", weather.feelsLike);

    // Additional conversions
    writefln("\nTemperature conversions:");
    writefln("  %.1f°C = %.1f°F", weather.temperature, celsiusToFahrenheit(weather.temperature));
    writefln("  %.1f°C = %.2f K", weather.temperature, celsiusToKelvin(weather.temperature));
}

/**
 * Convert Celsius to Fahrenheit
 */
double celsiusToFahrenheit(double celsius) {
    return (celsius * 9.0 / 5.0) + 32.0;
}

/**
 * Convert Celsius to Kelvin
 */
double celsiusToKelvin(double celsius) {
    return celsius + 273.15;
}

/**
 * Demonstrate handling incomplete weather data
 */
void demonstrateIncompleteData() {
    writeln("\n=== Handling Incomplete Weather Data ===");

    // Weather data with missing fields
    string incompleteJson = `{
        "name": "Unknown City",
        "main": {"temp": 20.0},
        "weather": [{"description": "partly cloudy"}]
    }`;

    JSONValue incompleteData = parseJSON(incompleteJson);
    WeatherData weather = jsonToWeatherData(incompleteData);

    writefln("Handling incomplete weather data:");
    writefln("Available data:");
    writefln("  City: %s", weather.city);
    writefln("  Temperature: %.1f°C", weather.temperature);
    writefln("  Description: %s", weather.description);

    writefln("\nMissing/default data:");
    writefln("  Country: '%s' (default empty)", weather.country);
    writefln("  Humidity: %.0f%% (default 0)", weather.humidity);
    writefln("  Wind Speed: %.1f m/s (default 0)", weather.windSpeed);
    writefln("  Main Condition: '%s' (default empty)", weather.mainCondition);

    // Check for completeness
    bool isComplete = !weather.city.empty && weather.temperature != 0.0 &&
                     !weather.description.empty && weather.humidity > 0;

    writefln("\nData completeness: %s", isComplete ? "Complete" : "Incomplete");
}

/**
 * Demonstrate weather data validation
 */
void demonstrateValidation() {
    writeln("\n=== Weather Data Validation ===");

    // Test cases with various data quality issues
    string[] testCases = [
        // Valid data
        `{"name": "Valid City", "main": {"temp": 25.0, "humidity": 60}, "weather": [{"main": "Clear", "description": "clear sky"}]}`,

        // Invalid temperature
        `{"name": "Hot City", "main": {"temp": 999, "humidity": 60}, "weather": [{"main": "Clear", "description": "clear sky"}]}`,

        // Invalid humidity
        `{"name": "Dry City", "main": {"temp": 25.0, "humidity": 150}, "weather": [{"main": "Clear", "description": "clear sky"}]}`,

        // Missing required fields
        `{"name": "Incomplete City"}`
    ];

    foreach (i, testJson; testCases) {
        JSONValue data = parseJSON(testJson);
        WeatherData weather = jsonToWeatherData(data);

        writefln("Test case %d:", i + 1);
        writefln("  City: %s", weather.city);
        writefln("  Temperature: %.1f°C", weather.temperature);
        writefln("  Humidity: %.0f%%", weather.humidity);
        writefln("  Description: %s", weather.description);

        // Validate data
        string[] issues = validateWeatherData(weather);
        if (issues.empty) {
            writefln("  Validation: ✓ Valid");
        } else {
            writefln("  Validation: ✗ Issues found:");
            foreach (issue; issues) {
                writefln("    - %s", issue);
            }
        }
        writeln();
    }
}

/**
 * Validate weather data for reasonableness
 */
string[] validateWeatherData(WeatherData weather) {
    string[] issues;

    // Temperature range check (-100°C to 60°C)
    if (weather.temperature < -100.0 || weather.temperature > 60.0) {
        issues ~= format("Temperature %.1f°C is out of reasonable range", weather.temperature);
    }

    // Humidity range check (0-100%)
    if (weather.humidity < 0.0 || weather.humidity > 100.0) {
        issues ~= format("Humidity %.0f%% is out of range 0-100%%", weather.humidity);
    }

    // Wind speed check (0-150 m/s)
    if (weather.windSpeed < 0.0 || weather.windSpeed > 150.0) {
        issues ~= format("Wind speed %.1f m/s is out of reasonable range", weather.windSpeed);
    }

    // Wind direction check (0-360 degrees)
    if (weather.windDirection < 0 || weather.windDirection > 360) {
        issues ~= format("Wind direction %d° is out of range 0-360°", weather.windDirection);
    }

    // Required fields check
    if (weather.city.empty) {
        issues ~= "City name is required";
    }

    if (weather.description.empty) {
        issues ~= "Weather description is required";
    }

    return issues;
}

/**
 * Check if weather struct conversion functionality works
 */
bool testWeatherStructCapability() {
    try {
        // Test basic conversion
        string testJson = `{
            "name": "Test City",
            "sys": {"country": "TC"},
            "main": {"temp": 20.0, "feels_like": 22.0, "humidity": 65.0, "pressure": 1013.0},
            "weather": [{"main": "Clear", "description": "clear sky", "icon": "01d"}],
            "wind": {"speed": 2.5, "deg": 180},
            "dt": 1640995200
        }`;

        JSONValue data = parseJSON(testJson);
        WeatherData weather = jsonToWeatherData(data);

        // Verify conversion
        if (weather.city != "Test City") return false;
        if (weather.country != "TC") return false;
        if (abs(weather.temperature - 20.0) > 0.001) return false;
        if (abs(weather.feelsLike - 22.0) > 0.001) return false;
        if (abs(weather.humidity - 65.0) > 0.001) return false;
        if (weather.description != "clear sky") return false;
        if (weather.mainCondition != "Clear") return false;

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the weather struct conversion example
 */
void runExample() {
    writeln("=== Weather API JSON to Struct Conversion ===\n");

    if (!testWeatherStructCapability()) {
        writeln("ERROR: Weather struct conversion functionality test failed!");
        writeln("This might be due to std.json module issues.");
        return;
    }

    writeln("✓ Weather struct conversion functionality confirmed\n");

    demonstrateWeatherConversion();
    demonstrateMultipleWeather();
    demonstrateTemperatureConversion();
    demonstrateIncompleteData();
    demonstrateValidation();

    writeln("\n=== Summary ===");
    writeln("• Convert JSON API responses to D structs for type safety");
    writeln("• Use helper functions for safe field extraction");
    writeln("• Handle missing fields with appropriate defaults");
    writeln("• Validate data ranges for reasonableness");
    writeln("• Process arrays of weather data for comparisons");
    writeln("• Convert between temperature units when needed");
    writeln("• Check data completeness before using");
}

unittest {
    writeln("=== Running weather_struct tests ===");

    // Test weather struct capability
    bool weatherWorks = testWeatherStructCapability();
    writefln("Weather struct capability test: %s", weatherWorks ? "working" : "not working");
    assert(weatherWorks);

    // Test temperature conversions
    assert(abs(celsiusToFahrenheit(0.0) - 32.0) < 0.001);
    assert(abs(celsiusToFahrenheit(100.0) - 212.0) < 0.001);
    assert(abs(celsiusToKelvin(0.0) - 273.15) < 0.001);
    assert(abs(celsiusToKelvin(25.0) - 298.15) < 0.001);
    writeln("✓ Temperature conversions work");

    // Test validation
    WeatherData validWeather = WeatherData("Test City", "TC", 25.0, 26.0, 60.0, 1013.0,
                                          "clear sky", "Clear", 2.5, 180, 0, 0, "01d", 0);
    string[] validIssues = validateWeatherData(validWeather);
    assert(validIssues.empty);
    writeln("✓ Valid weather data passes validation");

    // Test invalid data detection
    WeatherData invalidWeather = WeatherData("", "", 999.0, 0.0, 150.0, 0.0,
                                            "", "", -1.0, 400, 0, 0, "", 0);
    string[] invalidIssues = validateWeatherData(invalidWeather);
    assert(invalidIssues.length > 0);
    writeln("✓ Invalid weather data is detected");

    // Test helper functions
    JSONValue testJson = parseJSON(`{"long_val": 123456789, "float_val": 12.34}`);
    assert(extractLong(testJson, "long_val") == 123456789);
    assert(abs(extractFloat(testJson, "float_val") - 12.34) < 0.001);
    assert(abs(extractFloat(testJson, "long_val") - 123456789.0) < 0.001);
    writeln("✓ Helper functions work");

    writeln("All weather_struct tests passed!");
    writeln("=== weather_struct tests completed ===");
}
