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

public typealias RelayPublisher<Output> = AnyPublisher<Output, Never>
public typealias CurrentValueRelay<Output> = CurrentValueSubject<Output, Never>
public typealias PassthroughRelay<Output> = PassthroughSubject<Output, Never>

/// Stores `Cancellable` instances as one `Cancellable` type.
/// - note: does not gaurantee cancellation on deinit.
public final class CompositeCancellable: Cancellable, ExpressibleByArrayLiteral {
    /// Number of inserted `Cancellable`s.
    public var count: Int {
        lock.lock(); defer { lock.unlock() }
        return values.count
    }

    /// Return `true` if cancel was called.
    public private(set) var isCancelled: Bool = false

    private let lock = NSRecursiveLock()
    private var values: [Cancellable] = []

    public init() {}

    public init(arrayLiteral elements: Cancellable...) {
        values = elements
    }

    /// Stores the `Cancellable` instance to be cancelled with the receiver.
    /// - note: If `isCancelled` is true, will immediately cancel inserted element.
    /// - parameter cancellable: The `Cancellable` to insert into the receiver and be retained.
    /// - returns: The provided instance to optionally still singularly cancel.
    @discardableResult
    public func insert(_ cancellable: Cancellable) -> Cancellable {
        lock.lock(); defer { lock.unlock() }
        guard !isCancelled else {
            cancellable.cancel()
            return cancellable
        }
        values.append(cancellable)
        return cancellable
    }

    /// Cancels all stored `Cancellable`s.
    public func cancel() {
        lock.lock(); defer { lock.unlock() }
        guard !isCancelled else { return }
        isCancelled = true
        values.cancel()
        values = []
    }
}

extension Cancellable {
    /// Stores this` Cancellable` in the specified `CompositeCancellable`.
    /// - parameter compositeCancellable: The `CompositeCancellable` to store in.
    func store(in compositeCancellable: CompositeCancellable) {
        compositeCancellable.insert(self)
    }
}

extension Sequence where Element == Cancellable {
    /// Cancels all stored `Cancellable`s.
    func cancel() {
        for element in self {
            element.cancel()
        }
    }
}

extension Publisher where Failure == Never {
    /// Maps a `Never` to the new `F` failure type.
    public func mapError<F>() -> Publishers.MapError<Self, F> {
        mapError { _ -> F in }
    }
}

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
                             receiveOutput: ((Self.Output) -> Void)? = nil,
                             receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil,
                             receiveFailure: ((Self.Failure) -> Void)? = nil,
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
    public func sink(receiveValue: ((Self.Output) -> Void)? = nil,
                     receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil,
                     receiveFailure: ((Self.Failure) -> Void)? = nil,
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
