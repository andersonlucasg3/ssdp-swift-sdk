import Foundation



public class AliveListener: Listener {
    public func listen() {
        super.listen(on: Host.port)
    }
    
    override func received(response: Data, from host: String) throws {
        guard let body = MessageBody.init(from: response) else {
            Log.debug(message: "Failed message: \n\(String.init(data: response, encoding: .ascii)!)")
            return
        }
        
        
    }
}
