//
//  File.swift
//  
//
//  Created by Adam Share on 9/8/20.
//

import Foundation
import Combine

//public final class CompositeCancellable: Cancellable {
//    public var count: Int {
//        lock.lock(); defer { lock.unlock() }
//        return values.count
//    }
//    
//    private(set) var cancelled: Bool = false
//
//    private let lock: NSRecursiveLock = NSRecursiveLock()
//    private var values: [Cancellable] = []
//
//    public func insert(_ cancellable: Cancellable) {
//        lock.lock(); defer { lock.unlock() }
//        guard !cancelled else {
//            cancellable.cancel()
//            return
//        }
//        values.append(cancellable)
//    }
//
//    public func cancel() {
//        lock.lock(); defer { lock.unlock() }
//        guard !cancelled else { return }
//        cancelled = true
//        values.cancel()
//    }
//}
//
//extension Sequence where Element == Cancellable {
//    func cancel() {
//        for element in self {
//            element.cancel()
//        }
//    }
//}
//
//extension Publisher where Failure == Never {
//    public func mapError<F>() -> Publishers.MapError<Self, F> {
//        mapError { _ -> F in }
//    }
//}
//
//extension Publisher {
//
//    /// Performs the specified closures when publisher events occur.
//    ///
//    /// - Parameters:
//    ///   - receiveSubscription: A closure that executes when the publisher receives the  subscription from the upstream publisher. Defaults to `nil`.
//    ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher. Defaults to `nil`.
//    ///   - receiveCompletion: A closure that executes when the publisher receives the completion from the upstream publisher. Defaults to `nil`.
//    ///   - receiveCancel: A closure that executes when the downstream receiver cancels publishing. Defaults to `nil`.
//    ///   - receiveRequest: A closure that executes when the publisher receives a request for more elements. Defaults to `nil`.
//    /// - Returns: A publisher that performs the specified closures when publisher events occur.
//    public func handleEvents(receiveSubscription: ((Subscription) -> Void)? = nil,
//                             receiveOutput: ((Self.Output) -> Void)? = nil,
//                             receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil,
//                             receiveFailure: ((Self.Failure) -> Void)? = nil,
//                             receiveFinished: (() -> Void)? = nil,
//                             receiveCancel: (() -> Void)? = nil,
//                             receiveRequest: ((Subscribers.Demand) -> Void)? = nil) -> Publishers.HandleEvents<Self> {
//        return handleEvents(receiveSubscription: receiveSubscription,
//                            receiveOutput: receiveOutput,
//                            receiveCompletion: { (completion) in
//                                receiveCompletion?(completion)
//                                switch completion {
//                                case let .failure(error):
//                                    receiveFailure?(error)
//                                case .finished:
//                                    receiveFinished?()
//                                }
//        },
//                            receiveCancel: receiveCancel,
//                            receiveRequest: receiveRequest)
//    }
//
//    /// Attaches a subscriber with closure-based behavior.
//    ///
//    /// - Parameters:
//    ///   - receiveValue: The closure to execute on receipt of a value. Defaults to `nil`.
//    ///   - receiveCompletion: The closure to execute on completion. Defaults to `nil`.
//    ///   - receiveFailure: The closure to execute on receipt of a failure. Defaults to `nil`.
//    ///   - receiveFinished: The closure to execute on receipt of a finished. Defaults to `nil`.
//    ///   - receiveCancel: The closure to execute on receipt of a cancel. Defaults to `nil`.
//    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
//    public func sink(receiveValue: ((Self.Output) -> Void)? = nil,
//                     receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil,
//                     receiveFailure: ((Self.Failure) -> Void)? = nil,
//                     receiveFinished: (() -> Void)? = nil,
//                     receiveCancel: (() -> Void)? = nil) -> AnyCancellable {
//        let cancellable = sink(receiveCompletion: { (completion) in
//            receiveCompletion?(completion)
//            switch completion {
//            case let .failure(error):
//                receiveFailure?(error)
//            case .finished:
//                receiveFinished?()
//            }
//        }, receiveValue: { (value) in
//            receiveValue?(value)
//        })
//
//        return AnyCancellable {
//            cancellable.cancel()
//            receiveCancel?()
//        }
//    }
//}
