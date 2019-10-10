public class AliveListener: Listener {
    public func listen() throws {
        try super.listen(on: 1900)
    }
    
    override func received(response: String, from host: String) throws {
        
    }
}
