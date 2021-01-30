import ArgumentParser

public enum KeyringBacked: String, ExpressibleByArgument {
    case file = "file"
    case os = "os"
    case keyWallet = "kwallet"
    case pass = "pass"
    case test = "test"
}
