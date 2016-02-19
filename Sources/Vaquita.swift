import Echo
import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public enum EncodingType {
    case UTF8

    var typeForEncoding: Any.Type {

        let type: Any.Type
        switch self {
        case UTF8:
            type = UInt8.self
        }

        return type
    }

    var encoding: UInt {
        switch self {
        case UTF8:
            return NSUTF8StringEncoding
        }
    }
}

public enum FileError: ErrorType {
    case ReadFailed
    case WriteFailed
    case OpenFailed
}

public class Vaquita {

    static let fileQueue = dispatch_queue_create("com.vaquita.file", 
                                                 DISPATCH_QUEUE_SERIAL)
    
    public class func readFile(path path: String, 
                               handler: (data: Data?, error: ErrorType?) -> ()) {
        dispatch_async(fileQueue) {
            do {
                let data = try self.readFileSync(path: path)
                handler(data: data, error: nil)
            } catch {
                handler(data: nil, error: error)
            }
        }
    }

    public class func readFileSync(path path: String) throws -> Data {
        let fileptr = fopen(path, "rb")
        if fileptr == nil {
            throw FileError.OpenFailed
        }
        fseek(fileptr, 0, SEEK_END)
        let fileLength = ftell(fileptr)
        rewind(fileptr)

        var buffer: UnsafeMutablePointer<UInt8> = 
            UnsafeMutablePointer.alloc(fileLength)
        fread(buffer, fileLength, 1, fileptr)
        fclose(fileptr)

        var data = [UInt8]()
        for _ in 0 ..< fileLength {
            
            data.append(buffer.memory)
            buffer = buffer.successor()
        }

        buffer.destroy()

        return Data(bytes: data)
    }

    public class func writeData(data: Data, toFilePath path: String, 
        handler: (error: ErrorType?) -> ()) {
        dispatch_async(fileQueue) {
            do {
                try self.writeDataSync(data, toFilePath: path)
                handler(error: nil)
            } catch {
                handler(error: error)
            }
        }
    }

    public class func writeDataSync(data: Data, toFilePath path: String) throws {
        let fileptr = fopen(path, "w")
        if fileptr == nil {
            throw FileError.OpenFailed
        }
        let string = try data.toString()
        fwrite(string, 1, data.size, fileptr)
        fclose(fileptr)
    }
}
