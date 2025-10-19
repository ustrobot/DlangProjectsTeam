/**
 * Lesson 1: Client-Server Model Demonstration
 *
 * This example demonstrates the basic concepts of client-server communication
 * and shows how network programming works at a conceptual level.
 */

module lesson1.client_server_model;

import std.stdio;
import std.string;
import std.algorithm;

/**
 * Represents a simple message that can be sent between client and server
 */
struct Message {
    string sender;
    string content;
    long timestamp;

    /**
     * Create a formatted string representation of the message
     */
    string toString() const {
        return format("[%s] %s: %s", timestamp, sender, content);
    }
}

/**
 * Represents a simple server that can handle client connections
 */
class Server {
private:
    string name;
    Message[] messageHistory;

public:
    /**
     * Constructor
     */
    this(string serverName) {
        this.name = serverName;
        writeln(format("Server '%s' started and ready to accept connections", name));
    }

    /**
     * Handle an incoming message from a client
     */
    void handleMessage(Message msg) {
        messageHistory ~= msg;
        writeln(format("Server '%s' received: %s", name, msg.toString()));

        // Simulate processing time
        // In real networking, this would involve network I/O
    }

    /**
     * Get the number of messages received
     */
    size_t getMessageCount() const {
        return messageHistory.length;
    }

    /**
     * Get server status information
     */
    string getStatus() const {
        return format("Server '%s': %d messages processed", name, messageHistory.length);
    }
}

/**
 * Represents a simple client that can connect to a server
 */
class Client {
private:
    string name;
    Server connectedServer;

public:
    /**
     * Constructor
     */
    this(string clientName) {
        this.name = clientName;
        writeln(format("Client '%s' initialized", name));
    }

    /**
     * Connect to a server
     */
    void connect(Server server) {
        this.connectedServer = server;
        writeln(format("Client '%s' connected to server", name));
    }

    /**
     * Send a message to the connected server
     */
    void sendMessage(string content) {
        if (connectedServer is null) {
            writeln(format("Client '%s' error: Not connected to any server", name));
            return;
        }

        Message msg = Message(name, content, 1234567890); // Mock timestamp
        connectedServer.handleMessage(msg);
        writeln(format("Client '%s' sent message: %s", name, content));
    }

    /**
     * Disconnect from the server
     */
    void disconnect() {
        if (connectedServer !is null) {
            writeln(format("Client '%s' disconnected from server", name));
            connectedServer = null;
        }
    }
}

/**
 * Demonstrate the client-server model
 */
void demonstrateClientServer() {
    writeln("=== Client-Server Model Demonstration ===\n");

    // Create a server
    auto server = new Server("WebServer");

    // Create some clients
    auto client1 = new Client("Alice");
    auto client2 = new Client("Bob");
    auto client3 = new Client("Charlie");

    // Clients connect to the server
    client1.connect(server);
    client2.connect(server);
    client3.connect(server);

    writeln();

    // Clients send messages to the server
    client1.sendMessage("Hello from Alice!");
    client2.sendMessage("Hi everyone, this is Bob");
    client1.sendMessage("How is everyone doing?");
    client3.sendMessage("Charlie here, great to be connected!");
    client2.sendMessage("This networking stuff is cool!");

    writeln();

    // Show server status
    writeln("Server Status:");
    writeln(server.getStatus());

    // Clients disconnect
    client1.disconnect();
    client2.disconnect();
    client3.disconnect();

    writeln("\n=== Demonstration Complete ===");
}

/**
 * Run the example
 */
void runExample() {
    demonstrateClientServer();
}

unittest {
    writeln("=== Running client_server_model tests ===");

    // Test Message struct
    auto msg = Message("Alice", "Hello", 1234567890);
    assert(msg.sender == "Alice");
    assert(msg.content == "Hello");
    assert(msg.timestamp == 1234567890);

    string msgStr = msg.toString();
    assert(canFind(msgStr, "Alice"));
    assert(canFind(msgStr, "Hello"));

    // Test Server
    auto server = new Server("TestServer");
    assert(server.getMessageCount() == 0);
    assert(canFind(server.getStatus(), "TestServer"));

    // Test Client
    auto client = new Client("TestClient");

    // Test connection and messaging
    client.connect(server);
    client.sendMessage("Test message");

    assert(server.getMessageCount() == 1);

    // Test disconnection
    client.disconnect();

    // Test sending without connection (should not crash)
    auto disconnectedClient = new Client("Disconnected");
    disconnectedClient.sendMessage("This should fail gracefully");

    writeln("All client-server model tests passed!");
    writeln("=== client_server_model tests completed ===");
}
