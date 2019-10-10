public class AliveListener: Listener {
    public func listen() {
        super.listen(on: Host.port)
    }
    
    override func received(response: String, from host: String) throws {
        
    }
}
