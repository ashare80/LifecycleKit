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

/// Replays sent values for a given buffer size.
public final class ReplaySubject<Output, Failure: Error>: Subject {
    private var isNotCompleted: Bool {
        return completion == nil
    }

    var subscriptions: Set<Subscription> = []

    private var buffer: [Output] = []
    private let bufferSize: Int
    private var completion: Subscribers.Completion<Failure>?
    private let lock: NSRecursiveLock = NSRecursiveLock()

    /// - parameter bufferSize: Number of values to replay.
    public init(bufferSize: Int = 1) {
        self.bufferSize = Swift.max(bufferSize, 0)
    }

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public func send(_ value: Output) {
        lock.lock(); defer { lock.unlock() }

        guard isNotCompleted else { return }

        if bufferSize > 1 {
            buffer.append(value)
            buffer = buffer.suffix(bufferSize)
        } else if bufferSize == 1 {
            buffer = [value]
        }

        for subscription in subscriptions {
            subscription.receive(value)
        }
    }

    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    public func send(completion: Subscribers.Completion<Failure>) {
        lock.lock(); defer { lock.unlock() }

        guard isNotCompleted else { return }

        self.completion = completion

        let subscriptions = self.subscriptions
        self.subscriptions = []
        for subscription in subscriptions {
            subscription.receive(completion: completion)
        }
    }

    /// Provides this Subject an opportunity to establish demand for any new upstream subscriptions (say via, ```Publisher.subscribe<S: Subject>(_: Subject)`
    public func send(subscription: Combine.Subscription) {
        lock.lock(); defer { lock.unlock() }

        subscription.request(.unlimited)
    }

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure,  Output == S.Input {
        lock.lock(); defer { lock.unlock() }

        let subscription = Subscription(subscriber: subscriber) { [weak self] subscription in
            self?.lock.lock(); defer { self?.lock.unlock() }
            self?.subscriptions.remove(subscription)
        }

        if isNotCompleted {
            subscriptions.insert(subscription)
        }

        subscriber.receive(subscription: subscription)
        subscription.replay(buffer, completion: completion)
    }

    final class Subscription: Combine.Subscription, ObjectIdentifiable {
        private var demand: Subscribers.Demand = .none

        private let subscriber: AnySubscriber<Output, Failure>
        private let onCancel: (Subscription) -> Void

        init<S>(subscriber: S, onCancel: @escaping (Subscription) -> Void) where S: Subscriber, Failure == S.Failure,  Output == S.Input {
            self.subscriber = AnySubscriber(subscriber)
            self.onCancel = onCancel
        }

        // Tells a publisher that it may send more values to the subscriber.
        func request(_ newDemand: Subscribers.Demand) {
            demand += newDemand
        }

        func cancel() {
            onCancel(self)
        }

        func receive(_ value: Output) {
            guard demand > 0 else { return }

            demand += subscriber.receive(value)
            demand -= 1
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            subscriber.receive(completion: completion)
        }

        func replay(_ values: [Output], completion: Subscribers.Completion<Failure>?) {
            for value in values {
                receive(value)
            }

            if let completion = completion {
                receive(completion: completion)
            }
        }
    }
}

public extension Publisher {
    /**
     Returns an publisher sequence that **shares a single subscription to the underlying sequence**, and immediately upon subscription replays  elements in buffer.

     This operator is equivalent to:
     * `.whileConnected`
     ```
     // Each connection will have it's own subject instance to store replay events.
     // Connections will be isolated from each another.
     source.multicast(makeSubject: { ReplaySubject(bufferSize: replay) }).autoconnect()
     ```
     * `.forever`
     ```
     // One subject will store replay events for all connections to source.
     // Connections won't be isolated from each another.
     source.multicast(ReplaySubject(bufferSize: replay)).autoconnect()
     ```

     It uses optimized versions of the operators for most common operations.
     - parameter replay: Maximum element count of the replay buffer.
     - parameter scope: Lifetime scope of sharing subject. For more information see `SubjectLifetimeScope` enum.
     - returns: A publisher sequence that contains the elements of a sequence produced by multicasting the source sequence.
     */

    /// Provides a subject that shares a single subscription to the upstream publisher and replays at most `bufferSize` items emitted by that publisher
    /// - Parameter bufferSize: limits the number of items that can be replayed
    func share(replay: Int, scope: Publishers.SubjectLifetimeScope = .whileConnected) -> AnyPublisher<Output, Failure> {

        switch scope {
        case .whileConnected:
            return multicast {
                ReplaySubject(bufferSize: replay)
            }
            .autoconnect()
            .eraseToAnyPublisher()
        case .forever:
            if replay <= 0  {
                return share()
                    .eraseToAnyPublisher()
            }

            return multicast(subject: ReplaySubject(bufferSize: replay))
                .autoconnect()
                .eraseToAnyPublisher()
        }
    }
}

public extension Publishers {
    /// Subject lifetime scope
    enum SubjectLifetimeScope {
        /**
         **Each connection will have it's own subject instance to store replay events.**
         **Connections will be isolated from each another.**
         Configures the underlying implementation to behave equivalent to.

         ```
         source.multicast(subject: { MySubject() }).autoconnect()
         ```
         **This is the recommended default.**
         This has the following consequences:
         * `retry` or `concat` operators will function as expected because terminating the sequence will clear internal state.
         * Each connection to source publisher sequence will use it's own subject.
         * When the number of subscribers drops from 1 to 0 and connection to source sequence is disposed, subject will be cleared.
         */
        case whileConnected

        /**
          **One subject will store replay events for all connections to source.**
          **Connections won't be isolated from each another.**
          Configures the underlying implementation behave equivalent to.
          ```
          source.multicast(MySubject()).refCount()
          ```

          This has the following consequences:
          * Using `retry` or `concat` operators after this operator usually isn't advised.
          * Each connection to source publisher sequence will share the same subject.
          * After number of subscribers drops from 1 to 0 and connection to source publisher sequence is dispose, this operator will
            continue holding a reference to the same subject.
            If at some later moment a new observer initiates a new connection to source it can potentially receive
            some of the stale events received during previous connection.
          * After source sequence terminates any new observer will always immediately receive replayed elements and terminal event.
            No new subscriptions to source publisher sequence will be attempted.
         */
        case forever
    }
}
