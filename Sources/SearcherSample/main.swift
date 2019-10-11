import SSDP
import Foundation

let address = getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0"
let urn: Value.NT = .urn(domain: "com-globo-play-receiver", type: "appletv", version: 1)
let searcher = SearchSender.RTU.searchAll(delay: 5).build()//(nt: urn, delay: 5).build()
let listener = SearchListener.init()

class Del: ListenerDelegate {
    func didReceiveMessage(body: MessageBody, from addr: Address) {
        print("Did receive \n\(body.build())\nfrom \(addr)")
        
        if body.method == .notify {
            guard let nt = body.headers[.nt] else { return }
            if nt == .nt(value: urn) {
                print("Received filtered notify from \(addr)")
            }
        }
        if body.method == .httpOk {
            print("Received filtered httpok from \(addr)")
            guard let st = body.headers[.st] else { return }
            if st == .st(value: .nt(nt: urn)) {
                
            }
        }
    }
}

let del  = Del.init()
searcher.listenerDelegate = del
searcher.listen()

func request() {
    searcher.send()

    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
