import Foundation

public class AliveListener: Listener {
    public func listen() {
        super.listen(on: Host.port)
    }
    
    override func received(response: Data, from host: String) throws {
        guard
            let body = MessageBody.init(from: response),
            body.method == .mSearch
        else { return }
        
        delegate?.didReceiveMessage(body: body, from: host)
    }
}
