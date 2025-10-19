/**
 * Lesson 1: IP Address Manipulation and Validation
 *
 * This example demonstrates how IP addresses work, including validation,
 * manipulation, subnet calculations, and IP address classes.
 */

module lesson1.ip_addressing;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.algorithm;
import std.regex;

/**
 * Represents an IPv4 address
 */
struct IPv4Address {
private:
    ubyte[4] octets; // Four octets (0-255)

public:
    /**
     * Constructor from four octets
     */
    this(ubyte o1, ubyte o2, ubyte o3, ubyte o4) {
        octets = [o1, o2, o3, o4];
    }

    /**
     * Constructor from string representation
     */
    this(string ipString) {
        auto parts = ipString.split(".");
        if (parts.length != 4) {
            throw new Exception("Invalid IPv4 address format: " ~ ipString);
        }

        for (int i = 0; i < 4; i++) {
            try {
                int value = to!int(parts[i]);
                if (value < 0 || value > 255) {
                    throw new Exception("Invalid octet value: " ~ parts[i]);
                }
                octets[i] = cast(ubyte)value;
            } catch (ConvException e) {
                throw new Exception("Invalid octet: " ~ parts[i]);
            }
        }
    }

    /**
     * Get string representation
     */
    string toString() const {
        return format("%d.%d.%d.%d", octets[0], octets[1], octets[2], octets[3]);
    }

    /**
     * Get individual octets
     */
    ubyte getOctet(int index) const {
        if (index < 0 || index > 3) {
            throw new Exception("Invalid octet index: " ~ to!string(index));
        }
        return octets[index];
    }

    /**
     * Convert to 32-bit integer
     */
    uint toInt() const {
        return (cast(uint)octets[0] << 24) |
               (cast(uint)octets[1] << 16) |
               (cast(uint)octets[2] << 8) |
               cast(uint)octets[3];
    }

    /**
     * Check if this is a private IP address
     */
    bool isPrivate() const {
        // 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
        if (octets[0] == 10) return true;
        if (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) return true;
        if (octets[0] == 192 && octets[1] == 168) return true;
        return false;
    }

    /**
     * Check if this is a loopback address
     */
    bool isLoopback() const {
        return octets[0] == 127;
    }

    /**
     * Get IP address class (A, B, C, D, E)
     */
    char getClass() const {
        ubyte firstOctet = octets[0];

        if (firstOctet >= 1 && firstOctet <= 126) return 'A';
        if (firstOctet >= 128 && firstOctet <= 191) return 'B';
        if (firstOctet >= 192 && firstOctet <= 223) return 'C';
        if (firstOctet >= 224 && firstOctet <= 239) return 'D'; // Multicast
        if (firstOctet >= 240 && firstOctet <= 255) return 'E'; // Reserved

        return '?';
    }
}

/**
 * Represents a subnet mask
 */
struct SubnetMask {
private:
    IPv4Address mask;

public:
    /**
     * Constructor from CIDR notation (e.g., "/24")
     */
    this(int cidr) {
        if (cidr < 0 || cidr > 32) {
            throw new Exception("Invalid CIDR value: " ~ to!string(cidr));
        }

        uint maskValue = 0xFFFFFFFF << (32 - cidr);
        ubyte o1 = cast(ubyte)((maskValue >> 24) & 0xFF);
        ubyte o2 = cast(ubyte)((maskValue >> 16) & 0xFF);
        ubyte o3 = cast(ubyte)((maskValue >> 8) & 0xFF);
        ubyte o4 = cast(ubyte)(maskValue & 0xFF);

        mask = IPv4Address(o1, o2, o3, o4);
    }

    /**
     * Constructor from IPv4Address
     */
    this(IPv4Address maskAddr) {
        mask = maskAddr;
    }

    /**
     * Get CIDR notation
     */
    int getCIDR() const {
        uint maskInt = mask.toInt();
        int cidr = 0;

        for (int i = 31; i >= 0; i--) {
            if ((maskInt & (1 << i)) != 0) {
                cidr++;
            } else {
                break;
            }
        }

        return cidr;
    }

    /**
     * Get string representation
     */
    string toString() const {
        return mask.toString();
    }

    /**
     * Get the IPv4Address representation
     */
    IPv4Address getAddress() const {
        return mask;
    }
}

/**
 * Represents a subnet (network address + mask)
 */
struct Subnet {
    IPv4Address network;
    SubnetMask mask;

    /**
     * Constructor
     */
    this(IPv4Address networkAddr, SubnetMask subnetMask) {
        network = networkAddr;
        mask = subnetMask;
    }

    /**
     * Constructor from CIDR notation (e.g., "192.168.1.0/24")
     */
    this(string cidrNotation) {
        auto parts = cidrNotation.split("/");
        if (parts.length != 2) {
            throw new Exception("Invalid CIDR notation: " ~ cidrNotation);
        }

        network = IPv4Address(parts[0]);
        mask = SubnetMask(to!int(parts[1]));
    }

    /**
     * Check if an IP address belongs to this subnet
     */
    bool contains(IPv4Address ip) const {
        uint networkInt = network.toInt() & mask.getAddress().toInt();
        uint ipInt = ip.toInt() & mask.getAddress().toInt();
        return networkInt == ipInt;
    }

    /**
     * Get broadcast address for this subnet
     */
    IPv4Address getBroadcastAddress() const {
        uint networkInt = network.toInt() & mask.getAddress().toInt();
        uint broadcastInt = networkInt | (~mask.getAddress().toInt() & 0xFFFFFFFF);

        ubyte o1 = cast(ubyte)((broadcastInt >> 24) & 0xFF);
        ubyte o2 = cast(ubyte)((broadcastInt >> 16) & 0xFF);
        ubyte o3 = cast(ubyte)((broadcastInt >> 8) & 0xFF);
        ubyte o4 = cast(ubyte)(broadcastInt & 0xFF);

        return IPv4Address(o1, o2, o3, o4);
    }

    /**
     * Get number of host addresses in this subnet
     */
    uint getHostCount() const {
        int cidr = mask.getCIDR();
        if (cidr >= 31) return 2; // Point-to-point links
        if (cidr == 32) return 1; // Single host
        return (1 << (32 - cidr)) - 2; // Subtract network and broadcast addresses
    }

    /**
     * Get string representation
     */
    string toString() const {
        return format("%s/%d", network.toString(), mask.getCIDR());
    }
}

/**
 * Validate an IPv4 address string
 */
bool isValidIPv4(string ipString) {
    try {
        IPv4Address ip = IPv4Address(ipString);
        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Demonstrate IP address concepts
 */
void demonstrateIPAddressing() {
    writeln("=== IP Address Manipulation and Validation ===\n");

    // Test IP address creation and validation
    writeln("--- IP Address Creation and Validation ---");
    string[] testIPs = [
        "192.168.1.1", "10.0.0.1", "172.16.0.1", "127.0.0.1",
        "255.255.255.255", "0.0.0.0", "invalid.ip", "256.1.1.1"
    ];

    foreach (ipStr; testIPs) {
        bool valid = isValidIPv4(ipStr);
        writefln("%-15s -> %s", ipStr, valid ? "Valid" : "Invalid");

        if (valid) {
            IPv4Address ip = IPv4Address(ipStr);
            writefln("  Class: %s, Private: %s, Loopback: %s",
                    ip.getClass(), ip.isPrivate() ? "Yes" : "No",
                    ip.isLoopback() ? "Yes" : "No");
        }
    }

    writeln("\n==================================================\n");

    // Demonstrate subnet calculations
    writeln("--- Subnet Calculations ---");

    string[] testSubnets = ["192.168.1.0/24", "10.0.0.0/8", "172.16.0.0/16"];

    foreach (subnetStr; testSubnets) {
        try {
            Subnet subnet = Subnet(subnetStr);
            writefln("Subnet: %s", subnet.toString());
            writefln("  Network: %s", subnet.network.toString());
            writefln("  Mask: %s", subnet.mask.toString());
            writefln("  Broadcast: %s", subnet.getBroadcastAddress().toString());
            writefln("  Host count: %d", subnet.getHostCount());

            // Test some addresses
            IPv4Address[] testAddrs = [
                IPv4Address(subnetStr.split("/")[0]), // Network address
                subnet.getBroadcastAddress(),         // Broadcast address
                IPv4Address("192.168.1.100")          // Random address
            ];

            foreach (addr; testAddrs) {
                bool contained = subnet.contains(addr);
                writefln("  Contains %s: %s", addr.toString(), contained ? "Yes" : "No");
            }
            writeln();
        } catch (Exception e) {
            writefln("Error with subnet %s: %s", subnetStr, e.msg);
        }
    }

    writeln("\n==================================================\n");

    // Demonstrate IP address classes
    writeln("--- IP Address Classes ---");
    IPv4Address[] classExamples = [
        IPv4Address("10.1.1.1"),     // Class A private
        IPv4Address("172.20.1.1"),   // Class B private
        IPv4Address("192.168.1.1"),  // Class C private
        IPv4Address("224.1.1.1"),    // Class D multicast
        IPv4Address("8.8.8.8")       // Class A public (Google DNS)
    ];

    foreach (ip; classExamples) {
        writefln("%-15s -> Class %s (%s, %s)",
                ip.toString(), ip.getClass(),
                ip.isPrivate() ? "Private" : "Public",
                ip.isLoopback() ? "Loopback" : "Regular");
    }

    writeln("\n=== IP Addressing Concepts ===");
    writeln("• IP addresses are 32-bit numbers written in dotted decimal notation");
    writeln("• Subnet masks determine which part is network vs host");
    writeln("• CIDR notation (/24) specifies subnet mask length");
    writeln("• Private addresses (10.x.x.x, 172.16-31.x.x, 192.168.x.x) are not routable on the internet");
    writeln("• Loopback address (127.x.x.x) refers to the local machine");
}

/**
 * Run the example
 */
void runExample() {
    demonstrateIPAddressing();
}

unittest {
    writeln("=== Running ip_addressing tests ===");

    // Test IPv4Address creation and validation
    auto ip1 = IPv4Address(192, 168, 1, 1);
    assert(ip1.toString() == "192.168.1.1");

    auto ip2 = IPv4Address("10.0.0.1");
    assert(ip2.toString() == "10.0.0.1");
    assert(ip2.getOctet(0) == 10);
    assert(ip2.getOctet(3) == 1);

    // Test invalid IP addresses
    bool caught = false;
    try {
        auto invalid = IPv4Address("256.1.1.1");
    } catch (Exception e) {
        caught = true;
    }
    assert(caught);

    caught = false;
    try {
        auto invalid = IPv4Address("192.168.1");
    } catch (Exception e) {
        caught = true;
    }
    assert(caught);

    // Test IP address properties
    auto privateIP = IPv4Address("192.168.1.1");
    assert(privateIP.isPrivate() == true);
    assert(privateIP.getClass() == 'C');

    auto loopbackIP = IPv4Address("127.0.0.1");
    assert(loopbackIP.isLoopback() == true);

    auto publicIP = IPv4Address("8.8.8.8");
    assert(publicIP.isPrivate() == false);
    assert(publicIP.getClass() == 'A');

    // Test validation function
    assert(isValidIPv4("192.168.1.1") == true);
    assert(isValidIPv4("invalid.ip") == false);
    assert(isValidIPv4("256.1.1.1") == false);

    // Test subnet masks
    auto mask24 = SubnetMask(24);
    assert(mask24.getCIDR() == 24);
    assert(mask24.toString() == "255.255.255.0");

    auto mask8 = SubnetMask(8);
    assert(mask8.getCIDR() == 8);
    assert(mask8.toString() == "255.0.0.0");

    // Test subnets
    auto subnet = Subnet("192.168.1.0/24");
    assert(subnet.contains(IPv4Address("192.168.1.100")) == true);
    assert(subnet.contains(IPv4Address("192.168.2.100")) == false);
    assert(subnet.getBroadcastAddress().toString() == "192.168.1.255");
    assert(subnet.getHostCount() == 254); // 256 - 2 (network + broadcast)

    auto smallSubnet = Subnet("192.168.1.0/30");
    assert(smallSubnet.getHostCount() == 2);

    writeln("All IP addressing tests passed!");
    writeln("=== ip_addressing tests completed ===");
}
