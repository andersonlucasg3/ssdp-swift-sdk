import Foundation

public class SearchListener: Listener {
    public override func listen(addr: Address) {
        super.listen(addr: addr)
    }
    
    override func received(response: Data, from addr: Address) throws {
        guard
            let body = MessageBody.init(from: response)
        else { return }
        
        delegate?.didReceiveMessage(body: body, from: addr)
    }
}
