//
//  File.swift
//  
//
//  Created by Adam Share on 10/10/20.
//

import Lifecycle
import SwiftUI

protocol Controller:
    LifecycleOwner,
    LifecycleSubscriber,
    LifecycleOwnerRouting
{
}

extension Controller {
    public func didLoad(_ lifecyclePublisher: LifecyclePublisher) {}
    public func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {}
    public func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {}
}
    
protocol ViewLifecycleController: Controller,
    ViewLifecycleOwner,
    ViewLifecycleSubscriber
{
}

extension ViewLifecycleController {
    public func viewDidLoad() {}
    public func viewDidAppear() {}
    public func viewDidDisappear() {}
}

open class ViewController: ObjectIdentifiable, ViewLifecycleController, ObservableObject {
    public let scopeLifecycle: ScopeLifecycle
    public let viewLifecycle: ViewLifecycle

    public init(scopeLifecycle: ScopeLifecycle = ScopeLifecycle(),
                viewLifecycle: ViewLifecycle = ViewLifecycle()) {
        self.scopeLifecycle = scopeLifecycle
        self.viewLifecycle = viewLifecycle
        scopeLifecycle.subscribe(self)
        viewLifecycle.subscribe(self)
        viewLifecycle.setScopeLifecycle(scopeLifecycle)
    }
}
