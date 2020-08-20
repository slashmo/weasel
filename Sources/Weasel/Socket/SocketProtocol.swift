public protocol SocketProtocol {
    var isOpen: Bool { get }

    func setOption<T>(level: CInt, name: CInt, value: T) throws
    func bind(to address: SocketAddress) throws
    func listen(backlog: CInt) throws
    func accept() throws -> SocketProtocol?
    func read(pointer: UnsafeMutableRawBufferPointer) throws -> Int
    func write(pointer: UnsafeRawBufferPointer) throws -> Int
    func close() throws
}

public extension SocketProtocol {
    func readBytes(inChunksOf chunkSize: Int = 128 * 1024) throws -> [UInt8] {
        var bytes = [UInt8]()
        var readerIndex = 0

        while true {
            bytes.append(contentsOf: [UInt8](repeating: 0, count: chunkSize))
            let offset = chunkSize * readerIndex
            let readCount = try bytes[offset...].withUnsafeMutableBytes(read)
            if readCount < chunkSize {
                bytes.removeLast(chunkSize - readCount)
                break
            } else if readCount == chunkSize {
                readerIndex += 1
            }
        }
        return bytes
    }

    @discardableResult
    func writeString(_ string: String) throws -> Int {
        try [UInt8](string.utf8).withUnsafeBytes(write)
    }
}
