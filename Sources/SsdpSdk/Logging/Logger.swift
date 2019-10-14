import class Foundation.NSString

public enum Log {
    static func debug(message: String, file: String = #file, line: Int = #line, function: String = #function) {
        #if DEBUG
        let fileName = NSString.init(string: file).lastPathComponent
        print("[\(fileName):\(line)] \(function) - \(message)")
        #endif
    }
}
