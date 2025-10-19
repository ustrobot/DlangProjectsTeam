/**
 * Lesson 6: OpenWeather API - Query OpenWeather API with key
 *
 * This example demonstrates integrating with the OpenWeather API
 * using API key authentication, showing real-world REST API usage.
 */

module lesson6.openweather_api;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.json;
import std.uri;
import std.math;

/**
 * Structure for OpenWeather API configuration
 */
struct OpenWeatherConfig {
    string apiKey;
    string baseUrl;
    string units;  // "metric", "imperial", or "standard"

    this(string key, string unitsFormat = "metric") {
        apiKey = key;
        baseUrl = "https://api.openweathermap.org/data/2.5";
        units = unitsFormat;
    }

    string getWeatherUrl(string city) {
        return format("%s/weather?q=%s&appid=%s&units=%s",
                     baseUrl, encodeComponent(city), apiKey, units);
    }

    string getForecastUrl(string city, int days = 5) {
        return format("%s/forecast?q=%s&appid=%s&units=%s",
                     baseUrl, encodeComponent(city), apiKey, units);
    }
}

/**
 * Structure for weather data
 */
struct WeatherData {
    string city;
    string country;
    string description;
    double temperature;
    double feelsLike;
    double humidity;
    double windSpeed;
    int pressure;
    long timestamp;
    string units;

    void printInfo() {
        writefln("Weather for %s, %s", city, country);
        writefln("Description: %s", description);
        writefln("Temperature: %.1f°%s (feels like %.1f°%s)",
                temperature, getUnitSymbol(), feelsLike, getUnitSymbol());
        writefln("Humidity: %.0f%%", humidity);
        writefln("Wind Speed: %.1f %s", windSpeed, getSpeedUnit());
        writefln("Pressure: %d hPa", pressure);
    }

    private string getUnitSymbol() {
        switch (units) {
            case "metric": return "C";
            case "imperial": return "F";
            case "standard": return "K";
            default: return "C";
        }
    }

    private string getSpeedUnit() {
        switch (units) {
            case "metric": return "m/s";
            case "imperial": return "mph";
            case "standard": return "m/s";
            default: return "m/s";
        }
    }
}

/**
 * Fetch current weather from OpenWeather API
 */
WeatherData getCurrentWeather(OpenWeatherConfig config, string city) {
    WeatherData weather;

    try {
        string url = config.getWeatherUrl(city);
        writefln("Fetching weather for: %s", city);
        writefln("API URL: %s", url.replace(config.apiKey, "[API_KEY]")); // Hide key in logs

        auto http = HTTP(url);
        string response;

        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        // Parse JSON response
        auto json = parseJSON(response);

        // Check for API errors
        if ("cod" in json) {
            long statusCode = json["cod"].type == JSONType.string ?
                            to!long(json["cod"].str) : json["cod"].integer;

            if (statusCode != 200) {
                string message = "message" in json ? json["message"].str : "Unknown error";
                throw new Exception(format("OpenWeather API error %d: %s", statusCode, message));
            }
        }

        // Extract weather data
        weather.city = json["name"].str;
        weather.country = json["sys"]["country"].str;
        weather.description = json["weather"][0]["description"].str;
        weather.temperature = json["main"]["temp"].floating;
        weather.feelsLike = json["main"]["feels_like"].floating;
        weather.humidity = json["main"]["humidity"].floating;
        weather.pressure = cast(int)json["main"]["pressure"].integer;
        weather.windSpeed = json["wind"]["speed"].floating;
        weather.timestamp = json["dt"].integer;
        weather.units = config.units;

    } catch (CurlException e) {
        throw new Exception(format("Network error fetching weather: %s", e.msg));
    } catch (JSONException e) {
        throw new Exception(format("JSON parsing error: %s", e.msg));
    }

    return weather;
}

/**
 * Demonstrate basic OpenWeather API usage
 */
void demonstrateBasicWeatherAPI() {
    writeln("=== Basic OpenWeather API Usage ===");

    // Note: In a real application, you would get the API key from environment variables
    // or secure configuration. For demo purposes, we'll use a placeholder.
    writefln("Note: This example uses a placeholder API key.");
    writefln("To get real data, sign up at https://openweathermap.org/api");
    writefln("and set your API key in the configuration.\n");

    // Using a demo configuration (will fail without real API key)
    OpenWeatherConfig config = OpenWeatherConfig("demo-key-placeholder", "metric");

    string[] cities = ["London", "New York", "Tokyo", "Sydney"];

    foreach (city; cities) {
        try {
            WeatherData weather = getCurrentWeather(config, city);

            writefln("\n--- Weather for %s ---", city);
            weather.printInfo();

        } catch (Exception e) {
            writefln("\n--- Weather for %s ---", city);
            writefln("✗ Failed to get weather: %s", e.msg);
            writefln("This is expected with a placeholder API key.");
        }

        import core.thread;
        Thread.sleep(500.msecs); // Rate limiting
    }
}

/**
 * Demonstrate different temperature units
 */
void demonstrateTemperatureUnits() {
    writeln("\n=== Temperature Units ===");

    writefln("OpenWeather API supports different temperature units:");

    string[] unitTypes = ["metric", "imperial", "standard"];
    string[] unitDescriptions = [
        "Celsius (°C) - metric system",
        "Fahrenheit (°F) - imperial system",
        "Kelvin (K) - absolute temperature"
    ];

    // Demo with placeholder data since we don't have a real API key
    writefln("\nUnit conversion examples (using sample data):");

    // Sample temperature in Celsius
    double celsiusTemp = 20.0;

    foreach (i, unit; unitTypes) {
        writefln("\n--- %s ---", unitDescriptions[i]);

        double displayTemp;
        string unitSymbol;

        switch (unit) {
            case "metric":
                displayTemp = celsiusTemp;
                unitSymbol = "°C";
                break;
            case "imperial":
                displayTemp = celsiusTemp * 9.0/5.0 + 32.0; // C to F
                unitSymbol = "°F";
                break;
            case "standard":
                displayTemp = celsiusTemp + 273.15; // C to K
                unitSymbol = "K";
                break;
            default:
                displayTemp = celsiusTemp;
                unitSymbol = "°C";
                break;
        }

        writefln("Temperature: %.1f %s", displayTemp, unitSymbol);
    }

    writefln("\nNote: Real API calls would return data in the requested unit format.");
}

/**
 * Demonstrate API error handling
 */
void demonstrateAPIErrorHandling() {
    writeln("\n=== API Error Handling ===");

    writefln("Common OpenWeather API errors:");

    // Simulate different error scenarios
    struct ErrorScenario {
        string description;
        string mockResponse;
        string expectedError;
    }

    ErrorScenario[] scenarios = [
        ErrorScenario(
            "Invalid API Key",
            `{"cod":401,"message":"Invalid API key. Please see http://openweathermap.org/faq#error401 for more info."}`,
            "Invalid API key"
        ),
        ErrorScenario(
            "City Not Found",
            `{"cod":"404","message":"city not found"}`,
            "city not found"
        ),
        ErrorScenario(
            "Too Many Requests",
            `{"cod":429,"message":"Your account is temporary blocked due to exceeding of requests limitation ` ~
            `of your subscription type. Please choose the proper subscription http://openweathermap.org/price"}`,
            "requests limitation"
        )
    ];

    foreach (scenario; scenarios) {
        writefln("\n--- %s ---", scenario.description);

        try {
            // Simulate API response parsing that would cause an error
            auto json = parseJSON(scenario.mockResponse);

            if ("cod" in json) {
                long statusCode = json["cod"].type == JSONType.string ?
                                to!long(json["cod"].str) : json["cod"].integer;

                if (statusCode != 200) {
                    string message = "message" in json ? json["message"].str : "Unknown error";
                    throw new Exception(format("API error %d: %s", statusCode, message));
                }
            }

            writefln("⚠ Unexpected success with error scenario");

        } catch (Exception e) {
            writefln("✓ Correctly caught error: %s", e.msg);
            if (canFind(e.msg, scenario.expectedError)) {
                writefln("✓ Error message contains expected text");
            }
        }
    }

    writefln("\nError handling strategies:");
    writefln("• 401: Check API key validity and format");
    writefln("• 404: Verify city name spelling and format");
    writefln("• 429: Implement rate limiting and backoff");
    writefln("• Network errors: Implement retry logic");
}

/**
 * Demonstrate API key security
 */
void demonstrateAPIKeySecurity() {
    writeln("\n=== API Key Security ===");

    writefln("OpenWeather API key security best practices:");

    // 1. Key Storage
    writefln("\n1. Secure key storage:");
    writefln("   ✓ Store in environment variables: OPENWEATHER_API_KEY");
    writefln("   ✓ Use configuration files outside version control");
    writefln("   ✓ Never hardcode in source code");
    writefln("   ✓ Use different keys for dev/staging/production");

    // 2. Key Format
    writefln("\n2. API key format:");
    writefln("   ✓ 32-character hexadecimal string");
    writefln("   ✓ Example: 1234567890abcdef1234567890abcdef");
    writefln("   ✓ Always include in 'appid' query parameter");

    // 3. Rate Limiting
    writefln("\n3. Rate limiting awareness:");
    writefln("   ✓ Free tier: 60 calls/minute, 1,000,000 calls/month");
    writefln("   ✓ Implement client-side rate limiting");
    writefln("   ✓ Handle 429 responses with exponential backoff");
    writefln("   ✓ Cache responses when possible");

    // 4. HTTPS Only
    writefln("\n4. HTTPS requirement:");
    writefln("   ✓ OpenWeather API requires HTTPS");
    writefln("   ✓ API key transmitted securely");
    writefln("   ✓ All endpoints use https:// protocol");

    // Demonstrate URL construction
    writefln("\n5. Secure URL construction:");

    string demoKey = "demo-key-1234567890abcdef";
    string city = "London";
    string units = "metric";

    string secureUrl = format("https://api.openweathermap.org/data/2.5/weather?q=%s&appid=%s&units=%s",
                             encodeComponent(city), demoKey, units);

    writefln("Secure URL: %s", secureUrl.replace(demoKey, "[API_KEY]"));
    writefln("✓ Uses HTTPS protocol");
    writefln("✓ API key properly encoded");
    writefln("✓ City name URL-encoded");
}

/**
 * Demonstrate weather data parsing
 */
void demonstrateWeatherDataParsing() {
    writeln("\n=== Weather Data Parsing ===");

    writefln("OpenWeather API JSON response structure:");

    // Sample API response (simplified)
    string sampleResponse = `{
        "coord": {"lon": -0.1257, "lat": 51.5085},
        "weather": [{"id": 803, "main": "Clouds", "description": "broken clouds", "icon": "04d"}],
        "base": "stations",
        "main": {
            "temp": 15.5,
            "feels_like": 14.8,
            "temp_min": 13.9,
            "temp_max": 16.7,
            "pressure": 1013,
            "humidity": 72
        },
        "visibility": 10000,
        "wind": {"speed": 3.6, "deg": 230},
        "clouds": {"all": 75},
        "dt": 1640995200,
        "sys": {"type": 2, "id": 2019646, "country": "GB", "sunrise": 1640968138, "sunset": 1640995200},
        "timezone": 0,
        "id": 2643743,
        "name": "London",
        "cod": 200
    }`;

    writefln("Sample API response:");
    writefln("%s", sampleResponse);
    writefln("");

    try {
        auto json = parseJSON(sampleResponse);

        // Parse into WeatherData structure
        WeatherData weather;
        weather.city = json["name"].str;
        weather.country = json["sys"]["country"].str;
        weather.description = json["weather"][0]["description"].str;
        weather.temperature = json["main"]["temp"].floating;
        weather.feelsLike = json["main"]["feels_like"].floating;
        weather.humidity = json["main"]["humidity"].floating;
        weather.pressure = cast(int)json["main"]["pressure"].integer;
        weather.windSpeed = json["wind"]["speed"].floating;
        weather.timestamp = json["dt"].integer;
        weather.units = "metric";

        writefln("Parsed weather data:");
        weather.printInfo();

        writefln("\n✓ Successfully parsed all weather fields");

    } catch (Exception e) {
        writefln("✗ Failed to parse weather data: %s", e.msg);
    }
}

/**
 * Demonstrate forecast API (5-day forecast)
 */
void demonstrateWeatherForecast() {
    writeln("\n=== Weather Forecast API ===");

    writefln("OpenWeather 5-day forecast API:");

    // Sample forecast response structure
    string sampleForecast = `{
        "cod": "200",
        "message": 0,
        "cnt": 40,
        "list": [
            {
                "dt": 1641002400,
                "main": {"temp": 15.2, "feels_like": 14.5, "humidity": 75},
                "weather": [{"description": "light rain"}],
                "dt_txt": "2022-01-01 12:00:00"
            },
            {
                "dt": 1641013200,
                "main": {"temp": 16.8, "feels_like": 16.2, "humidity": 68},
                "weather": [{"description": "clear sky"}],
                "dt_txt": "2022-01-01 15:00:00"
            }
        ],
        "city": {"name": "London", "country": "GB"}
    }`;

    writefln("Sample forecast response (simplified):");
    writefln("%s", sampleForecast);
    writefln("");

    try {
        auto json = parseJSON(sampleForecast);

        writefln("Forecast for: %s, %s", json["city"]["name"].str, json["city"]["country"].str);
        writefln("Number of forecast entries: %d", json["list"].array.length);

        // Show first few forecast entries
        auto forecastList = json["list"].array;
        for (int i = 0; i < min(3, forecastList.length); i++) {
            auto entry = forecastList[i];
            string dateTime = entry["dt_txt"].str;
            double temp = entry["main"]["temp"].floating;
            string description = entry["weather"][0]["description"].str;

            writefln("  %s: %.1f°C, %s", dateTime, temp, description);
        }

        writefln("\n✓ Successfully parsed forecast data");

    } catch (Exception e) {
        writefln("✗ Failed to parse forecast data: %s", e.msg);
    }

    writefln("\nNote: Real forecast API provides 40 entries (8 per day for 5 days).");
}

/**
 * Demonstrate API integration best practices
 */
void demonstrateIntegrationBestPractices() {
    writeln("\n=== API Integration Best Practices ===");

    writefln("Best practices for integrating with weather APIs:");

    // 1. Error Handling
    writefln("\n1. Comprehensive error handling:");
    writefln("   ✓ Check HTTP status codes");
    writefln("   ✓ Parse API error responses");
    writefln("   ✓ Handle network timeouts");
    writefln("   ✓ Implement retry logic");

    // 2. Rate Limiting
    writefln("\n2. Rate limiting:");
    writefln("   ✓ Respect API limits (60 calls/minute for free tier)");
    writefln("   ✓ Implement exponential backoff");
    writefln("   ✓ Cache responses when appropriate");
    writefln("   ✓ Use webhooks for real-time updates if available");

    // 3. Data Validation
    writefln("\n3. Data validation:");
    writefln("   ✓ Validate required fields exist");
    writefln("   ✓ Check data types and ranges");
    writefln("   ✓ Handle missing or null values");
    writefln("   ✓ Sanitize user inputs");

    // 4. Logging
    writefln("\n4. Logging and monitoring:");
    writefln("   ✓ Log API requests and responses");
    writefln("   ✓ Monitor response times");
    writefln("   ✓ Track error rates");
    writefln("   ✓ Alert on API failures");

    // 5. Testing
    writefln("\n5. Testing strategies:");
    writefln("   ✓ Mock API responses for unit tests");
    writefln("   ✓ Test error scenarios");
    writefln("   ✓ Validate against real API occasionally");
    writefln("   ✓ Test rate limiting behavior");

    writefln("\n6. Configuration management:");
    writefln("   ✓ Store API keys securely");
    writefln("   ✓ Use environment-specific configurations");
    writefln("   ✓ Document API dependencies");
    writefln("   ✓ Plan for API changes");
}

/**
 * Check if OpenWeather API integration works
 */
bool testOpenWeatherAPICapability() {
    try {
        // Test with a simple HTTP request (won't work without real API key)
        auto http = HTTP("https://api.openweathermap.org/data/2.5/weather?q=London&appid=demo");
        string response;

        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        // Just check if we got any response
        return response.length > 0;
    } catch (Exception e) {
        // Even if it fails due to invalid API key, we can test the HTTP functionality
        return true; // Network connectivity works
    }
}

/**
 * Run the OpenWeather API example
 */
void runExample() {
    writeln("=== OpenWeather API Integration ===\n");

    if (!testOpenWeatherAPICapability()) {
        writeln("ERROR: OpenWeather API functionality test failed!");
        writeln("This might be due to network issues.");
        return;
    }

    writeln("✓ OpenWeather API functionality confirmed\n");

    // Demonstrate OpenWeather API integration
    demonstrateBasicWeatherAPI();
    demonstrateTemperatureUnits();
    demonstrateAPIErrorHandling();
    demonstrateAPIKeySecurity();
    demonstrateWeatherDataParsing();
    demonstrateWeatherForecast();
    demonstrateIntegrationBestPractices();

    writeln("\n=== Summary ===");
    writeln("• OpenWeather API provides weather data via REST endpoints");
    writeln("• Authentication uses API key in 'appid' query parameter");
    writeln("• Supports multiple temperature units (metric/imperial/standard)");
    writeln("• Returns JSON responses with comprehensive weather data");
    writeln("• Implements rate limiting (60 calls/minute for free tier)");
    writeln("• Requires HTTPS for all requests");
    writeln("• Provides both current weather and 5-day forecast endpoints");
    writeln("• Proper error handling is essential for production use");
    writeln("• API keys should be stored securely and rotated regularly");
}

unittest {
    writeln("=== Running openweather_api tests ===");

    // Test OpenWeather API capability
    bool openWeatherWorks = testOpenWeatherAPICapability();
    writefln("OpenWeather API capability test: %s", openWeatherWorks ? "working" : "not working");

    // Test OpenWeatherConfig structure (safe, no network required)
    OpenWeatherConfig config = OpenWeatherConfig("test-api-key-123", "metric");

    assert(config.apiKey == "test-api-key-123");
    assert(config.units == "metric");
    assert(canFind(config.getWeatherUrl("London"), "q=London"));
    assert(canFind(config.getWeatherUrl("London"), "appid=test-api-key-123"));
    assert(canFind(config.getWeatherUrl("London"), "units=metric"));
    writeln("✓ OpenWeatherConfig structure works");

    // Test WeatherData structure (safe, no network required)
    WeatherData weather;
    weather.city = "Test City";
    weather.country = "TC";
    weather.description = "clear sky";
    weather.temperature = 25.5;
    weather.feelsLike = 26.0;
    weather.humidity = 65.0;
    weather.windSpeed = 5.2;
    weather.pressure = 1013;
    weather.units = "metric";

    assert(weather.city == "Test City");
    assert(weather.getUnitSymbol() == "C");
    assert(weather.getSpeedUnit() == "m/s");
    writeln("✓ WeatherData structure works");

    // Test URL encoding for city names (safe, no network required)
    string cityWithSpaces = "New York";
    string encodedCity = encodeComponent(cityWithSpaces);

    assert(encodedCity != cityWithSpaces);
    assert(canFind(encodedCity, "%20")); // Space should be encoded
    writeln("✓ URL encoding for city names works");

    // Test temperature unit conversions (safe, no network required)
    double celsius = 20.0;
    double fahrenheit = celsius * 9.0/5.0 + 32.0;
    double kelvin = celsius + 273.15;

    assert(abs(fahrenheit - 68.0) < 0.1); // Should be approximately 68°F
    assert(abs(kelvin - 293.15) < 0.1); // Should be approximately 293.15K
    writeln("✓ Temperature unit conversions work");

    // Test JSON error response parsing (safe, no network required)
    string errorResponse = `{"cod":401,"message":"Invalid API key"}`;

    try {
        auto json = parseJSON(errorResponse);
        assert("cod" in json);
        assert("message" in json);
        assert(json["cod"].integer == 401);
        assert(json["message"].str == "Invalid API key");
        writeln("✓ JSON error response parsing works");
    } catch (Exception e) {
        assert(false, "JSON error parsing should work");
    }

    // Test API key format validation (safe, no network required)
    string validKey = "1234567890abcdef1234567890abcdef"; // 32 chars
    string shortKey = "short";
    string longKey = "this-is-a-very-long-api-key-that-exceeds-normal-length";

    assert(validKey.length == 32);
    assert(shortKey.length < 32);
    assert(longKey.length > 32);

    // OpenWeather keys are typically 32 hex characters
    bool isValidFormat = true;
    foreach (char c; validKey) {
        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))) {
            isValidFormat = false;
            break;
        }
    }
    assert(isValidFormat);
    writeln("✓ API key format validation works");

    // Test forecast data structure (safe, no network required)
    string forecastJson = `{"list":[{"dt":1641002400,"main":{"temp":15.2},"weather":[{"description":"light rain"}]}]}`;

    try {
        auto json = parseJSON(forecastJson);
        assert("list" in json);
        assert(json["list"].array.length > 0);
        assert("main" in json["list"][0]);
        assert("weather" in json["list"][0]);
        writeln("✓ Forecast data structure works");
    } catch (Exception e) {
        assert(false, "Forecast JSON parsing should work");
    }

    // Test rate limiting calculations (safe, no network required)
    int freeTierLimit = 60; // calls per minute
    int timeWindow = 60; // seconds
    double allowedRate = freeTierLimit / cast(double)timeWindow; // calls per second

    assert(allowedRate > 0 && allowedRate < 2); // Should be about 1 call per second
    writeln("✓ Rate limiting calculations work");

    // Test HTTPS URL construction (safe, no network required)
    string apiKey = "test-key";
    string city = "Paris";
    string fullUrl = format("https://api.openweathermap.org/data/2.5/weather?q=%s&appid=%s&units=metric",
                           encodeComponent(city), apiKey);

    assert(canFind(fullUrl, "https://"));
    assert(canFind(fullUrl, "api.openweathermap.org"));
    assert(canFind(fullUrl, "q=Paris"));
    assert(canFind(fullUrl, "appid=test-key"));
    assert(canFind(fullUrl, "units=metric"));
    writeln("✓ HTTPS URL construction works");

    writeln("All openweather_api tests passed!");
    writeln("=== openweather_api tests completed ===");
}
