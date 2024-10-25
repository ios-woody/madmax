//
//  WebSocketClient.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/4/24.
//

import Foundation

enum WebSocketError: Error {
    case invalidURL
}
enum State {
    case notConnected
    case connected
    case disconnected
}

final actor WebSocketController: NSObject {

    var url: URL? = URL(string: "wss://ws.bitmex.com/realtime")

    weak var orderData: OrderData?
    weak var delegate: URLSessionWebSocketDelegate?

    private var webSocketTask: URLSessionWebSocketTask? {
        didSet { oldValue?.cancel(with: .goingAway, reason: nil) }
    }

    private var state: State = .notConnected

    init(orderData: OrderData) {
        self.orderData = orderData
    }
    func connect() async throws {
        guard state == .notConnected else { return }

        try openWebSocket()

        let request = Request(op: "subscribe", args: ["orderBookL2_25:XBTUSD"])
        guard let requestData = try? JSONEncoder().encode(request),
              let requestString = String(data: requestData, encoding: .utf8)
        else { return }

        send(message: requestString)
        receive { [orderData] string, data in
            Task {
                let string = String(string?.prefix(100) ?? "")
                await orderData?.storeData(string: string)
            }
            //  OrderData 처리
        }
    }

    func openWebSocket() throws {
        guard let url = url else { throw WebSocketError.invalidURL }

        let urlSession = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        let webSocketTask = urlSession.webSocketTask(with: url)

        webSocketTask.resume()

        self.webSocketTask = webSocketTask
    }
    
    func send(message: String) {
        self.send(message: message, data: nil)
    }

    private func send(message: String?, data: Data?) {
        let taskMessage: URLSessionWebSocketTask.Message
        if let string = message {
            taskMessage = URLSessionWebSocketTask.Message.string(string)
        } else if let data = data {
            taskMessage = URLSessionWebSocketTask.Message.data(data)
        } else {
            return
        }
        self.webSocketTask?.send(taskMessage, completionHandler: { error in
            guard let error = error else { return }
            print("WebSOcket sending error: \(error)")
        })
    }
    
    func closeWebSocket() {
        self.webSocketTask = nil
        self.delegate = nil
    }

//    func receive() async -> (String?, Data?) {
//        return await withCheckedContinuation { continuation in
//            webSocketTask?.receive(completionHandler: { result in
//                switch result {
//                case let .success(message):
//                    switch message {
//                    case let .string(string):
//                        continuation.resume(returning: (string, nil))
//                    case let .data(data):
//                        continuation.resume(returning: (nil, data))
//                    @unknown default:
//                        continuation.resume(returning: (nil, nil))
//                    }
//                case let .failure(error):
//                    continuation.resume(returning: (nil, nil))
//                }
//            })
//        }
//
//    }

    func receive(onReceive: @escaping (String?, Data?) -> ())  {
        self.webSocketTask?.receive(completionHandler: { result in
            switch result {
            case let .success(message):
                switch message {
                case let .string(string):
                    onReceive(string, nil)
                case let .data(data):
                    onReceive(nil, data)
                @unknown default:
                    onReceive(nil, nil)
                }
                self.receive(onReceive: onReceive)
            case let .failure(error):
                print("Received error \(error)")
            }
        })
    }
}

extension WebSocketController: URLSessionWebSocketDelegate {
//    func urlSession(
//        _ session: URLSession,
//        webSocketTask: URLSessionWebSocketTask,
//        didOpenWithProtocol protocol: String?
//    ) {
//        print("Did connect to socket")
//
//        self.state = .connected
//
//        self.delegate?.urlSession?(
//            session,
//            webSocketTask: webSocketTask,
//            didOpenWithProtocol: `protocol`
//        )
//    }
//    
//    func urlSession(
//        _ session: URLSession,
//        webSocketTask: URLSessionWebSocketTask,
//        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
//        reason: Data?
//    ) {
//        print("Did close connection with reason")
//        self.delegate?.urlSession?(
//            session,
//            webSocketTask: webSocketTask,
//            didCloseWith: closeCode,
//            reason: reason
//        )
//    }
}
