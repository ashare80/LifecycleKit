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
    public func autoCancel(_ lifecycleProvider: LifecycleProvider, when states: LifecycleStateOptions = .notActive) -> RetainedCancellablePublisher<AnyPublisher<Output, Failure>> {
        return autoCancel(lifecycleProvider.lifecyclePublisher, when: states)
    }

    /// Completes when any provided lifecycle states are output, or lifecycle publisher completes.
    public func autoCancel<P: Publisher>(_ lifecyclePublisher: P, when states: LifecycleStateOptions = .notActive) -> RetainedCancellablePublisher<AnyPublisher<Output, Failure>> where P.Output == LifecycleState {
        return prefix(untilOutputFrom: lifecyclePublisher.filter(states.contains(state:)), options: .all).retained
    }
}

extension Publisher {
    /// Cancellable will be retained be the sink and must me explicitly cancelled or completed.
    public var retained: RetainedCancellablePublisher<Self> {
        return RetainedCancellablePublisher(self)
    }
}

public struct RetainedCancellablePublisher<P: Publisher> {
    private let source: P

    fileprivate init(_ source: P) {
        self.source = source
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
    @discardableResult
    public func sink(receiveValue: ((P.Output) -> Void)? = nil,
                     receiveCompletion: ((Subscribers.Completion<P.Failure>) -> Void)? = nil,
                     receiveFailure: ((P.Failure) -> Void)? = nil,
                     receiveFinished: (() -> Void)? = nil,
                     receiveCancel: (() -> Void)? = nil) -> Cancellable
    {
        var retained: CompositeCancellable? = CompositeCancellable()
        var completed: Bool = false

        let cancellable: AnyCancellable = source
            .sink(receiveCompletion: { completion in
                receiveCompletion?(completion)
                switch completion {
                case let .failure(error):
                    receiveFailure?(error)
                case .finished:
                    receiveFinished?()
                }
                completed = true
                retained = nil
            }, receiveValue: { value in
                receiveValue?(value)
            })

        var storedCancellable = cancellable

        if let receiveCancel = receiveCancel {
            storedCancellable = AnyCancellable {
                cancellable.cancel()
                if !completed {
                    receiveCancel()
                }
            }
        }

        if let compositeCancellable = retained {
            compositeCancellable.insert(storedCancellable)
            return compositeCancellable
        } else {
            return storedCancellable
        }
    }
}
