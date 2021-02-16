// Content defines an interface that a proposal must implement. It contains
// information such as the title and description along with the type and routing
// information for the appropriate handler to process the proposal. Content can
// have additional fields, which will handled by a proposal's Handler.
public protocol Content {
    var title: String { get }
    var description: String { get }
    var proposalRoute: String { get }
    var proposalType: String { get }
    func validateBasic() throws
    var string: String { get }
}
