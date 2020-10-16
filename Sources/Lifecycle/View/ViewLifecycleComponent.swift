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
import SwiftUI

public protocol ViewableBuildable {
    func build() -> Viewable
}

extension AnyBuilder: ViewableBuildable where R == Viewable {}

public protocol LifecycleOwnerViewProviding: ViewableBuildable {
    associatedtype ContentView: View
    var lifecycleOwner: LifecycleOwner { get }
    var view: ContentView { get }
}

extension LifecycleOwnerViewProviding {
    public func build() -> Viewable {
        return LifecycleOwnerViewProvider(view: view.asAnyView, childLifecycle: lifecycleOwner)
    }
}

public protocol ViewLifecycleOwnerViewProviding: ViewableBuildable {
    associatedtype ContentView: View
    var lifecycleOwner: LifecycleOwner { get }
    var view: ContentView { get }
    var viewLifecycleOwner: ViewLifecycleOwner { get }
}

extension ViewLifecycleOwnerViewProviding {
    public func build() -> Viewable {
        return LifecycleOwnerViewProvider(view: viewLifecycleOwner.tracked(view), childLifecycle: lifecycleOwner)
    }
}
