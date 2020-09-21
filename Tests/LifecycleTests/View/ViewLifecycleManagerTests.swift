//
//  File.swift
//  
//
//  Created by Adam Share on 9/21/20.
//

import Foundation
@testable import Lifecycle
import XCTest
import SwiftUI

final class ViewLifecycleManagerTests: XCTestCase {
    func testBind() {
        let viewLifecycleManaged = TestViewLifecycleManaged()
        
        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 0)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 0)

        let _ = viewLifecycleManaged.tracked(EmptyView())
        
        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 0)
        
        let _ = viewLifecycleManaged.tracked(EmptyView())
        
        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 0)
        
        viewLifecycleManaged.viewLifecycleManager.isDisplayed = true
        
        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 0)
        
        viewLifecycleManaged.viewLifecycleManager.isDisplayed = true
        
        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 0)
        
        viewLifecycleManaged.viewLifecycleManager.isDisplayed = false
        
        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 1)
        
        viewLifecycleManaged.viewLifecycleManager.isDisplayed = false
        
        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 1)
    }
    
    func testBindAgain_asserts() {
        let viewLifecycleManaged = TestViewLifecycleManaged()
        expectAssertionFailure {
            viewLifecycleManaged.bind(to: viewLifecycleManaged.viewLifecycleManager)
        }
    }
}

final class TestViewLifecycleManaged: ViewLifecycleManaged {
    var viewDidLoadCount: Int = 0
    override func viewDidLoad() {
        viewDidLoadCount += 1
    }
    
    var viewDidAppearCount: Int = 0
    override func viewDidAppear() {
        viewDidAppearCount += 1
    }
    
    var viewDidDisappearCount: Int = 0
    override func viewDidDisappear() {
        viewDidDisappearCount += 1
    }
}
