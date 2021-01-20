//
//  File.swift
//  
//
//  Created by Adam Share on 1/19/21.
//

#if !os(macOS)
import Foundation
import UIKit
import CombineExtensions

open class LifecycleViewController: UIViewController, ObjectIdentifiable, ViewLifecycleOwner {
    public let viewLifecycle: ViewLifecycle = ViewLifecycle()

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLifecycle.viewDidLoad(with: self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewLifecycle.isDisplayed = true
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewLifecycle.isDisplayed = false
    }
}
#endif
