/**
 * Lesson 1: DNS Lookup and Resolution
 *
 * This example demonstrates how DNS (Domain Name System) works to resolve
 * human-readable domain names to IP addresses that computers can use.
 */

module lesson1.dns_lookup;

import std.stdio;
import std.string;
import std.socket;
import std.conv;
import std.algorithm;

/**
 * Represents a DNS record with various types
 */
enum RecordType {
    A,      // IPv4 address
    AAAA,   // IPv6 address
    CNAME,  // Canonical name (alias)
    MX,     // Mail exchange
    NS,     // Name server
    TXT     // Text record
}

/**
 * Represents a DNS record
 */
struct DNSRecord {
    string name;
    RecordType type;
    string value;
    int ttl; // Time to live in seconds

    /**
     * Create a string representation of the DNS record
     */
    string toString() const {
        string typeStr;
        switch (type) {
            case RecordType.A: typeStr = "A"; break;
            case RecordType.AAAA: typeStr = "AAAA"; break;
            case RecordType.CNAME: typeStr = "CNAME"; break;
            case RecordType.MX: typeStr = "MX"; break;
            case RecordType.NS: typeStr = "NS"; break;
            case RecordType.TXT: typeStr = "TXT"; break;
            default: typeStr = "UNKNOWN"; break;
        }

        return format("%s %s %s (TTL: %d)", name, typeStr, value, ttl);
    }
}

/**
 * Simple DNS resolver class (simulates DNS resolution)
 */
class DNSResolver {
private:
    // Mock DNS records for demonstration
    DNSRecord[string] mockRecords;

    void initializeMockRecords() {
        // Mock records for example.com
        mockRecords["example.com A"] = DNSRecord("example.com", RecordType.A, "93.184.216.34", 3600);
        mockRecords["www.example.com CNAME"] = DNSRecord("www.example.com", RecordType.CNAME, "example.com", 3600);
        mockRecords["mail.example.com MX"] = DNSRecord("mail.example.com", RecordType.MX, "mailserver.example.com", 3600);
        mockRecords["example.com NS"] = DNSRecord("example.com", RecordType.NS, "ns1.example.com", 3600);
        mockRecords["example.com TXT"] = DNSRecord("example.com", RecordType.TXT, "\"v=spf1 -all\"", 3600);

        // Mock records for google.com
        mockRecords["google.com A"] = DNSRecord("google.com", RecordType.A, "142.250.184.78", 300);
        mockRecords["www.google.com CNAME"] = DNSRecord("www.google.com", RecordType.CNAME, "google.com", 300);

        // Mock records for localhost
        mockRecords["localhost A"] = DNSRecord("localhost", RecordType.A, "127.0.0.1", 0);
    }

public:
    /**
     * Constructor
     */
    this() {
        initializeMockRecords();
    }

    /**
     * Resolve a domain name to an IP address (A record)
     */
    string resolveA(string domain) {
        string key = domain ~ " A";
        if (key in mockRecords) {
            return mockRecords[key].value;
        }

        // For demonstration, if we don't have a mock record,
        // try to resolve using actual DNS (if network is available)
        try {
            auto addresses = getAddress(domain, 80); // Port doesn't matter for resolution
            if (addresses.length > 0) {
                return addresses[0].toAddrString();
            }
        } catch (Exception e) {
            // Fall back to mock resolution
        }

        return "NXDOMAIN"; // Domain not found
    }

    /**
     * Resolve a CNAME record
     */
    string resolveCNAME(string domain) {
        string key = domain ~ " CNAME";
        if (key in mockRecords) {
            return mockRecords[key].value;
        }
        return null;
    }

    /**
     * Get all records for a domain
     */
    DNSRecord[] getAllRecords(string domain) {
        DNSRecord[] results;

        foreach (key, record; mockRecords) {
            if (record.name == domain) {
                results ~= record;
            }
        }

        return results;
    }

    /**
     * Simulate the DNS resolution process
     */
    string[] simulateResolution(string domain) {
        string[] steps;
        steps ~= format("Resolving domain: %s", domain);

        // Step 1: Check if it's already an IP address
        if (isIPAddress(domain)) {
            steps ~= format("'%s' is already an IP address", domain);
            return steps;
        }

        // Step 2: Check local hosts file (simulated)
        steps ~= "Checking local hosts file... (not found)";

        // Step 3: Check local DNS cache (simulated)
        steps ~= "Checking local DNS cache... (not found)";

        // Step 4: Query DNS resolver
        steps ~= "Querying DNS resolver...";

        string ip = resolveA(domain);
        if (ip != "NXDOMAIN") {
            steps ~= format("DNS resolution successful: %s -> %s", domain, ip);
        } else {
            steps ~= format("DNS resolution failed: %s not found", domain);
        }

        return steps;
    }

    /**
     * Get DNS records for common domains
     */
    void displayCommonRecords() {
        string[] domains = ["example.com", "google.com", "localhost"];

        writeln("=== Common DNS Records ===");

        foreach (domain; domains) {
            writeln(format("\nRecords for %s:", domain));
            auto records = getAllRecords(domain);
            if (records.length == 0) {
                writeln("  No records found");
            } else {
                foreach (record; records) {
                    writeln(format("  %s", record.toString()));
                }
            }
        }
    }
}

/**
 * Check if a string is a valid IP address
 */
bool isIPAddress(string str) {
    try {
        // Try to parse as IPv4
        auto parts = str.split(".");
        if (parts.length == 4) {
            foreach (part; parts) {
                int num = to!int(part);
                if (num < 0 || num > 255) return false;
            }
            return true;
        }

        // Could add IPv6 validation here if needed
        return false;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Demonstrate DNS concepts and resolution
 */
void demonstrateDNS() {
    auto resolver = new DNSResolver();

    writeln("=== DNS (Domain Name System) Demonstration ===\n");

    // Show common DNS records
    resolver.displayCommonRecords();

    writeln("\n==================================================\n");

    // Demonstrate resolution process
    string[] testDomains = ["example.com", "www.example.com", "google.com", "nonexistent.domain"];

    foreach (domain; testDomains) {
        writeln(format("--- Resolving: %s ---", domain));
        auto steps = resolver.simulateResolution(domain);
        foreach (step; steps) {
            writeln("  " ~ step);
        }
        writeln();
    }

    // Demonstrate CNAME resolution
    writeln("=== CNAME Resolution Example ===");
    string cnameResult = resolver.resolveCNAME("www.example.com");
    if (cnameResult) {
        writeln("www.example.com -> " ~ cnameResult);
        string finalIP = resolver.resolveA(cnameResult);
        writeln(cnameResult ~ " -> " ~ finalIP);
    }

    writeln("\n=== DNS Concepts ===");
    writeln("• DNS translates domain names to IP addresses");
    writeln("• DNS uses a hierarchical structure (.com, .org, etc.)");
    writeln("• DNS records have different types (A, CNAME, MX, etc.)");
    writeln("• DNS resolution is usually cached for performance");
    writeln("• DNS uses UDP port 53 by default");
}

/**
 * Run the example
 */
void runExample() {
    demonstrateDNS();
}

unittest {
    writeln("=== Running dns_lookup tests ===");

    // Test DNS Resolver
    auto resolver = new DNSResolver();

    // Test IP address validation
    assert(isIPAddress("192.168.1.1") == true);
    assert(isIPAddress("127.0.0.1") == true);
    assert(isIPAddress("256.1.1.1") == false);
    assert(isIPAddress("example.com") == false);
    assert(isIPAddress("abc") == false);

    // Test mock DNS resolution
    string ip = resolver.resolveA("example.com");
    assert(ip == "93.184.216.34");

    ip = resolver.resolveA("localhost");
    assert(ip == "127.0.0.1");

    ip = resolver.resolveA("nonexistent.domain");
    assert(ip == "NXDOMAIN");

    // Test CNAME resolution
    string cname = resolver.resolveCNAME("www.example.com");
    assert(cname == "example.com");

    // Test resolution simulation
    auto steps = resolver.simulateResolution("example.com");
    assert(steps.length > 0);
    assert(canFind(steps[0], "Resolving domain"));
    assert(canFind(steps[steps.length - 1], "DNS resolution successful"));

    // Test record retrieval
    auto records = resolver.getAllRecords("example.com");
    assert(records.length >= 1);

    // Test DNS record string representation
    if (records.length > 0) {
        string recordStr = records[0].toString();
        assert(canFind(recordStr, "example.com"));
    }

    writeln("All DNS resolution tests passed!");
    writeln("=== dns_lookup tests completed ===");
}
