//
//  Copyright (c) 2021. Adam Share
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

public extension Publisher {
    /// Performs the specified closures when publisher events occur.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure that executes when the publisher receives the  subscription from the upstream publisher. Defaults to `nil`.
    ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher. Defaults to `nil`.
    ///   - receiveCompletion: A closure that executes when the publisher receives the completion from the upstream publisher. Defaults to `nil`.
    ///   - receiveCancel: A closure that executes when the downstream receiver cancels publishing. Defaults to `nil`.
    ///   - receiveRequest: A closure that executes when the publisher receives a request for more elements. Defaults to `nil`.
    /// - Returns: A publisher that performs the specified closures when publisher events occur.
    func handleEvents(receiveSubscription: ((Subscription) -> Void)? = nil,
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
    ///   - receiveCancel: The closure to execute on receipt of a cancel.
    ///   - receiveCompletion: The closure to execute on completion.
    ///   - receiveFailure: The closure to execute on receipt of a failure.
    ///   - receiveFinished: The closure to execute on receipt of a finished.
    ///   - receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func sink(receiveCancel: @escaping () -> Void,
              receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void = { _ in },
              receiveFailure: @escaping (Failure) -> Void = { _ in },
              receiveFinished: @escaping () -> Void = {},
              receiveValue: @escaping (Output) -> Void = { _ in }) -> AnyCancellable
    {
        var isCompleted: Bool = false
        let cancellable: AnyCancellable = sink(receiveCompletion: { completion in
            isCompleted = true
            receiveCompletion(completion)
            switch completion {
            case let .failure(error):
                receiveFailure(error)
            case .finished:
                receiveFinished()
            }
        }, receiveValue: { value in
            receiveValue(value)
        })

        return AnyCancellable {
            cancellable.cancel()
            if !isCompleted {
                receiveCancel()
            }
        }
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveCompletion: The closure to execute on completion.
    ///   - receiveFailure: The closure to execute on receipt of a failure.
    ///   - receiveFinished: The closure to execute on receipt of a finished.
    ///   - receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func sink(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void = { _ in },
              receiveFailure: @escaping (Failure) -> Void,
              receiveFinished: @escaping () -> Void = {},
              receiveValue: @escaping (Output) -> Void = { _ in }) -> AnyCancellable
    {
        return sink(receiveCompletion: { completion in
            receiveCompletion(completion)
            switch completion {
            case let .failure(error):
                receiveFailure(error)
            case .finished:
                receiveFinished()
            }
        }, receiveValue: { value in
            receiveValue(value)
        })
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveCompletion: The closure to execute on completion.
    ///   - receiveFailure: The closure to execute on receipt of a failure.
    ///   - receiveFinished: The closure to execute on receipt of a finished.
    ///   - receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func sink(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void = { _ in },
              receiveFinished: @escaping () -> Void,
              receiveValue: @escaping (Output) -> Void = { _ in }) -> AnyCancellable
    {
        return sink(receiveCompletion: receiveCompletion,
                    receiveFailure: { _ in },
                    receiveFinished: receiveFinished,
                    receiveValue: receiveValue)
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveCompletion: The closure to execute on completion.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func sink(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) -> AnyCancellable
    {
        return sink(receiveCompletion: receiveCompletion, receiveValue: { _ in })
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveCompletion: The closure to execute on completion.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func sink(receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        return sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveCompletion: The closure to execute on completion.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func sink() -> AnyCancellable {
        return sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
