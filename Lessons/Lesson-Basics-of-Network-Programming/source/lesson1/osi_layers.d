/**
 * Lesson 1: OSI Network Layers Visualization
 *
 * This example provides a visual representation of the OSI model and TCP/IP stack,
 * showing how data flows through different network layers.
 */

module lesson1.osi_layers;

import std.stdio;
import std.string;
import std.array;
import std.algorithm;

/**
 * Represents the 7 layers of the OSI model
 */
enum OSILayer {
    PHYSICAL = 1,    // Physical transmission
    DATA_LINK = 2,   // MAC addresses, switches
    NETWORK = 3,     // IP addresses, routing
    TRANSPORT = 4,   // TCP/UDP, ports
    SESSION = 5,     // Session management
    PRESENTATION = 6, // Data translation, encryption
    APPLICATION = 7   // HTTP, FTP, SMTP
}

/**
 * Represents the TCP/IP protocol stack layers
 */
enum TCPIPLayer {
    NETWORK_INTERFACE = 1,  // Hardware/physical layer
    INTERNET = 2,          // IP layer
    TRANSPORT = 3,         // TCP/UDP layer
    APPLICATION = 4        // Application protocols
}

/**
 * Represents a network packet as it travels through layers
 */
struct NetworkPacket {
    string data;
    string[string] headers; // Headers added at each layer

    /**
     * Add a header at a specific layer
     */
    void addHeader(string layerName, string headerInfo) {
        headers[layerName] = headerInfo;
    }

    /**
     * Get formatted representation showing all layers
     */
    string toString() const {
        string result = "Packet Contents:\n";
        result ~= "  Data: " ~ data ~ "\n";
        result ~= "  Headers:\n";

        foreach (layer, header; headers) {
            result ~= format("    %s: %s\n", layer, header);
        }

        return result;
    }
}

/**
 * Demonstrates how data flows through OSI layers during transmission
 */
class OSIModel {
private:
    string[] layerNames = [
        "Physical Layer",    // 1
        "Data Link Layer",   // 2
        "Network Layer",     // 3
        "Transport Layer",   // 4
        "Session Layer",     // 5
        "Presentation Layer", // 6
        "Application Layer"  // 7
    ];

    string[] layerDescriptions = [
        "Converts data into electrical/optical signals",
        "Provides node-to-node data transfer with MAC addresses",
        "Handles routing and logical addressing (IP)",
        "Provides end-to-end communication (TCP/UDP)",
        "Manages communication sessions between applications",
        "Handles data translation, encryption, compression",
        "Provides network services to applications (HTTP, FTP)"
    ];

    string[] layerProtocols = [
        "Ethernet, WiFi, USB, cables",
        "Ethernet, PPP, MAC addresses",
        "IP, ICMP, routing protocols",
        "TCP, UDP, ports, flow control",
        "NetBIOS, RPC, session establishment",
        "SSL/TLS, ASCII/EBCDIC, JPEG/PNG",
        "HTTP, FTP, SMTP, DNS"
    ];

public:
    /**
     * Display the OSI model layers
     */
    void displayLayers() {
        writeln("=== OSI Model (7 Layers) ===\n");

        for (int i = 6; i >= 0; i--) { // Display from Application (7) to Physical (1)
            int layerNum = i + 1;
            writefln("Layer %d: %s", layerNum, layerNames[i]);
            writefln("  Description: %s", layerDescriptions[i]);
            writefln("  Protocols: %s", layerProtocols[i]);
            writeln();
        }
    }

    /**
     * Simulate data encapsulation through OSI layers
     */
    NetworkPacket simulateDataFlow(string originalData) {
        writeln("=== Data Encapsulation Through OSI Layers ===\n");

        NetworkPacket packet;
        packet.data = originalData;

        // Start from Application layer (7) down to Physical (1)
        packet.addHeader("Application (7)", "HTTP GET request");
        writeln("7. Application Layer: User data + HTTP headers");

        packet.addHeader("Presentation (6)", "Data formatting, no encryption");
        writeln("6. Presentation Layer: Data translation/formatting");

        packet.addHeader("Session (5)", "Session ID: ABC123");
        writeln("5. Session Layer: Session establishment");

        packet.addHeader("Transport (4)", "TCP, Source Port: 12345, Dest Port: 80");
        writeln("4. Transport Layer: TCP segment with ports");

        packet.addHeader("Network (3)", "IP, Source: 192.168.1.100, Dest: 10.0.0.1");
        writeln("3. Network Layer: IP packet with addresses");

        packet.addHeader("Data Link (2)", "Ethernet, Source MAC: AA:BB:CC, Dest MAC: DD:EE:FF");
        writeln("2. Data Link Layer: Ethernet frame with MAC addresses");

        packet.addHeader("Physical (1)", "Electrical/optical signals on cable");
        writeln("1. Physical Layer: Binary data as electrical signals");

        writeln("\nData has been encapsulated through all 7 layers!");
        return packet;
    }

    /**
     * Show the relationship between OSI and TCP/IP models
     */
    void compareWithTCPIP() {
        writeln("\n=== OSI vs TCP/IP Model Comparison ===\n");

        writeln("TCP/IP Model (4 layers):");
        writeln("4. Application Layer    -> OSI Layers 5,6,7 (HTTP, FTP, DNS)");
        writeln("3. Transport Layer      -> OSI Layer 4 (TCP, UDP)");
        writeln("2. Internet Layer       -> OSI Layer 3 (IP, routing)");
        writeln("1. Network Interface    -> OSI Layers 1,2 (Ethernet, WiFi)");
        writeln();

        writeln("Key differences:");
        writeln("- TCP/IP is more practical and widely used");
        writeln("- OSI is more theoretical but provides better understanding");
        writeln("- TCP/IP combines some OSI layers for efficiency");
    }
}

/**
 * Demonstrates the TCP/IP protocol stack
 */
class TCPIPModel {
private:
    string[] tcpipLayers = [
        "Network Interface Layer", // 1
        "Internet Layer",          // 2
        "Transport Layer",         // 3
        "Application Layer"        // 4
    ];

    string[] tcpipProtocols = [
        "Ethernet, WiFi, PPP",
        "IP, ICMP, ARP",
        "TCP, UDP",
        "HTTP, FTP, DNS, SMTP"
    ];

public:
    /**
     * Display TCP/IP layers
     */
    void displayLayers() {
        writeln("=== TCP/IP Model (4 Layers) ===\n");

        for (int i = 3; i >= 0; i--) { // Display from Application (4) to Network Interface (1)
            int layerNum = i + 1;
            writefln("Layer %d: %s", layerNum, tcpipLayers[i]);
            writefln("  Protocols: %s", tcpipProtocols[i]);
            writeln();
        }
    }

    /**
     * Simulate a simple HTTP request through TCP/IP layers
     */
    void simulateHTTPRequest() {
        writeln("=== HTTP Request Through TCP/IP Layers ===\n");

        writeln("Sending: GET /index.html HTTP/1.1");
        writeln("Host: www.example.com");
        writeln();

        // Application Layer (4)
        writeln("4. Application Layer (HTTP):");
        writeln("   Creates HTTP request: 'GET /index.html HTTP/1.1'");
        writeln("   Adds headers: Host, User-Agent, etc.");
        writeln();

        // Transport Layer (3)
        writeln("3. Transport Layer (TCP):");
        writeln("   Adds TCP header with source/dest ports");
        writeln("   Establishes connection (3-way handshake)");
        writeln("   Ensures reliable delivery");
        writeln();

        // Internet Layer (2)
        writeln("2. Internet Layer (IP):");
        writeln("   Adds IP header with source/dest IP addresses");
        writeln("   Determines routing path to destination");
        writeln("   Handles packet fragmentation if needed");
        writeln();

        // Network Interface Layer (1)
        writeln("1. Network Interface Layer (Ethernet):");
        writeln("   Adds Ethernet header with MAC addresses");
        writeln("   Converts to electrical signals");
        writeln("   Transmits over physical medium");
        writeln();

        writeln("Packet transmitted successfully!");
    }
}

/**
 * Run the OSI/TCP-IP visualization example
 */
void runExample() {
    auto osiModel = new OSIModel();
    auto tcpipModel = new TCPIPModel();

    // Display OSI model
    osiModel.displayLayers();

    // Simulate data flow
    auto packet = osiModel.simulateDataFlow("Hello, World!");
    writeln("\nFinal packet structure:");
    writeln(packet.toString());

    // Compare with TCP/IP
    osiModel.compareWithTCPIP();

    // Display TCP/IP model
    tcpipModel.displayLayers();

    // Simulate HTTP request
    tcpipModel.simulateHTTPRequest();
}

unittest {
    writeln("=== Running osi_layers tests ===");

    // Test OSI Model
    auto osiModel = new OSIModel();
    auto packet = osiModel.simulateDataFlow("Test");

    assert(packet.data == "Test");
    assert("Application (7)" in packet.headers);
    assert("Transport (4)" in packet.headers);
    assert("Network (3)" in packet.headers);
    assert("Physical (1)" in packet.headers);

    // Test packet string representation
    string packetStr = packet.toString();
    assert(canFind(packetStr, "Test"));
    assert(canFind(packetStr, "Application"));
    assert(canFind(packetStr, "Headers"));

    // Test TCP/IP Model
    auto tcpipModel = new TCPIPModel();
    // Just verify methods don't crash
    tcpipModel.displayLayers();
    tcpipModel.simulateHTTPRequest();

    writeln("All OSI/TCP-IP model tests passed!");
    writeln("=== osi_layers tests completed ===");
}
