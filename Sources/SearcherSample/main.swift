import SSDP
import Foundation

let search = SearchRequest.RTU.search(nt: .ssdp(ssdp: .all)).build()

do {
    try search.request()
} catch {
    print("Deu merda: \(error)")
}

DispatchQueue.main.asyncAfter(deadline: .now() + 18) {
    exit(0)
}

dispatchMain()
