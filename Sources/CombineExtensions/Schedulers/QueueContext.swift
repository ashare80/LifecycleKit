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

import Foundation

public protocol DispatchQueueContext {
    var isCurrentExecutionContext: Bool { get }
}

public extension DispatchQueue {
    struct Context<Value: Equatable>: DispatchQueueContext {
        public let key: DispatchSpecificKey<Value>
        public let value: Value

        public init(key: DispatchSpecificKey<Value>, value: Value) {
            self.key = key
            self.value = value
        }

        public var isCurrentExecutionContext: Bool {
            Foundation.DispatchQueue.getSpecific(key: key) == value
        }
    }

    typealias DefaultContext = Context<UInt8>
}

public extension DispatchQueue.DefaultContext {
    init() {
        self.init(key: DispatchSpecificKey<UInt8>(), value: 0)
    }
}
