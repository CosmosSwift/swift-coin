import ArgumentParser
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

// Executor wraps the cobra Command with a nicer Execute method
public final class Executor {
    let command: ParsableCommand.Type

    public init(command: ParsableCommand.Type) {
        self.command = command
    }
    
    public func execute() {
        command.main()
    }
}

