//
//  File.swift
//  
//
//  Created by Adam Share on 1/19/21.
//

import Foundation

/// Base class of an `Interactor` that actually has an associated `Presenter` and `View`.
open class PresentableInteractor<PresenterType>: Interactor {
    public let presenter: PresenterType

    /// Initializer.
    ///
    /// - note: This holds a strong reference to the given `Presenter`.
    ///
    /// - parameter presenter: The presenter associated with this `Interactor`.
    public init(presenter: PresenterType) {
        self.presenter = presenter
        
        super.init()
        
        if let viewLifecycleOwner = presenter as? ViewLifecycleOwner,
           let viewLifecycleSubscriber = self as? ViewLifecycleSubscriber {
            viewLifecycleOwner.viewLifecycle.subscribe(viewLifecycleSubscriber)
        }
    }
}
