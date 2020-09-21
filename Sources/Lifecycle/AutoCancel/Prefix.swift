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

extension Publishers {
    public struct PrefixUntilOutputOptions: OptionSet {
        public static let output: PrefixUntilOutputOptions = .init(rawValue: 1 << 0)
        public static let failure: PrefixUntilOutputOptions = .init(rawValue: 1 << 1)
        public static let finish: PrefixUntilOutputOptions = .init(rawValue: 1 << 2)
        public static let completion: PrefixUntilOutputOptions = [.finish, .failure]
        public static let all: PrefixUntilOutputOptions = [.output, .finish, .failure]

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public func contains<Output, Failure: Error>(_ event: Subscribers.Event<Output, Failure>) -> Bool {
            return contains(event.asPrefixOption)
        }
    }
}

extension Subscribers {
    public enum Event<Output, Failure: Error> {
        /// Next output is produced.
        case output(Output)

        /// Publisher completed with an error.
        case failure(Failure)

        /// Publisher finished successfully.
        case finish

        fileprivate var asPrefixOption: Publishers.PrefixUntilOutputOptions {
            switch self {
            case .output: return .output
            case .failure: return .failure
            case .finish: return .finish
            }
        }

        init(_ completion: Completion<Failure>) {
            switch completion {
            case let .failure(error):
                self = .failure(error)
            case .finished:
                self = .finish
            }
        }
    }
}

extension Publisher {
    /// Maps output and completion into `Event`s that can be handled as `Output` be a `Prefix` operator or recorded.
    /// - note: Stream will complete with `finish` after either`Event.failure` or `Event.finish`.
    public var events: RelayPublisher<Subscribers.Event<Output, Failure>> {
        return Deferred<RelayPublisher<Subscribers.Event<Output, Failure>>> {
            let subject = PassthroughRelay<Subscribers.Event<Self.Output, Self.Failure>>()

            return self.handleEvents(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    subject.send(.finish)
                default:
                    break
                }
                subject.send(completion: .finished)
            })
                .map { value in .output(value) }
                .eraseToAnyPublisher()
                .catch { error in Just(.failure(error)) }
                .eraseToAnyPublisher()
                .map { value in subject.prepend(value) }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Republishes elements until another publisher emits a finishing output.
    ///
    /// After the second publisher publishes an event matching provided options, the publisher returned by this method finishes.
    ///
    /// - Parameter publisher: A second publisher.
    /// - Parameter options: Which events will cause the publiser returned to finish.
    /// - Returns: A publisher that republishes elements until the second publisher publishes specified output from options.
    public func prefix<P: Publisher>(untilOutputFrom publisher: P, options: Publishers.PrefixUntilOutputOptions) -> AnyPublisher<Output, Failure> {
        guard options != .output else {
            return prefix(untilOutputFrom: publisher).eraseToAnyPublisher()
        }

        return prefix(untilOutputFrom: publisher
            .events
            .filter(options.contains)
            .handleEvents(receiveOutput: { output in
                Swift.print(String(describing: output))
            }, receiveCompletion: { complete in
                Swift.print(String(describing: complete))
            })
        ).eraseToAnyPublisher()
    }
}
