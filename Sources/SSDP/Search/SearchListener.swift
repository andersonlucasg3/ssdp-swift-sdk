public class SearchListener: Listener {
    public func listen() {
        super.listen(on: Host.port, and: Host.ip)
    }
    
    override func received(response: String, from host: String) throws {
        
    }
}
