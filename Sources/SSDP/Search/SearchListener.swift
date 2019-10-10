import Foundation

public class SearchListener: Listener {
    public func listen() {
        super.listen(on: Host.port, and: Host.ip)
    }
    
    override func received(response: Data, from host: String) throws {
        guard
            let body = MessageBody.init(from: response),
            body.method == .httpOk || body.method == .notify
        else { return }
        
        delegate?.didReceiveMessage(body: body, from: host)
    }
}
