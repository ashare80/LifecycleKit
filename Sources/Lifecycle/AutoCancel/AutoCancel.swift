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
import CombineExtensions
import Foundation

extension Publisher {
    /// Completes when any provided lifecycle states are output, or lifecycle publisher completes.
    public func autoCancel(_ lifecyclePublisher: LifecyclePublisher, when states: LifecycleStateOptions = .notActive) -> RetainedCancellablePublisher<Self> {
        return autoCancel(lifecyclePublisher.lifecycleState, when: states)
    }

    /// Completes when any provided lifecycle states are output, or lifecycle publisher completes.
    public func autoCancel<P: Publisher>(_ lifecycleState: P, when states: LifecycleStateOptions = .notActive) -> RetainedCancellablePublisher<Self> where P.Output == LifecycleState {
        return RetainedCancellablePublisher(source: self, cancelPublisher: lifecycleState.filter(states.contains(state:)).map { _ in () }.replaceError(with: ()).mapError().eraseToAnyPublisher())
    }
}

extension Publisher {
    /// Cancellable will be retained be the sink and must me explicitly cancelled or completed.
    public var retained: RetainedCancellablePublisher<Self> {
        return RetainedCancellablePublisher(source: self, cancelPublisher: nil)
    }
}

public struct RetainedCancellablePublisher<P: Publisher> {
    let source: P
    let cancelPublisher: RelayPublisher<Void>?

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveValue: The closure to execute on receipt of a value. Defaults to `nil`.
    ///   - receiveCompletion: The closure to execute on completion. Defaults to `nil`.
    ///   - receiveFailure: The closure to execute on receipt of a failure. Defaults to `nil`.
    ///   - receiveFinished: The closure to execute on receipt of a finished. Defaults to `nil`.
    ///   - receiveCancel: The closure to execute on receipt of a cancel. Defaults to `nil`.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    @discardableResult
    public func sink(receiveValue: ((P.Output) -> Void)? = nil,
                     receiveCompletion: ((Subscribers.Completion<P.Failure>) -> Void)? = nil,
                     receiveFailure: ((P.Failure) -> Void)? = nil,
                     receiveFinished: (() -> Void)? = nil,
                     receiveCancel: (() -> Void)? = nil) -> Cancellable
    {
        let retainedSink = RetainedCancellableSink(receiveValue: receiveValue,
                                                   receiveCompletion: receiveCompletion,
                                                   receiveFailure: receiveFailure,
                                                   receiveFinished: receiveFinished,
                                                   receiveCancel: receiveCancel,
                                                   cancelPublisher: cancelPublisher)
        source.subscribe(retainedSink)
        return retainedSink
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveValue: The closure to execute on receipt of a value. Defaults to `nil`.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    @discardableResult
    public func sink(_ receiveValue: @escaping (P.Output) -> Void) -> Cancellable {
        return sink(receiveValue: receiveValue)
    }
}

final class RetainedCancellableSink<Input, Failure: Error>: Subscriber, Cancellable {
    public let combineIdentifier: CombineIdentifier = CombineIdentifier()

    private var subscription: Subscription?

    /// Make sure everything is cleared to avoid retain cycles.
    func clear() {
        subscription?.cancel()
        subscription = nil
        cancelPublisherCancellable?.cancel()
        cancelPublisherCancellable = nil
        receiveValue = nil
        receiveCompletion = nil
        receiveFailure = nil
        receiveFinished = nil
        receiveCancel = nil
        cancelPublisher = nil
    }

    private var cancelPublisherCancellable: Cancellable?

    private var receiveValue: ((Input) -> Void)?
    private var receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
    private var receiveFailure: ((Failure) -> Void)?
    private var receiveFinished: (() -> Void)?
    private var receiveCancel: (() -> Void)?
    private var cancelPublisher: RelayPublisher<Void>?

    init(receiveValue: ((Input) -> Void)? = nil,
         receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
         receiveFailure: ((Failure) -> Void)? = nil,
         receiveFinished: (() -> Void)? = nil,
         receiveCancel: (() -> Void)? = nil,
         cancelPublisher: RelayPublisher<Void>? = nil) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
        self.receiveFailure = receiveFailure
        self.receiveFinished = receiveFinished
        self.receiveCancel = receiveCancel
        self.cancelPublisher = cancelPublisher
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription

        cancelPublisherCancellable = cancelPublisher?.sink(receiveValue: cancel,
                                                           receiveFinished: cancel)

        self.subscription?.request(.unlimited)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        receiveValue?(input)
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion?(completion)

        switch completion {
        case let .failure(error):
            receiveFailure?(error)
        case .finished:
            receiveFinished?()
        }

        clear()
    }

    func cancel() {
        guard subscription != nil else {
            clear()
            return
        }
        receiveCancel?()
        clear()
    }
}
