import struct Foundation.TimeInterval
#if !os(macOS)
import class UIKit.UIDevice
#endif
import class Foundation.Bundle

public enum Value: Equatable {
    case host(value: Host)
    case date(value: TimeInterval)
    case ext
    case nt(value: NT)
    case nts(value: NTS)
    case location(value: String)
    case cacheControl(value: CacheControl)
    case server(value: Server)
    case usn(value: USN)
    case man(value: MAN)
    case mx(value: MX)
    case st(value: ST)
    case userAgent(value: Server)
        
    public static func == (lhs: Value, rhs: Value) -> Bool {
        switch lhs {
        case .cacheControl: if case .cacheControl = rhs { return true }
        case .host: if case .host = rhs { return true }
        case .date: if case .date = rhs { return true }
        case .ext: if case .ext = rhs { return true }
        case .nt: if case .nt = rhs { return true }
        case .nts: if case .nts = rhs { return true }
        case .location: if case .location = rhs { return true }
        case .server: if case .server = rhs { return true }
        case .usn: if case .usn = rhs { return true }
        case .man: if case .man = rhs { return true }
        case .mx: if case .mx = rhs { return true }
        case .st: if case .st = rhs { return true }
        case .userAgent: if case .userAgent = rhs { return true }
        }
        return false
    }
    
    public enum NT: Equatable {
        case upnp
        case urn(domain: String, type: String, version: UInt16)
        case ssdp(ssdp: SSDP)
        case uuid(uuid: String)
    }
    
    public enum USN {
        case nt(uuid: String, nt: NT)
        case uuid(uuid: String)
    }

    public enum NTS {
        case sspd(value: SSDP)
    }

    public enum CacheControl {
        case maxAge(seconds: UInt16)
    }
    
    public enum Server: RawRepresentable {
        case this
        case custom(os: String, osv: String, p: String, pv: String)
        
        public var rawValue: String {
            switch self {
            case .this:
                #if !os(macOS)
                let os = UIDevice.current.systemName
                let v = UIDevice.current.systemVersion
                let p = product()
                let pv = version()
                return toString(os, v, p, pv)
                #else
                return toString("macOS", "10.15", "Sample", "1.0")
                #endif
            case .custom(let os, let osv, let p, let pv):
                return toString(os, osv, p, pv)
            }
        }
        
        public init?(rawValue: String) {
            return nil
        }
        
        private func toString(_ os: String, _ osv: String, _ p: String, _ pv: String) -> String {
            return "\(os)/\(osv) UPnP/1.0 \(p)/\(pv)"
        }
        
        private func product() -> String {
            return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown"
        }
        
        private func version() -> String {
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.1"
        }
    }

    public enum SSDP: String {
        case alive = "alive"
        case byebye = "byebye"
        case discover = "discover"
        case all = "all"
    }
    
    public enum MAN {
        case ssdp(ssdp: SSDP)
    }
    
    public enum MX {
        case delay(seconds: UInt16)
    }
    
    public enum ST: Equatable {
        case nt(nt: NT)
        case ssdp(ssdp: SSDP)
    }
}
