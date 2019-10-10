import SSDP
import Foundation

let search = SearchSender.RTU.search(nt: .ssdp(ssdp: .all)).build()

func request() {
    do { try search.request() }
    catch { print("Deu merda: \(error)") }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
