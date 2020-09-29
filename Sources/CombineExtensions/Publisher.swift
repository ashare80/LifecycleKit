//
//  Copyright (c) 2020. Adam Share
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Combine
import Foundation

extension Publisher {
    /// Performs the specified closures when publisher events occur.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure that executes when the publisher receives the  subscription from the upstream publisher. Defaults to `nil`.
    ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher. Defaults to `nil`.
    ///   - receiveCompletion: A closure that executes when the publisher receives the completion from the upstream publisher. Defaults to `nil`.
    ///   - receiveCancel: A closure that executes when the downstream receiver cancels publishing. Defaults to `nil`.
    ///   - receiveRequest: A closure that executes when the publisher receives a request for more elements. Defaults to `nil`.
    /// - Returns: A publisher that performs the specified closures when publisher events occur.
    public func handleEvents(receiveSubscription: ((Subscription) -> Void)? = nil,
                             receiveOutput: ((Output) -> Void)? = nil,
                             receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
                             receiveFailure: ((Failure) -> Void)? = nil,
                             receiveFinished: (() -> Void)? = nil,
                             receiveCancel: (() -> Void)? = nil,
                             receiveRequest: ((Subscribers.Demand) -> Void)? = nil) -> Publishers.HandleEvents<Self>
    {
        handleEvents(receiveSubscription: receiveSubscription,
                     receiveOutput: receiveOutput,
                     receiveCompletion: { completion in
                         receiveCompletion?(completion)
                         switch completion {
                         case let .failure(error):
                             receiveFailure?(error)
                         case .finished:
                             receiveFinished?()
                         }
                     },
                     receiveCancel: receiveCancel,
                     receiveRequest: receiveRequest)
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveValue: The closure to execute on receipt of a value. Defaults to `nil`.
    ///   - receiveCompletion: The closure to execute on completion. Defaults to `nil`.
    ///   - receiveFailure: The closure to execute on receipt of a failure. Defaults to `nil`.
    ///   - receiveFinished: The closure to execute on receipt of a finished. Defaults to `nil`.
    ///   - receiveCancel: The closure to execute on receipt of a cancel. Defaults to `nil`.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveValue: ((Output) -> Void)? = nil,
                     receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
                     receiveFailure: ((Failure) -> Void)? = nil,
                     receiveFinished: (() -> Void)? = nil,
                     receiveCancel: (() -> Void)? = nil) -> AnyCancellable
    {
        let cancellable: AnyCancellable = sink(receiveCompletion: { completion in
            receiveCompletion?(completion)
            switch completion {
            case let .failure(error):
                receiveFailure?(error)
            case .finished:
                receiveFinished?()
            }
        }, receiveValue: { value in
            receiveValue?(value)
        })

        guard let receiveCancel = receiveCancel else {
            return cancellable
        }

        return AnyCancellable {
            cancellable.cancel()
            receiveCancel()
        }
    }
}

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

extension Publisher where Output: OptionalType {
    public func filterNil() -> Publishers.SwitchToLatest<AnyPublisher<Output.Wrapped, Failure>, Publishers.Map<Self, AnyPublisher<Output.Wrapped, Failure>>> {
        return map { (output) -> AnyPublisher<Output.Wrapped, Failure> in
            if let output = output.value {
                return Just(output).mapError().eraseToAnyPublisher()
            } else {
                return Empty().eraseToAnyPublisher()
            }
        }
        .switchToLatest()
    }
}
