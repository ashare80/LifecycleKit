//
//  Copyright (c) 2020. Adam Share
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@testable import Lifecycle
import SwiftUI
import XCTest

final class ViewLifecycleManagerTests: XCTestCase {
    func testBind() {
        let viewLifecycleManaged = TestViewLifecycleManaged()

        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 0)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 0)

        _ = viewLifecycleManaged.tracked(EmptyView())

        XCTAssertEqual(viewLifecycleManaged.viewDidLoadCount, 1)
        XCTAssertEqual(viewLifecycleManaged.viewDidAppearCount, 0)
        XCTAssertEqual(viewLifecycleManaged.viewDidDisappearCount, 0)

        _ = viewLifecycleManaged.tracked(EmptyView())

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
