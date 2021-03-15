//
//  Copyright (c) 2021. Adam Share
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
@testable import CombineExtensions
import XCTest

final class ReplayTests: XCTestCase {

    func testReplaySubject() {
        weak var weakSubject0: ReplaySubject<Int, MockError>?
        weak var weakSubject1: ReplaySubject<Int, MockError>?
        weak var weakSubject5: ReplaySubject<Int, MockError>?

        autoreleasepool {
            let subject0 = ReplaySubject<Int, MockError>(bufferSize: 0)
            let subject1 = ReplaySubject<Int, MockError>()
            let subject5 = ReplaySubject<Int, MockError>(bufferSize: 5)

            weakSubject0 = subject0
            weakSubject1 = subject1
            weakSubject5 = subject5

            let record0Before = subject0.record()
            let record1Before = subject1.record()
            let record5Before = subject5.record()

            subject0.send(1)
            subject1.send(1)
            subject5.send(1)

            XCTAssertEqual(record0Before.events, [Subscribers.Event(1)])
            XCTAssertEqual(record1Before.events, [Subscribers.Event(1)])
            XCTAssertEqual(record5Before.events, [Subscribers.Event(1)])

            subject0.send(2)
            subject1.send(2)
            subject5.send(2)

            XCTAssertEqual(record0Before.events, [Subscribers.Event(1), Subscribers.Event(2)])
            XCTAssertEqual(record1Before.events, [Subscribers.Event(1), Subscribers.Event(2)])
            XCTAssertEqual(record5Before.events, [Subscribers.Event(1), Subscribers.Event(2)])

            XCTAssertEqual(subject0.subscriptions.count, 1)
            XCTAssertEqual(subject1.subscriptions.count, 1)
            XCTAssertEqual(subject5.subscriptions.count, 1)

            record0Before.cancellable?.cancel()
            record1Before.cancellable?.cancel()
            record5Before.cancellable?.cancel()

            XCTAssertEqual(subject0.subscriptions.count, 0)
            XCTAssertEqual(subject1.subscriptions.count, 0)
            XCTAssertEqual(subject5.subscriptions.count, 0)

            subject0.send(3)
            subject1.send(3)
            subject5.send(3)

            XCTAssertEqual(record0Before.events, [Subscribers.Event(1), Subscribers.Event(2)])
            XCTAssertEqual(record1Before.events, [Subscribers.Event(1), Subscribers.Event(2)])
            XCTAssertEqual(record5Before.events, [Subscribers.Event(1), Subscribers.Event(2)])

            subject0.send(4)
            subject1.send(4)
            subject5.send(4)

            let record0After2 = subject0.record()
            let record1After2 = subject1.record()
            let record5After2 = subject5.record()

            XCTAssertEqual(subject0.subscriptions.count, 1)
            XCTAssertEqual(subject1.subscriptions.count, 1)
            XCTAssertEqual(subject5.subscriptions.count, 1)

            XCTAssertEqual(record0After2.events, [])
            XCTAssertEqual(record1After2.events, [Subscribers.Event(4)])
            XCTAssertEqual(record5After2.events, [Subscribers.Event(1), Subscribers.Event(2), Subscribers.Event(3), Subscribers.Event(4)])

            subject0.send(5)
            subject1.send(5)
            subject5.send(5)

            XCTAssertEqual(record0After2.events, [Subscribers.Event(5)])
            XCTAssertEqual(record1After2.events, [Subscribers.Event(4), Subscribers.Event(5)])
            XCTAssertEqual(record5After2.events, [Subscribers.Event(1), Subscribers.Event(2), Subscribers.Event(3), Subscribers.Event(4), Subscribers.Event(5)])

            subject0.send(6)
            subject1.send(6)
            subject5.send(6)

            XCTAssertEqual(record0After2.events, [Subscribers.Event(5), Subscribers.Event(6)])
            XCTAssertEqual(record1After2.events, [Subscribers.Event(4), Subscribers.Event(5), Subscribers.Event(6)])
            XCTAssertEqual(record5After2.events, [Subscribers.Event(1), Subscribers.Event(2), Subscribers.Event(3), Subscribers.Event(4), Subscribers.Event(5), Subscribers.Event(6)])

            XCTAssertEqual(subject0.subscriptions.count, 1)
            XCTAssertEqual(subject1.subscriptions.count, 1)
            XCTAssertEqual(subject5.subscriptions.count, 1)

            subject0.send(completion: .finished)
            subject1.send(completion: .failure(.test))
            subject5.send(completion: .finished)

            XCTAssertEqual(subject0.subscriptions.count, 0)
            XCTAssertEqual(subject1.subscriptions.count, 0)
            XCTAssertEqual(subject5.subscriptions.count, 0)

            XCTAssertEqual(record0After2.events, [Subscribers.Event(5), Subscribers.Event(6), Subscribers.Event(.finished)])
            XCTAssertEqual(record1After2.events, [Subscribers.Event(4), Subscribers.Event(5), Subscribers.Event(6), Subscribers.Event(.failure(.test))])
            XCTAssertEqual(record5After2.events, [Subscribers.Event(1), Subscribers.Event(2), Subscribers.Event(3), Subscribers.Event(4), Subscribers.Event(5), Subscribers.Event(6), Subscribers.Event(.finished)])

            let record0After6 = subject0.record()
            let record1After6 = subject1.record()
            let record5After6 = subject5.record()

            XCTAssertEqual(record0After6.events, [Subscribers.Event(.finished)])
            XCTAssertEqual(record1After6.events, [Subscribers.Event(6), Subscribers.Event(.failure(.test))])
            XCTAssertEqual(record5After6.events, [Subscribers.Event(2), Subscribers.Event(3), Subscribers.Event(4), Subscribers.Event(5), Subscribers.Event(6), Subscribers.Event(.finished)])

            XCTAssertEqual(subject0.subscriptions.count, 0)
            XCTAssertEqual(subject1.subscriptions.count, 0)
            XCTAssertEqual(subject5.subscriptions.count, 0)
        }

        XCTAssertNil(weakSubject0)
        XCTAssertNil(weakSubject1)
        XCTAssertNil(weakSubject5)
    }

    func testSharedReplay() {
        weak var weakObject: TestObject?
        weak var weakSubject: PassthroughSubject<TestObject, MockError>?

        autoreleasepool {
            let subject = PassthroughSubject<TestObject, MockError>()
            weakSubject = subject

            let sharedReplay = subject.share(replay: 1)

            subject.send(TestObject())

            let record1 = sharedReplay.record()

            XCTAssertEqual(record1.events, [])

            let sent = TestObject()
            weakObject = sent

            subject.send(sent)

            let record2 = sharedReplay.record()

            XCTAssertEqual(record1.events, record2.events)
            XCTAssertEqual(record1.events, [Subscribers.Event(sent)])

            XCTAssertNotNil(weakSubject)
            XCTAssertNotNil(weakObject)
        }

        XCTAssertNil(weakSubject)
        XCTAssertNil(weakObject)
    }

    func testShareScope1() {
        let subject = PassthroughSubject<TestObject, MockError>()
        subject.send(TestObject())

        let sharedReplay = subject.share(replay: 1)

        let record = sharedReplay
            .record()

        XCTAssertEqual(record.events.count, 0)

        subject.send(TestObject())

        XCTAssertEqual(record.events.count, 1)

        record.cancellable?.cancel()

        let record2 = sharedReplay
            .record()

        XCTAssertEqual(record2.events.count, 1)
    }

    func testShareScope5() {
        let subject = PassthroughSubject<TestObject, MockError>()
        subject.send(TestObject())

        let sharedReplay = subject.share(replay: 5)

        let record = sharedReplay
            .record()

        XCTAssertEqual(record.events.count, 0)

        subject.send(TestObject())
        subject.send(TestObject())
        subject.send(TestObject())
        subject.send(TestObject())
        subject.send(TestObject())
        subject.send(TestObject())

        XCTAssertEqual(record.events.count, 6)

        record.cancellable?.cancel()

        let record2 = sharedReplay
            .record()

        XCTAssertEqual(record2.events.count, 5)
    }
}

final class TestObject: ObjectIdentifiable {}
enum MockError: String, Error, Equatable {
    case test
}
