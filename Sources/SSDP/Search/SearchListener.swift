import Foundation

public class SearchListener: Listener {
    public override func listen(addr: Address) {
        super.listen(addr: addr)
    }
    
    override func received(response: Data, from addr: Address) throws -> Bool {
        guard
            let body = MessageBody.init(from: response)
        else {
            if let text = String.init(data: response, encoding: .ascii) {
                Log.debug(message: "Lost message: \(text)")
            }
            return false
        }
        
        delegate?.didReceiveMessage(body: body, from: addr)
        return true
    }
}
