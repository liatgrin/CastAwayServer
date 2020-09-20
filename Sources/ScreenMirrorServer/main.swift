import PerfectLib
import PerfectHTTP
import PerfectWebSockets
import PerfectHTTPServer

do {
    // Launch the HTTP server on port 8181
    try HTTPServer.launch(name: "websockets server",
                          port: 8181,
                          routes: makeRoutes(),
                          responseFilters: [(try HTTPFilter.contentCompression(data: [:]), .high)])
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

func makeRoutes() -> Routes {

    var routes = Routes()
    // Add a default route which lets us serve the static index.html file
    routes.add(method: .get, uri: "*", handler: { request, response in
        StaticFileHandler(documentRoot: ".").handleRequest(request: request, response: response)
    })

    // Add the endpoint for the WebSocket example system
    routes.add(method: .get, uri: "/signal", handler: {
        request, response in

        // To add a WebSocket service, set the handler to WebSocketHandler.
        // Provide your closure which will return your service handler.
        WebSocketHandler(handlerProducer: {
            (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in

            // Check to make sure the client is requesting our "echo" service.
//            guard protocols.contains("echo") else {
//                return nil
//            }
            print("initialized signaling handler")
            return SignalingHandler()
        }).handleRequest(request: request, response: response)
    })

    return routes
}
