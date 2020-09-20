//
//  File.swift
//  
//
//  Created by Adam Share on 9/20/20.
//

import Foundation

public protocol LifecycleManageableRouting: AnyObject {
    /// All attached `LifecycleManageable`s.
    var children: [LifecycleManageable] { get }
    
    /// Attaches the given `LifecycleManageable` as a child.
    ///
    /// - parameter child: The child `LifecycleManageable` to attach.
    func attachChild(_ child: LifecycleManageable)
    
    /// Detaches the given `LifecycleManageable` from the tree.
    ///
    /// - parameter child: The child `LifecycleManageable` to detach.
    func detachChild(_ child: LifecycleManageable)
}

extension LifecycleManageableRouting where Self: LifecycleManageable {
    public var children: [LifecycleManageable] {
        return scopeLifecycleManager.children
    }

    /// Attaches the given `LifecycleManageable` as a child.
    ///
    /// - parameter child: The child `LifecycleManageable` to attach.
    public func attachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager.attachChild(child)
    }

    /// Detaches the given `LifecycleManageable` from the tree.
    ///
    /// - parameter child: The child `LifecycleManageable` to detach.
    public func detachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager.detachChild(child)
    }
}

extension LifecycleManageableRouting where Self: WeakLifecycleManageable {
    public var children: [LifecycleManageable] {
        return scopeLifecycleManager?.children ?? []
    }

    /// Attaches the given `LifecycleManageable` as a child.
    ///
    /// - parameter child: The child `LifecycleManageable` to attach.
    public func attachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager?.attachChild(child)
    }

    /// Detaches the given `LifecycleManageable` from the tree.
    ///
    /// - parameter child: The child `LifecycleManageable` to detach.
    public func detachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager?.detachChild(child)
    }
}
