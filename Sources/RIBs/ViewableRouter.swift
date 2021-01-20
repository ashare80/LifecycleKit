//
//  File.swift
//  
//
//  Created by Adam Share on 1/19/21.
//

import Foundation

/// The base protocol for all routers that own their own view controllers.
public protocol ViewableRouting: Routing {

    // The following methods must be declared in the base protocol, since `Router` internally invokes these methods.
    // In order to unit test router with a mock child router, the mocked child router first needs to conform to the
    // custom subclass routing protocol, and also this base protocol to allow the `Router` implementation to execute
    // base class logic without error.
    /// The base view controllable associated with this `Router`.
    var viewControllable: ViewControllable { get }
}

/// Base class of an `Interactor` that has a separate associated `Presenter` and `View`.
open class ViewableRouter<InteractorType, ViewControllerType>: Router<InteractorType> {
    
    /// The corresponding `ViewController` owned by this `Router`.
    public let viewController: ViewControllerType
    
    /// The base `ViewControllable` associated with this `Router`.
    public let viewControllable: ViewControllable
    
    /// Initializer.
    ///
    /// - parameter interactor: The corresponding `Interactor` of this `Router`.
    /// - parameter viewController: The corresponding `ViewController` of this `Router`.
    public init(interactor: InteractorType, viewController: ViewControllerType) {
        self.viewController = viewController
        guard let viewControllable = viewController as? ViewControllable else {
            fatalError("\(viewController) should conform to \(ViewControllable.self)")
        }
        
        self.viewControllable = viewControllable
        
        super.init(interactor: interactor)
        
        
        if let viewLifecycleOwner = viewController as? ViewLifecycleOwner {
            viewLifecycleOwner.viewLifecycle.setScopeLifecycle(scopeLifecycle)
            if let viewLifecycleSubscriber = self as? ViewLifecycleSubscriber {
                viewLifecycleOwner.viewLifecycle.subscribe(viewLifecycleSubscriber)
            }
        }
    }
    
    deinit {
        if let viewLifecycleOwner = viewController as? ViewLifecycleOwner {
            expectDeallocateIfOwns(viewLifecycleOwner, inTime: .viewDisappearExpectation)
        }
    }
}
