import Foundation

public class AliveListener: Listener {
    override func received(response: Data, from addr: Address) throws -> Bool {
        guard
            let body = MessageBody.init(from: response)
        else { return false }
        
        delegate?.didReceiveMessage(body: body, from: addr)
        return true
    }
}
