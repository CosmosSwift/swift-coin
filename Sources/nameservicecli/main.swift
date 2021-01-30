import ArgumentParser
import Tendermint
import Cosmos
import App

struct NameserviceCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Command line interface for interacting with nameserviced",
        subcommands: [
            KeysCommand.self,
        ]
    )
}
let codec = NameServiceApp.makeCodec()

NameServiceApp.configure()

let executor = Executor(command: NameserviceCLI.self)
executor.execute()
