import Logging
import ArgumentParser

// server context
public class ServerContext {
    public static var logger: Logger = Logger(label: "Cosmos Server")
    public static var codec: Codec = Codec()
    public static var defaultHome: String = ""

    public static let commands: [ParsableCommand.Type] = [
        StartCommand.self,
//        UnsafeResetAllCommand.self,
//        TenderminCommand.self,
//        ExportCommand.self,
//        VersionCommand.self
    ]
    
    public static var makeApp: MakeApp = {  _, _, _, _ in
        fatalError()
    }
    
    public static var exportApp: ExportApp = { _, _, _, _, _, _ in
        fatalError()
    }
}
