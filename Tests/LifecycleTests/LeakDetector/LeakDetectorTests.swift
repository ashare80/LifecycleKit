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

import CombineExtensions
import Foundation
@testable import Lifecycle
import XCTest

final class LeakDetectorTests: XCTestCase {

    override func tearDown() {
        super.tearDown()

        LeakDetector.instance.reset()
    }

    func testExpectDealloc() {
        weak var object: AnyObject?
        autoreleasepool {
            let testObject = TestNSObject()
            object = testObject

            expectAssertionFailure(timeout: 2.0) {
                LeakDetector.instance.expectDeallocate(object: testObject).retained.sink()
                XCTAssertTrue(LeakDetector.instance.trackingObjects.asArray.first === object)
            }

            LeakDetector.instance.expectDeallocate(object: testObject, inTime: 0.0).retained.sink()
            XCTAssertTrue(LeakDetector.instance.trackingObjects.asArray.first === object)
        }

        XCTAssertEqual(LeakDetector.instance.expectationCount, 1)
        XCTAssertTrue(LeakDetector.instance.trackingObjects.asArray.isEmpty)
        XCTAssertNil(object)

        let e = expectation(description: "Still expectations in leak detector")

        asyncMain(delay: 0.5) {
            XCTAssertEqual(LeakDetector.instance.expectationCount, 0)
            e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func testExpectObjectsDealloc() {
        var objects: WeakSet<TestObject> = []
        autoreleasepool {
            let testObjects = [TestObject(), TestObject(), TestObject()]
            objects = WeakSet(testObjects)

            expectAssertionFailure(timeout: 2.0) {
                LeakDetector.instance.expectDeallocate(objects: objects).retained.sink()
                XCTAssertEqual(LeakDetector.instance.trackingObjects.count, 3)
            }

            LeakDetector.instance.expectDeallocate(objects: objects, inTime: 0.0).retained.sink()
            XCTAssertEqual(LeakDetector.instance.trackingObjects.count, 3)
            XCTAssertEqual(objects.count, 3)
            XCTAssertEqual(testObjects.count, 3)
        }

        XCTAssertEqual(LeakDetector.instance.expectationCount, 1)
        XCTAssertTrue(LeakDetector.instance.trackingObjects.asArray.isEmpty)
        XCTAssertEqual(objects.count, 0)

        let e = expectation(description: "Still expectations in leak detector")

        asyncMain(delay: 0.5) {
            XCTAssertEqual(LeakDetector.instance.expectationCount, 0)
            e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func testViewDisappear() {
        let viewLifecycleOwner = TestViewLifecycleOwner()
        viewLifecycleOwner.viewLifecycle.viewDidLoad(with: viewLifecycleOwner)
        viewLifecycleOwner.viewLifecycle.isDisplayed = true

        expectAssertionFailure(timeout: 2.0) {
            LeakDetector.instance.expectViewDisappear(tracker: viewLifecycleOwner.viewLifecycle, inTime: 1.0).retained.sink()
            XCTAssertTrue(LeakDetector.instance.trackingObjects.isEmpty)
        }

        LeakDetector.instance.expectViewDisappear(tracker: viewLifecycleOwner.viewLifecycle, inTime: 1.0).retained.sink()
        viewLifecycleOwner.viewLifecycle.isDisplayed = false
        XCTAssertTrue(LeakDetector.instance.trackingObjects.isEmpty)
    }
}

final class TestObject {}
final class TestNSObject: NSObject {}
