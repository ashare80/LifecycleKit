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
@testable import Lifecycle
import XCTest

final class AutoCancelTests: XCTestCase {

    func test_cleanupOnInactive() {
        let publisher = PassthroughSubject<Void, Never>()

        weak var weakObject: TestObject?
        weak var weakCancellable: AnyObject?

        var receiveValueCount = 0
        var receiveCompletionCount = 0
        var receiveCancelCount = 0

        autoreleasepool {
            let object = TestObject()
            weakObject = object
            let lifecycle = PassthroughSubject<LifecycleState, Never>()

            weakCancellable = publisher
                .autoCancel(lifecycle)
                .sink(receiveValue: {
                    receiveValueCount += 1
                    XCTAssertNotNil(object)
                }, receiveCompletion: { _ in
                    receiveCompletionCount += 1
                }, receiveCancel: {
                    receiveCancelCount += 1
                }) as AnyObject

            publisher.send()

            XCTAssertNotNil(weakCancellable)
            lifecycle.send(.inactive)
            XCTAssertNil(weakCancellable)

            publisher.send()
        }

        publisher.send()

        XCTAssertNil(weakCancellable)
        XCTAssertNil(weakObject)
        XCTAssertEqual(receiveValueCount, 1)
        XCTAssertEqual(receiveCompletionCount, 0)
        XCTAssertEqual(receiveCancelCount, 1)
    }

    func test_cleanUpOnComplete() {
        weak var weakObject: TestObject?

        var receiveValueCount = 0
        var receiveCompletionCount = 0
        var receiveCancelCount = 0

        autoreleasepool {
            let object = TestObject()
            weakObject = object

            let publisher = PassthroughSubject<Void, Never>()
            let lifecycle = PassthroughSubject<LifecycleState, Never>()

            publisher
                .autoCancel(lifecycle)
                .sink(receiveValue: {
                    receiveValueCount += 1
                    XCTAssertNotNil(object)
                }, receiveCompletion: { _ in
                    receiveCompletionCount += 1
                }, receiveCancel: {
                    receiveCancelCount += 1
                })
            publisher.send(completion: .finished)
        }

        XCTAssertNil(weakObject)
        XCTAssertEqual(receiveValueCount, 0)
        XCTAssertEqual(receiveCompletionCount, 1)
        XCTAssertEqual(receiveCancelCount, 0)
    }

    func test_cleanUpOnCancel() {
        weak var weakObject: TestObject?

        var receiveValueCount = 0
        var receiveCompletionCount = 0
        var receiveCancelCount = 0

        autoreleasepool {
            let object = TestObject()
            weakObject = object

            let publisher = PassthroughSubject<Void, Never>()
            let lifecycle = PassthroughSubject<LifecycleState, Never>()

            let cancellable = publisher
                .autoCancel(lifecycle)
                .sink(receiveValue: {
                    receiveValueCount += 1
                    XCTAssertNotNil(object)
                }, receiveCompletion: { _ in
                    receiveCompletionCount += 1
                }, receiveCancel: {
                    receiveCancelCount += 1
                })
            cancellable.cancel()
        }

        XCTAssertNil(weakObject)
        XCTAssertEqual(receiveValueCount, 0)
        XCTAssertEqual(receiveCompletionCount, 0)
        XCTAssertEqual(receiveCancelCount, 1)
    }

    func test_cleanUpAlreadyCompletedLifecycle() {
        weak var weakObject: TestObject?

        var receiveValueCount = 0
        var receiveCompletionCount = 0
        var receiveCancelCount = 0

        let publisher = PassthroughSubject<Void, Never>()
        var lifecycleState: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>>!

        autoreleasepool {
            let object = TestObject()
            weakObject = object

            let scopeLifecycle = ScopeLifecycle()
            lifecycleState = scopeLifecycle.lifecycleState

            lifecycleState.retained.sink(receiveValue: { state in
                XCTAssertNotNil(object)
            }, receiveFinished: {
                XCTAssertNotNil(object)
            })
        }

        let cancellable = publisher
            .autoCancel(lifecycleState)
            .sink(receiveValue: {
                receiveValueCount += 1
            }, receiveCompletion: { _ in
                receiveCompletionCount += 1
            }, receiveCancel: {
                receiveCancelCount += 1
            })
        cancellable.cancel()

        XCTAssertNil(weakObject)
        XCTAssertEqual(receiveValueCount, 0)
        XCTAssertEqual(receiveCompletionCount, 0)
        XCTAssertEqual(receiveCancelCount, 1)
    }
}
