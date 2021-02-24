import Foundation
import AsyncHTTPClient
import NIO
import ABCIMessages
import ABCIREST

#warning("This should be rewritten to have async send instead, and possibly pushed to the swift-abci repo")
public struct ABCIRESTClient<Payload: RequestPayload> {
    
    var url: String
    let threads: Int
    
    public init(url: String, threads: Int = 1) {
        self.url = url
        self.threads = threads
    }
    
    public func syncSend(payload: Payload) throws -> ResponseResult<Payload> {
        
        // Setup an `EventLoopGroup` for the connection to run on.
        //
        // See: https://github.com/apple/swift-nio#eventloops-and-eventloopgroups
        let group = MultiThreadedEventLoopGroup(numberOfThreads: threads)
        
        // Make sure the group is shutdown when we're done with it.
        defer {
            try! group.syncShutdownGracefully()
        }
        
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(group))
        
        defer {
            try! httpClient.syncShutdown()
        }
        var request = try HTTPClient.Request(url: url, method: .POST)
        
        request.headers.add(name: "User-Agent", value: ABCI_REST.httpClientType)
        request.headers.add(name: "Content-Type", value: "text/json")

        let query = RequestQuery(payload: payload, height: 0, prove: true)
        
        
        let restRequest = RESTRequest<Payload>(request: query, id: 10) // TODO: implement height, prove, id
        
        guard let data = try? JSONEncoder().encode(restRequest) else {
            throw RESTRequestError.badRequest
        }
        let bodyStr = String(data: data, encoding: .utf8) ?? ""
        print(bodyStr)
        request.body = .string(bodyStr)
        
        let responseData = try httpClient.execute(request: request).wait()
        
        guard let buffer = responseData.body else {
            throw RESTRequestError.badResponse
        }
        
        let response = try JSONDecoder().decode(RESTResponse<Payload>.self, from: Data(buffer: buffer))
        
        return response.result
    }
}

