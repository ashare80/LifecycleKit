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
