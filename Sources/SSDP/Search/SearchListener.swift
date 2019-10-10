public class SearchListener: Listener {
    public func listen() throws {
        try super.listen(on: 0)
    }
    
    override func received(response: String, from host: String) throws {
        
    }
}
