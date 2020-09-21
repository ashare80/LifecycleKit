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

@testable import Lifecycle
import XCTest

final class ArrayTests: XCTestCase {
    // MARK: - Tests

    func test_removeAllByReference() {
        let object1 = NSObject()
        let object2 = NSObject()
        let object3 = NSObject()

        var array = [object1, object2]
        XCTAssert(array.count == 2)

        array.removeAllByReference(object1)
        XCTAssert(array.count == 1)

        array.removeAllByReference(object3)
        XCTAssert(array.count == 1)

        array.removeAllByReference(object2)
        XCTAssert(array.isEmpty)
    }
}
