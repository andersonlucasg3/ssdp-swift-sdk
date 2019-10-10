import SSDP
import Foundation

let searcher = SearchSender.RTU.search(nt: .ssdp(ssdp: .all)).build()

let listener = try SearchListener.init()
try listener.listen()

func request() {
    do { try searcher.send() }
    catch { print("Deu merda: \(error)") }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
