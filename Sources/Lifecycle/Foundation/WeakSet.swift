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

/// Set of weakly referenced objects.
/// - warning: Element must conform to `AnyObject`.
public struct WeakSet<Element>: ExpressibleByArrayLiteral, CustomDebugStringConvertible {
    /// Returns an array with a strong reference to elements.
    public var asArray: [Element] {
        storage.dictionaryRepresentation().values.compactMap { $0 as? Element }
    }

    public var isEmpty: Bool {
        return count == 0
    }

    /// The number of elements in the set.
    public var count: Int {
        asArray.count
    }

    private var storage: NSMapTable<NSString, AnyObject> = .strongToWeakObjects()

    public init(arrayLiteral elements: Element...) {
        for element in elements {
            insertToStorage(object: element as AnyObject)
        }
    }

    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            insertToStorage(object: element as AnyObject)
        }
    }

    /// `True` if element is contained in the set.
    /// - parameter element: `Element` to compare.
    /// - parameter element: Returns
    public func contains(_ element: Element) -> Bool {
        storage.object(forKey: fromattedMemoryString(for: element as AnyObject) as NSString) != nil
    }

    public mutating func formUnion<T>(_ other: WeakSet<T>) {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy()
        }

        guard let enumerator = other.storage.objectEnumerator() else { return }
        while let element = enumerator.nextObject() {
            insertToStorage(object: element as AnyObject)
        }
    }

    public mutating func insert(_ element: Element) {
        objc_sync_enter(storage); defer { objc_sync_exit(storage) }
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy()
        }
        insertToStorage(object: element as AnyObject)
    }

    private func insertToStorage(object: AnyObject) {
        storage.setObject(object, forKey: fromattedMemoryString(for: object) as NSString)
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
        storage.removeObject(forKey: fromattedMemoryString(for: element as AnyObject) as NSString)
    }

    private func storageCopy() -> NSMapTable<NSString, AnyObject> {
        storage.copy() as? NSMapTable<NSString, AnyObject> ?? .strongToWeakObjects()
    }

    public var debugDescription: String {
        var description = "["
        let enumerator = storage.keyEnumerator()
        var nextSpacer = ""
        while let key = enumerator.nextObject() as? NSString {
            if let object = storage.object(forKey: key) {
                description += nextSpacer + "<\(object): \(key)>"
                nextSpacer = ", "
            }
        }
        return description + "]"
    }
}

func fromattedMemoryString(for object: AnyObject) -> String {
    return String(format: "%018p", unsafeBitCast(object, to: Int.self))
}
