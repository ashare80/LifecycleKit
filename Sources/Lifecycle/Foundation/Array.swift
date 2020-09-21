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
