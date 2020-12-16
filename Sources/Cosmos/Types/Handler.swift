// Handler defines the core of the state transition function of an application.
public typealias Handler = (_ request: Request, _ message: Message) throws -> Result

// AnteHandler authenticates transactions, before their internal messages are handled.
// If newCtx.IsZero(), ctx is used instead.
public typealias AnteHandler = (_ request: Request, _ transaction: Transaction, _ simulate: Bool) throws -> Request

