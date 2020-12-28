// An Invariant is a function which tests a particular invariant.
// The invariant returns a descriptive message about what happened
// and a boolean indicating whether the invariant has been broken.
// The simulator will then halt and print the logs.
public typealias Invariant = (_ request: Request) -> (String, Bool)

// Invariants defines a group of invariants
typealias Invariants = [Invariant]

// expected interface for registering invariants
public protocol InvariantRegistry  {
    func registerRoute(moduleName: String, route: String, invariant: Invariant)
}

// FormatInvariant returns a standardized invariant message.
func formatInvariant(module: String, name: String, message: String) -> String {
    "\(module): \(name) invariant\n\(message)\n"
}
