//
//  File.swift
//  
//
//  Created by Adam Share on 1/19/21.
//

#if !os(macOS)
import Foundation
import UIKit

/// The root `Router` of an application.
public protocol LaunchRouting: ViewableRouting {

    /// Launches the router tree.
    ///
    /// - parameter window: The application window to launch from.
    func launch(from window: UIWindow)
}

/// The application root router base class, that acts as the root of the router tree.
open class LaunchRouter<InteractorType, ViewControllerType>: ViewableRouter<InteractorType, ViewControllerType>, LaunchRouting, RootLifecycle {

    public var rootLifecycleOwner: LifecycleOwner {
        return self
    }
    
    /// Initializer.
    ///
    /// - parameter interactor: The corresponding `Interactor` of this `Router`.
    /// - parameter viewController: The corresponding `ViewController` of this `Router`.
    public override init(interactor: InteractorType, viewController: ViewControllerType) {
        super.init(interactor: interactor, viewController: viewController)
    }

    /// Launches the router tree.
    ///
    /// - parameter window: The window to launch the router tree in.
    public final func launch(from window: UIWindow) {
        window.rootViewController = viewControllable.uiviewController
        window.makeKeyAndVisible()

        activateRoot()
    }
}
#endif
