import Foundation

public class SearchListener: Listener {
    override func received(response: Data, from addr: Address) throws {
        guard
            let body = MessageBody.init(from: response),
            body.method == .httpOk || body.method == .notify
        else { return }
        
        delegate?.didReceiveMessage(body: body, from: addr)
    }
}
