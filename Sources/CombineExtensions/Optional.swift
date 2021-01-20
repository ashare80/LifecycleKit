//
//  File.swift
//  
//
//  Created by Adam Share on 1/19/21.
//

import Combine
import Foundation

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

extension Publisher where Output: OptionalType {
    public func filterNil() -> Publishers.Map<Publishers.Filter<Self>, Output.Wrapped> {
        return filter { (output) -> Bool in output.value != nil }
            .map { output -> Output.Wrapped in output.value! }
    }
}
