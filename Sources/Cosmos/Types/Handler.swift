// Handler defines the core of the state transition function of an application.
public typealias Handler = (_ request: Request, _ message: Message) throws -> Result

// AnteHandler authenticates transactions, before their internal messages are handled.
// If newCtx.IsZero(), ctx is used instead.
public typealias AnteHandler = (_ request: Request, _ transaction: Transaction, _ simulate: Bool) throws -> Request?

// AnteDecorator wraps the next AnteHandler to perform custom pre- and post-processing.
public protocol AnteDecorator {
    func anteHandle(
        request: Request,
        transaction: Transaction,
        simulate: Bool,
        next: AnteHandler?
    ) throws -> Request
}

// ChainDecorator chains AnteDecorators together with each AnteDecorator
// wrapping over the decorators further along chain and returns a single AnteHandler.
//
// NOTE: The first element is outermost decorator, while the last element is innermost
// decorator. Decorator ordering is critical since some decorators will expect
// certain checks and updates to be performed (e.g. the Context) before the decorator
// is run. These expectations should be documented clearly in a CONTRACT docline
// in the decorator's godoc.
//
// NOTE: Any application that uses GasMeter to limit transaction processing cost
// MUST set GasMeter with the FIRST AnteDecorator. Failing to do so will cause
// transactions to be processed with an infinite gasmeter and open a DOS attack vector.
// Use `ante.SetUpContextDecorator` or a custom Decorator with similar functionality.
// Returns nil when no AnteDecorator are supplied.
public func chainAnteDecorators(_ chain: [AnteDecorator]) -> AnteHandler? {
    var chain = chain
    
    guard !chain.isEmpty else {
        return nil
    }

    // handle non-terminated decorators chain
    if !(chain.last is Terminator) {
        chain.append(Terminator())
    }

    return { request, transaction, simulate in
        return try chain[0].anteHandle(
            request: request,
            transaction: transaction,
            simulate: simulate,
            next: chainAnteDecorators(Array(chain.suffix(from: 1)))
        )
    }
}

// Terminator AnteDecorator will get added to the chain to simplify decorator code
// Don't need to check if next == nil further up the chain
//                        ______
//                     <((((((\\\
//                     /      . }\
//                     ;--..--._|}
//  (\                 '--/\--'  )
//   \\                | '-'  :'|
//    \\               . -==- .-|
//     \\               \.__.'   \--._
//     [\\          __.--|       //  _/'--.
//     \ \\       .'-._ ('-----'/ __/      \
//      \ \\     /   __>|      | '--.       |
//       \ \\   |   \   |     /    /       /
//        \ '\ /     \  |     |  _/       /
//         \  \       \ |     | /        /
//   snd    \  \      \        /
struct Terminator: AnteDecorator {
    // Simply return provided Context and nil error
    func anteHandle(
        request: Request,
        transaction: Transaction,
        simulate: Bool,
        next: AnteHandler?
    ) throws -> Request {
        request
    }
}
