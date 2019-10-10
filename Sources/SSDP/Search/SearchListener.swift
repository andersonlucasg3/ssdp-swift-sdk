public class SearchListener: Listener {
    public func listen() throws {
        try super.listen(on: Host.port)
    }
    
    override func received(response: String, from host: String) throws {
        
    }
}
