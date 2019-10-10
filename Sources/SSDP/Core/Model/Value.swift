import struct Foundation.TimeInterval
#if !os(macOS)
import class UIKit.UIDevice
#endif
import class Foundation.Bundle

public enum Value {
    case host(value: Host)
    case nt(value: NT)
    case nts(value: NTS)
    case location(value: String)
    case cacheControl(value: CacheControl)
    case server(value: Server)
    case usn(value: USN)
    case man(value: MAN)
    case mx(value: MX)
    case st(value: ST)
        
    public enum NT {
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
        
        public var rawValue: String {
            switch self {
            case .this:
                #if !os(macOS)
                let os = UIDevice.current.systemName
                let v = UIDevice.current.systemVersion
                let p = product()
                let pv = version()
                return "\(os)/\(v) UPnP/1.0 \(p)/\(pv)"
                #else
                return "macOS/15 UPnP/1.0 test/1.0"
                #endif
            }
        }
        
        public init?(rawValue: String) {
            return nil
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
    
    public enum ST {
        case nt(nt: NT)
        case ssdp(ssdp: SSDP)
    }
}
