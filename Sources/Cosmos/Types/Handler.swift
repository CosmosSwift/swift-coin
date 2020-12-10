// Handler defines the core of the state transition function of an application.
public typealias Handler = (_ request: Request, _ message: Message) throws -> Result
