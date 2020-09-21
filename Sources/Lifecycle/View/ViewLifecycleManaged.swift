//
//  File.swift
//  
//
//  Created by Adam Share on 9/21/20.
//

import Foundation


/// Base class to conform to `ViewLifecycleManageable` binding as the owner of a `ViewLifecycleManager`.
open class ViewLifecycleManaged: ObjectIdentifiable, ViewLifecycleManageable, ViewLifecycleBindable {
    public let viewLifecycleManager: ViewLifecycleManager

    public init(viewLifecycleManager: ViewLifecycleManager = ViewLifecycleManager()) {
        self.viewLifecycleManager = viewLifecycleManager
        bind(to: viewLifecycleManager)
    }

    open func viewDidLoad() {}
    open func viewDidAppear() {}
    open func viewDidDisappear() {}
}
