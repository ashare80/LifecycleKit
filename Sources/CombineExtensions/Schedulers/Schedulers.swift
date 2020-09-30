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
import Foundation

public struct Schedulers {
    /// In case `schedule` methods are called from `DispatchQueue.main`, it will perform action immediately without scheduling.
    public static let main: DispatchQueue.Scheduler = .init(.main)

    /// Schedules to `DispatchQueue.main` to run at the next possible opportunity.
    public static let asyncMain: DispatchQueue = .main

    /// In case `schedule` methods are called from `DispatchQueue.userInitiated`, it will perform action immediately without scheduling.
    public static let userInitiated: DispatchQueue.Scheduler = .init(.userInitiated)

    /// In case `schedule` methods are called from `DispatchQueue.userInteractive`, it will perform action immediately without scheduling.
    public static let userInteractive: DispatchQueue.Scheduler = .init(.userInteractive)

    /// In case `schedule` methods are called from `DispatchQueue.default`, it will perform action immediately without scheduling.
    public static let `default`: DispatchQueue.Scheduler = .init(.default)

    /// In case `schedule` methods are called from `DispatchQueue.utility`, it will perform action immediately without scheduling.
    public static let utility: DispatchQueue.Scheduler = .init(.utility)

    /// In case `schedule` methods are called from `DispatchQueue.background`, it will perform action immediately without scheduling.
    public static let background: DispatchQueue.Scheduler = .init(.background)
}

extension DispatchQueue {
    /// A scheduler that will perfom the action immediately if the current execution context matches the dispatch queue.
    /// Otherwise the default schedule async to queue is performed.
    public struct Scheduler: Combine.Scheduler {
        public typealias SchedulerOptions = Never
        public typealias SchedulerTimeType = Foundation.DispatchQueue.SchedulerTimeType

        public var now: SchedulerTimeType {
            return dispatchQueue.now
        }

        public var minimumTolerance: SchedulerTimeType.Stride {
            return dispatchQueue.minimumTolerance
        }

        private let dispatchQueue: DispatchQueue

        public init(_ dispatchQueue: DispatchQueue) {
            self.dispatchQueue = dispatchQueue
        }

        public func schedule(options: SchedulerOptions? = nil, _ action: @escaping () -> Void) {
            if dispatchQueue.isCurrentExecutionContext {
                action()
            } else {
                dispatchQueue.schedule(action)
            }
        }

        public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions? = nil, _ action: @escaping () -> Void) {
            dispatchQueue.schedule(after: date, tolerance: tolerance, options: nil, action)
        }

        public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions? = nil, _ action: @escaping () -> Void) -> Cancellable {
            return dispatchQueue.schedule(after: date, interval: interval, tolerance: tolerance, options: nil, action)
        }
    }
}
