import struct Foundation.TimeInterval
import class UIKit.UIDevice
import class Foundation.Bundle

public enum Value: RawRepresentable {
    case host(value: Host)
    case nt(value: NT)
    case nts(value: NTS)
    case location(value: String)
    case cacheControl(value: CacheControl)
    case server(value: Server)
    
    public var rawValue: String {
        switch self {
        case .host(let value): return value.rawValue
        case .nt(let value): return from(nt: value)
        case .nts(let value): return from(nts: value)
        case .location(let value): return value
        case .cacheControl(let value): return from(cc: value)
        case .server(let value): return value.rawValue
        }
    }
    
    public init?(rawValue: String) {
        return nil
    }
    
    fileprivate func from(nt: NT) -> String {
        switch nt {
        case .urn(let domain, let device, let type, let version):
            return "urn:\(domain):\(device):\(type):\(version)"
        }
    }
    
    fileprivate func from(nts: NTS) -> String {
        switch nts {
        case .sspd(let value): return "ssdp:\(value.rawValue)"
        }
    }
    
    fileprivate func from(cc: CacheControl) -> String {
        switch cc {
        case .maxAge(let seconds): return "max-age=\(seconds)"
        }
    }
        
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
        case value
        
        public var rawValue: String {
            switch self {
            case .value:
                let os = UIDevice.current.systemName
                let v = UIDevice.current.systemVersion
                let p = product()
                let pv = version()
                return "\(os)/\(v) UPnP/1.0 \(p)/\(pv)"
            }
        }
        
        public init?(rawValue: Self.RawValue) {
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
    }
}
