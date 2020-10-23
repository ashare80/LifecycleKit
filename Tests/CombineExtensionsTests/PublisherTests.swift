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
@testable import CombineExtensions
import XCTest

final class PublisherTests: XCTestCase {
    func testFilterNil() {
        let publisher = CurrentValueRelay<Bool?>(nil)

        let record = publisher
            .filterNil()
            .record()

        XCTAssertEqual(record.events, [])

        publisher.send(true)

        XCTAssertEqual(record.events, [Subscribers.Event(true)])

        publisher.send(nil)

        XCTAssertEqual(record.events, [Subscribers.Event(true)])

        publisher.send(false)

        XCTAssertEqual(record.events, [Subscribers.Event(true), Subscribers.Event(false)])
    }
}
