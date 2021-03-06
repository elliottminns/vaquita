

public protocol ByteType {
    static var encodingType: EncodingType { get }
    static func fromString(string: String) -> [Self]
}

extension UInt8: ByteType {
    public static var encodingType: EncodingType {
        return .UTF8
    }

    public static func fromString(string: String) -> [UInt8] {
        let buf = [UInt8](string.utf8)
        return buf
    }
}

enum EncodingError: ErrorType {
    case Failed
}

public struct Data {

    public let bytes: [UInt8]

    public var size: Int {
        return self.bytes.count * sizeof(UInt8)
    }

    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    public init(string: String) {
        self.bytes = UInt8.fromString(string)
    }

    public func toString() throws -> String {
        var bytes = self.bytes
        guard let str = String(bytesNoCopy: &bytes,
            length: bytes.count * sizeof(UInt8),
            encoding: UInt8.encodingType.encoding,
            freeWhenDone: false) else {
                throw EncodingError.Failed
        }

        return str
    }
}
