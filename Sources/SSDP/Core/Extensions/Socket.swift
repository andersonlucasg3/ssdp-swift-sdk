import Foundation

public enum Network: String {
    case wifi = "en"
    case ethernet = "eth"
    case cellular = "pdp_ip"
    
    public enum Inet: String {
        case ipv4 = "ipv4"
        case ipv6 = "ipv6"
    }
}

public func getAddress(for network: Network, and inet: Network.Inet = .ipv4) -> String? {
    var address: String?

    // Get list of all interfaces on the local machine:
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }

    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee

        // Check for IPv4 or IPv6 interface:
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if (addrFamily == UInt8(AF_INET) && inet == .ipv4) ||
            (addrFamily == UInt8(AF_INET6) && inet == .ipv6) {

            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if name.hasPrefix(network.rawValue) {

                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
                break
            }
        }
    }
    freeifaddrs(ifaddr)

    return address
}
