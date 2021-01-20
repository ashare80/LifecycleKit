//
//  File.swift
//  
//
//  Created by Adam Share on 1/19/21.
//

import Combine
import Foundation

@propertyWrapper
public final class DidSetPublished<Element> {

    public var projectedValue: RelayPublisher<Element> {
        return relay.eraseToAnyPublisher()
    }

    public var wrappedValue: Element {
        set {
            relay.send(newValue)
        }
        get {
            relay.value
        }
    }

    private let relay: CurrentValueRelay<Element>

    public init(wrappedValue: Element) {
        relay = CurrentValueRelay(wrappedValue)
    }

    deinit {
        relay.send(completion: .finished)
    }
}

@propertyWrapper
public final class DidSetFilterNilPublished<Element> {

    public var projectedValue: RelayPublisher<Element> {
        return relay.eraseToAnyPublisher()
    }

    public var wrappedValue: Element? {
        didSet {
            if let value = wrappedValue {
                relay.send(value)
            }
        }
    }

    private let relay: ReplayRelay<Element> = ReplayRelay(bufferSize: 1)

    public init(wrappedValue: Element?) {
        self.wrappedValue = wrappedValue

        if let value = wrappedValue {
            relay.send(value)
        }
    }

    deinit {
        relay.send(completion: .finished)
    }
}
