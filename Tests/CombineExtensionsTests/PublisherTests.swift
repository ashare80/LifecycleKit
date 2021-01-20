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
    var cancellable: AnyCancellable?
    let publisher = CurrentValueSubject<Bool, Error>(true)
    
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
    
        func testSink11111() {
        // [1, 1, 1, 1, 1,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveCompletion: { (_) in },
            receiveFailure: { (_) in },
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink01111() {
        // [0, 1, 1, 1, 1,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in },
            receiveFailure: { (_) in },
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink00111() {
        // [0, 0, 1, 1, 1,]
        cancellable = publisher.sink(
            receiveFailure: { (_) in },
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink00011() {
        // [0, 0, 0, 1, 1,]
        cancellable = publisher.sink(
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink00001() {
        // [0, 0, 0, 0, 1,]
        cancellable = publisher.sink(
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink00000() {
        // [0, 0, 0, 0, 0,]
        cancellable = publisher.sink()
        }
        
        func testSink10111() {
        // [1, 0, 1, 1, 1,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveFailure: { (_) in },
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink10011() {
        // [1, 0, 0, 1, 1,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink10001() {
        // [1, 0, 0, 0, 1,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink10101() {
        // [1, 0, 1, 0, 1,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveFailure: { (_) in },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink10000() {
        // [1, 0, 0, 0, 0,]
        cancellable = publisher.sink(
            receiveCancel: { }
        )
        }
        
        func testSink01000() {
        // [0, 1, 0, 0, 0,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in }
        )
        }
        
        func testSink01100() {
        // [0, 1, 1, 0, 0,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in },
            receiveFailure: { (_) in }
        )
        }
        
        func testSink01101() {
        // [0, 1, 1, 0, 1,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in },
            receiveFailure: { (_) in },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink01110() {
        // [0, 1, 1, 1, 0,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in },
            receiveFailure: { (_) in },
            receiveFinished: { }
        )
        }
        
        func testSink11011() {
        // [1, 1, 0, 1, 1,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveCompletion: { (_) in },
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink11001() {
        // [1, 1, 0, 0, 1,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveCompletion: { (_) in },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink11000() {
        // [1, 1, 0, 0, 0,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveCompletion: { (_) in }
        )
        }
        
        func testSink00100() {
        // [0, 0, 1, 0, 0,]
        cancellable = publisher.sink(
            receiveFailure: { (_) in }
        )
        }
        
        func testSink00101() {
        // [0, 0, 1, 0, 1,]
        cancellable = publisher.sink(
            receiveFailure: { (_) in },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
        }
        
        func testSink00110() {
        // [0, 0, 1, 1, 0,]
        cancellable = publisher.sink(
            receiveFailure: { (_) in },
            receiveFinished: { }
        )
        }
        
        func testSink00010() {
        // [0, 0, 0, 1, 0,]
        cancellable = publisher.sink(
            receiveFinished: { }
        )
        }
        
        func testSink10110() {
        // [1, 0, 1, 1, 0,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveFailure: { (_) in },
            receiveFinished: { }
        )
        }
        
        func testSink10010() {
        // [1, 0, 0, 1, 0,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveFinished: { }
        )
        }
        
        func testSink11010() {
        // [1, 1, 0, 1, 0,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveCompletion: { (_) in },
            receiveFinished: { }
        )
        }
        
        func testSink01010() {
        // [0, 1, 0, 1, 0,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in },
            receiveFinished: { }
        )
        }
        
        func testSink01011() {
        // [0, 1, 0, 1, 1,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in },
            receiveFinished: { },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
    }
    
    func testSink01001() {
        // [0, 1, 0, 0, 1,]
        cancellable = publisher.sink(
            receiveCompletion: { (_) in },
            receiveValue: { (value) in  XCTAssertTrue(value) }
        )
    }
    
    func test11110() {
        // [1, 1, 1, 1, 0,]
        cancellable = publisher.sink(
            receiveCancel: { },
            receiveCompletion: { (_) in },
            receiveFailure: { (_) in },
            receiveFinished: { }
        )
    }
}
