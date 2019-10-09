import struct Foundation.TimeInterval
import class UIKit.UIDevice
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
        case urn(domain: String, device: String, type: String, version: UInt16)
    }
    
    public enum USN {
        case uuid(uuid: String, nt: NT)
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
                let os = UIDevice.current.systemName
                let v = UIDevice.current.systemVersion
                let p = product()
                let pv = version()
                return "\(os)/\(v) UPnP/1.0 \(p)/\(pv)"
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
    }
    
    public enum MAN {
        case ssdp(ssdp: SSDP)
    }
    
    public enum MX {
        case delay(seconds: UInt16)
    }
    
    public enum ST {
        case st(nt: NT)
    }
}
