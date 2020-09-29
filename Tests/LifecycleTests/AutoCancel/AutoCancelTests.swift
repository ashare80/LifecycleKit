//
//  File.swift
//  
//
//  Created by Adam Share on 9/28/20.
//

import Foundation
@testable import Lifecycle
import XCTest
import Combine
import CombineExtensions

final class AutoCancelTests: XCTestCase {
    // MARK: - Tests

    func test_cleanupOnInactive() {
        let publisher = PassthroughSubject<(), Never>()
        
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
            
            let publisher = PassthroughSubject<(), Never>()
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
            
            let publisher = PassthroughSubject<(), Never>()
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
}
