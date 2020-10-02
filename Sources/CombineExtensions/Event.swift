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

extension Subscribers {
    /// Represents a sequence event.
    public enum Event<Input, Failure: Error>: CustomDebugStringConvertible {
        /// Subscriber receives input.
        case value(Input)

        /// Sequence completed with an error.
        case error(Failure)

        /// Sequence completed successfully.
        case finished

        public init(_ value: Input) {
            self = .value(value)
        }

        public init(_ completion: Subscribers.Completion<Failure>) {
            switch completion {
            case let .failure(error):
                self = .error(error)
            case .finished:
                self = .finished
            }
        }

        /// Description of event.
        public var debugDescription: String {
            switch self {
            case let .value(value):
                return "send(\(value))"
            case let .error(error):
                return "error(\(error))"
            case .finished:
                return "finished"
            }
        }

        /// Is `finished` or `error` event.
        public var isCompletionEvent: Bool {
            switch self {
            case .value: return false
            case .error, .finished: return true
            }
        }

        /// If `next` event, returns element value.
        public var value: Input? {
            if case let .value(value) = self {
                return value
            }
            return nil
        }

        /// If `error` event, returns error.
        public var error: Swift.Error? {
            if case let .error(error) = self {
                return error
            }
            return nil
        }

        /// If `finished` event, returns `true`.
        public var isFinished: Bool {
            if case .finished = self {
                return true
            }
            return false
        }
    }
}

extension Subscribers.Event: Equatable where Input: Equatable, Failure: Equatable {}

extension Publisher {

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// - Parameters:
    ///   - receiveEvent: The closure to execute on receipt of an event.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveEvent: @escaping (Subscribers.Event<Output, Failure>) -> Void) -> AnyCancellable {
        return sink(receiveCompletion: { completion in
            receiveEvent(Subscribers.Event(completion))
        }, receiveValue: { value in
            receiveEvent(Subscribers.Event(value))
        })
    }
}
