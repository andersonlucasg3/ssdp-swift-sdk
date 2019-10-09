import SSDPClient
import HeliumLogger
import LoggerAPI
import Foundation

let client = SSDPDiscovery.init()

Log.logger = HeliumLogger.init(.debug)

client.discoverService(forDuration: 10)

DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
    exit(0)
}

dispatchMain()
