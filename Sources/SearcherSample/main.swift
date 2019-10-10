import SSDP
import Foundation

let searcher = SearchSender.RTU.search(nt: .ssdp(ssdp: .all)).build()

searcher.listen(addr: Address.init(host: Host.ip, port: Host.port))

//func request() {
//    searcher.send()
//    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//        request()
//    }
//}
//
//request()

dispatchMain()
