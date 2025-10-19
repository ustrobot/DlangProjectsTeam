/**
 * Lesson 1: TCP vs UDP Protocol Basics
 *
 * This example demonstrates the fundamental differences between TCP and UDP protocols
 * and shows when to use each protocol for different types of network communication.
 */

module lesson1.tcp_udp_basics;

import std.stdio;
import std.string;
import std.random;
import std.algorithm;

/**
 * Enumeration of transport protocols
 */
enum Protocol {
    TCP,
    UDP
}

/**
 * Represents a network packet with protocol information
 */
struct Packet {
    Protocol protocol;
    string sourceIP;
    string destIP;
    int sourcePort;
    int destPort;
    string payload;
    bool reliable;      // For TCP: guaranteed delivery
    bool ordered;       // For TCP: packets arrive in order
    int sequenceNum;    // For TCP: sequence numbering

    /**
     * Create a string representation of the packet
     */
    string toString() const {
        string protoStr = protocol == Protocol.TCP ? "TCP" : "UDP";
        string flags = format("Reliable: %s, Ordered: %s",
                            reliable ? "Yes" : "No",
                            ordered ? "Yes" : "No");

        return format("%s Packet: %s:%d -> %s:%d [%s] %s",
                     protoStr, sourceIP, sourcePort, destIP, destPort,
                     payload, protocol == Protocol.TCP ? format("(Seq: %d)", sequenceNum) : "");
    }
}

/**
 * Simulates TCP connection establishment (3-way handshake)
 */
class TCPConnection {
private:
    string clientIP;
    string serverIP;
    int clientPort;
    int serverPort;
    bool established;
    int nextSequenceNum;

public:
    this(string clientIP, string serverIP, int clientPort, int serverPort) {
        this.clientIP = clientIP;
        this.serverIP = serverIP;
        this.clientPort = clientPort;
        this.serverPort = serverPort;
        this.established = false;
        this.nextSequenceNum = uniform(1000, 9999); // Random starting sequence
    }

    /**
     * Simulate the TCP 3-way handshake
     */
    bool establishConnection() {
        writeln("=== TCP Connection Establishment (3-way handshake) ===");

        // Step 1: SYN
        auto synPacket = Packet(Protocol.TCP, clientIP, serverIP, clientPort, serverPort,
                               "SYN", true, true, nextSequenceNum);
        writeln("1. " ~ synPacket.toString());
        nextSequenceNum++;

        // Step 2: SYN-ACK
        auto synAckPacket = Packet(Protocol.TCP, serverIP, clientIP, serverPort, clientPort,
                                  "SYN-ACK", true, true, 2000);
        writeln("2. " ~ synAckPacket.toString());

        // Step 3: ACK
        auto ackPacket = Packet(Protocol.TCP, clientIP, serverIP, clientPort, serverPort,
                               "ACK", true, true, nextSequenceNum);
        writeln("3. " ~ ackPacket.toString());

        established = true;
        writeln("Connection established successfully!");
        return true;
    }

    /**
     * Send data using TCP
     */
    void sendData(string data) {
        if (!established) {
            writeln("Error: Connection not established!");
            return;
        }

        auto dataPacket = Packet(Protocol.TCP, clientIP, serverIP, clientPort, serverPort,
                                data, true, true, nextSequenceNum);
        writeln("Sending TCP data: " ~ dataPacket.toString());
        nextSequenceNum += data.length;
    }

    /**
     * Close TCP connection (4-way handshake)
     */
    void closeConnection() {
        if (!established) return;

        writeln("=== TCP Connection Termination (4-way handshake) ===");

        // Step 1: FIN
        auto finPacket = Packet(Protocol.TCP, clientIP, serverIP, clientPort, serverPort,
                               "FIN", true, true, nextSequenceNum);
        writeln("1. " ~ finPacket.toString());

        // Step 2: ACK
        auto ackPacket = Packet(Protocol.TCP, serverIP, clientIP, serverPort, clientPort,
                               "ACK", true, true, 2001);
        writeln("2. " ~ ackPacket.toString());

        // Step 3: FIN
        auto fin2Packet = Packet(Protocol.TCP, serverIP, clientIP, serverPort, clientPort,
                                "FIN", true, true, 2002);
        writeln("3. " ~ fin2Packet.toString());

        // Step 4: ACK
        auto ack2Packet = Packet(Protocol.TCP, clientIP, serverIP, clientPort, serverPort,
                                "ACK", true, true, nextSequenceNum + 1);
        writeln("4. " ~ ack2Packet.toString());

        established = false;
        writeln("Connection closed.");
    }
}

/**
 * Simulates UDP communication (connectionless)
 */
class UDPCommunicator {
private:
    string localIP;
    int localPort;

public:
    this(string localIP, int localPort) {
        this.localIP = localIP;
        this.localPort = localPort;
    }

    /**
     * Send data using UDP (no connection establishment)
     */
    void sendData(string destIP, int destPort, string data) {
        auto udpPacket = Packet(Protocol.UDP, localIP, destIP, localPort, destPort,
                               data, false, false, 0);
        writeln("Sending UDP data: " ~ udpPacket.toString());
        writeln("Note: No delivery guarantee, no ordering guarantee");
    }
}

/**
 * Demonstrate TCP vs UDP differences
 */
void demonstrateProtocolComparison() {
    writeln("=== TCP vs UDP Protocol Comparison ===\n");

    // TCP Example
    writeln("--- TCP Example (Reliable, Connection-Oriented) ---");
    auto tcpConn = new TCPConnection("192.168.1.100", "10.0.0.1", 12345, 80);
    tcpConn.establishConnection();
    writeln();
    tcpConn.sendData("Hello, reliable server!");
    tcpConn.sendData("This message will definitely arrive in order");
    writeln();
    tcpConn.closeConnection();

    writeln("\n==================================================\n");

    // UDP Example
    writeln("--- UDP Example (Unreliable, Connectionless) ---");
    auto udpComm = new UDPCommunicator("192.168.1.100", 12345);
    udpComm.sendData("10.0.0.1", 53, "DNS query: www.example.com");
    udpComm.sendData("10.0.0.1", 53, "Another DNS query");
    writeln("Note: These packets are sent independently, no connection setup/teardown");

    writeln("\n==================================================\n");

    // Use case comparison
    writeln("=== When to Use Each Protocol ===");
    writeln("TCP is best for:");
    writeln("  - File transfers (HTTP, FTP)");
    writeln("  - Email (SMTP, IMAP)");
    writeln("  - Remote access (SSH, Telnet)");
    writeln("  - Any application requiring guaranteed, ordered delivery");
    writeln();
    writeln("UDP is best for:");
    writeln("  - Real-time applications (VoIP, gaming)");
    writeln("  - Streaming media");
    writeln("  - DNS queries");
    writeln("  - Network monitoring (ping, traceroute)");
    writeln("  - When speed is more important than reliability");
}

/**
 * Run the example
 */
void runExample() {
    demonstrateProtocolComparison();
}

unittest {
    writeln("=== Running tcp_udp_basics tests ===");

    // Test Packet struct
    auto tcpPacket = Packet(Protocol.TCP, "192.168.1.1", "10.0.0.1", 12345, 80,
                           "Hello", true, true, 1000);
    assert(tcpPacket.protocol == Protocol.TCP);
    assert(tcpPacket.sourceIP == "192.168.1.1");
    assert(tcpPacket.destIP == "10.0.0.1");
    assert(tcpPacket.reliable == true);
    assert(tcpPacket.ordered == true);

    auto udpPacket = Packet(Protocol.UDP, "192.168.1.1", "10.0.0.1", 12345, 53,
                           "Query", false, false, 0);
    assert(udpPacket.protocol == Protocol.UDP);
    assert(udpPacket.reliable == false);
    assert(udpPacket.ordered == false);

    // Test string representations
    string tcpStr = tcpPacket.toString();
    string udpStr = udpPacket.toString();
    assert(canFind(tcpStr, "TCP"));
    assert(canFind(tcpStr, "Hello"));
    assert(canFind(tcpStr, "Seq: 1000"));
    assert(canFind(udpStr, "UDP"));
    assert(canFind(udpStr, "Query"));
    assert(!canFind(udpStr, "Seq:"));

    // Test TCP Connection
    auto tcpConn = new TCPConnection("192.168.1.100", "10.0.0.1", 12345, 80);
    assert(tcpConn.establishConnection() == true);

    // Test UDP Communicator
    auto udpComm = new UDPCommunicator("192.168.1.100", 12345);
    // Just verify it doesn't crash
    udpComm.sendData("10.0.0.1", 53, "test");

    writeln("All TCP/UDP protocol tests passed!");
    writeln("=== tcp_udp_basics tests completed ===");
}
