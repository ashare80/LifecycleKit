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

import Foundation

/// Array extensions.
public extension Array {
    /// Remove the given element from this array, by comparing pointer references.
    ///
    /// - parameter element: The element to remove.
    @discardableResult
    mutating func removeAllByReference(_ element: Element) -> Bool {
        var removed: Bool = false
        removeAll { member -> Bool in
            let willRemove = (member as AnyObject === element as AnyObject)
            if willRemove {
                removed = true
            }
            return willRemove
        }
        return removed
    }
}

/// Set of weakly referenced objects.
/// - warning: Element must conform to `AnyObject`.
public struct WeakSet<Element> {
    /// Returns an array with a strong reference to elements.
    public var asArray: [Element] {
        storage.dictionaryRepresentation().values.compactMap { $0 as? Element }
    }

    public var isEmpty: Bool {
        return count == 0
    }

    /// The number of elements in the set.
    public var count: Int {
        storage.count
    }

    private var storage: NSMapTable<NSNumber, AnyObject> = .strongToWeakObjects()

    /// `True` if element is contained in the set.
    /// - parameter element: `Element` to compare.
    /// - parameter element: Returns
    public func contains(_ element: Element) -> Bool {
        storage.object(forKey: NSNumber(value: ObjectIdentifier(element as AnyObject).hashValue)) != nil
    }

    public mutating func insert(_ element: Element) {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy()
        }
        let object = element as AnyObject
        self.storage.setObject(object, forKey: NSNumber(value: ObjectIdentifier(object).hashValue))
    }

    public mutating func removeAll() {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        storage = .strongToWeakObjects()
    }

    public mutating func remove(_ element: Element) {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy()
        }
        storage.removeObject(forKey: NSNumber(value: ObjectIdentifier(element as AnyObject).hashValue))
    }

    private func storageCopy() -> NSMapTable<NSNumber, AnyObject> {
        storage.copy() as? NSMapTable<NSNumber, AnyObject> ?? .strongToWeakObjects()
    }
}

#if DEBUG
    func assertionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        assertionFailureClosure(message(), file, line)
    }

    var assertionFailureClosure: (String, StaticString, UInt) -> Void = defaultAssertionFailureClosure
    let defaultAssertionFailureClosure = { Swift.assertionFailure($0, file: $1, line: $2) }
#endif
