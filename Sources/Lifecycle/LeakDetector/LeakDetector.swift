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
import CombineExtensions
import SwiftUI

/// Leak detection status.
public enum LeakDetectionStatus {
    /// Leak detection is in progress.
    case inProgress

    /// Leak detection has completed.
    case completed
}

/// The default time values used for leak detection expectations.
public extension TimeInterval {
    /// The object deallocation time.
    static let deallocationExpectation: TimeInterval = 1.0

    /// The view disappear time.
    static let viewDisappearExpectation: TimeInterval = 5.0
}

/// An expectation based leak detector, that allows an object's owner to set an expectation that an owned object to be
/// deallocated within a time frame.
///
/// An `Interactor` might for example expect its `Presenter` be deallocated when the `Interactor`
/// itself is deallocated. If the interactor does not deallocate in time, a runtime assert is triggered, along with
/// critical logging.
public class LeakDetector {
    /// The singleton instance.
    public static let instance = LeakDetector()

    @Published public private(set) var expectationCount: Int = 0 {
        didSet {
            if expectationCount == 0 {
                // Clear strong key references.
                trackingObjects.removeAll()
            }
        }
    }

    private(set) var trackingObjects = WeakSet<AnyObject>()

    // Test override for leak detectors.
    static var disableLeakDetectorOverride: Bool = false

    private lazy var disableLeakDetector: Bool = {
        if let environmentValue = ProcessInfo().environment["DISABLE_LEAK_DETECTION"] {
            let lowercase = environmentValue.lowercased()
            return lowercase == "yes" || lowercase == "true"
        }
        return LeakDetector.disableLeakDetectorOverride
    }()

    private init() {}

    /// Sets up an expectation for the given objects to be deallocated within the given time.
    ///
    /// - parameter objects: The weak set of objects to track for deallocation.
    /// - parameter inTime: The time the given object is expected to be deallocated within.
    /// - returns: `Publishers.First` that outputs after delay.
    public func expectDeallocate<Element>(objects: WeakSet<Element>, inTime time: TimeInterval = .deallocationExpectation) -> RelayPublisher<Void> {
        guard !objects.isEmpty else { return Empty().eraseToAnyPublisher() }
        return Timer
            .execute(withDelay: time)
            .receive(on: Schedulers.main)
            .handleEvents(receiveSubscription: { _ in
                self.trackingObjects.formUnion(objects)
                self.expectationCount += 1
            }, receiveOutput: {
                if !objects.isEmpty {
                    let message = "\(objects) have leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"
                    if self.disableLeakDetector {
                        print("Leak detection is disabled. This should only be used for debugging purposes.")
                        print(message)
                    } else {
                        assertionFailure(message)
                    }
                }
            }, receiveCompletion: { _ in
                self.expectationCount -= 1
            }, receiveCancel: {
                self.expectationCount -= 1
            })
            .subscribe(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    /// Sets up an expectation for the given object to be deallocated within the given time.
    ///
    /// - parameter object: The object to track for deallocation.
    /// - parameter inTime: The time the given object is expected to be deallocated within.
    /// - returns: `Publishers.First` that outputs after delay.
    public func expectDeallocate(object: AnyObject, inTime time: TimeInterval = .deallocationExpectation) -> RelayPublisher<Void> {
        return Timer
            .execute(withDelay: time)
            .receive(on: Schedulers.main)
            .handleEvents(receiveSubscription: { [weak object] _ in
                self.expectationCount += 1
                if let object = object {
                    self.trackingObjects.insert(object)
                }
            }, receiveOutput: { [weak object] in
                if let object = object {
                    let message = memoryAddressDescription(for: object) + " has leaked. Objects are expected to be deallocated at this time: \(self.trackingObjects)"
                    if self.disableLeakDetector {
                        print("Leak detection is disabled. This should only be used for debugging purposes.")
                        print(message)
                    } else {
                        assertionFailure(message)
                    }
                }
            }, receiveCompletion: { _ in
                self.expectationCount -= 1
            }, receiveCancel: {
                self.expectationCount -= 1
            })
            .subscribe(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    /// Sets up an expectation for the given view controller to disappear within the given time.
    ///
    /// - parameter presenter: The `View` expected to disappear.
    /// - parameter inTime: The time the given view controller is expected to disappear.
    /// - returns: The handle that can be used to cancel the expectation.
    public func expectViewDisappear(tracker: ViewLifecycle, inTime time: TimeInterval = .viewDisappearExpectation) -> RelayPublisher<Void> {
        guard tracker.isActive else { return Empty().eraseToAnyPublisher() }

        return Timer
            .execute(withDelay: time)
            .receive(on: Schedulers.main)
            .handleEvents(receiveSubscription: { _ in
                self.expectationCount += 1
            }, receiveOutput: { [weak tracker] in
                if let tracker = tracker, let owner = tracker.owner, tracker.isDisplayed {
                    let message = memoryAddressDescription(for: owner) + " appearance has leaked. Either its parent lifecycle who does not own a view was detached, but failed to dismiss the leaked view; or the view is reused and re-added to window, yet the lifcycle was not re-activated but re-created. Objects are expected to be deallocated at this time: \(self.trackingObjects)"

                    if self.disableLeakDetector {
                        print("Leak detection is disabled. This should only be used for debugging purposes.")
                        print(message)
                    } else {
                        assertionFailure(message)
                    }
                }
            }, receiveCompletion: { _ in
                self.expectationCount -= 1
            }, receiveCancel: {
                self.expectationCount -= 1
            })
            .subscribe(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    #if DEBUG
        /// Reset the state of Leak Detector, internal for UI test only.
        func reset() {
            trackingObjects.removeAll()
            expectationCount = 0
        }
    #endif
}
