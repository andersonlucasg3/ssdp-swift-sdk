import Foundation

public class AliveListener: Listener {
    override func received(response: Data, from addr: Address) throws {
        guard
            let body = MessageBody.init(from: response),
            body.method == .mSearch
        else { return }
        
        delegate?.didReceiveMessage(body: body, from: addr)
    }
}
