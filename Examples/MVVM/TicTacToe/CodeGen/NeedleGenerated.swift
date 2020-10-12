

import Combine
import Lifecycle
import MVVM
import SPIR
import SwiftUI
import NeedleFoundation

let needleDependenciesHash : String? = nil

// MARK: - Registration

public func registerProviderFactories() {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedInComponent->OffGameComponent") { component in
        return OffGameDependency479766f40010f2fba206Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedInComponent->RandomWinComponent") { component in
        return RandomWinDependencyb8e547682e0f82da7ce5Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedInComponent->TicTacToeComponent") { component in
        return TicTacToeDependencyd8da033f5693c655b017Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedOutComponent") { component in
        return LoggedOutDependencyf9a3847ddf2c334fa1cbProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedInComponent->OffGameComponent->BasicScoreBoard") { component in
        return BasicScoreBoardDependency38b1143b1830ad844ca5Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedInComponent") { component in
        return LoggedInDependency00a48680f6ff3c35fee7Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root") { component in
        return EmptyDependencyProvider(component: component)
    }
    
}

// MARK: - Providers

private class OffGameDependency479766f40010f2fba206BaseProvider: OffGameDependency {
    var player1Name: String {
        return loggedInComponent.player1Name
    }
    var player2Name: String {
        return loggedInComponent.player2Name
    }
    var scoreStream: ScoreStream {
        return loggedInComponent.scoreStream
    }
    var games: [Game] {
        return loggedInComponent.games
    }
    var offGameListener: OffGameListener {
        return loggedInComponent.offGameListener
    }
    private let loggedInComponent: LoggedInComponent
    init(loggedInComponent: LoggedInComponent) {
        self.loggedInComponent = loggedInComponent
    }
}
/// ^->Root->LoggedInComponent->OffGameComponent
private class OffGameDependency479766f40010f2fba206Provider: OffGameDependency479766f40010f2fba206BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent as! LoggedInComponent)
    }
}
private class RandomWinDependencyb8e547682e0f82da7ce5BaseProvider: RandomWinDependency {
    var player1Name: String {
        return loggedInComponent.player1Name
    }
    var player2Name: String {
        return loggedInComponent.player2Name
    }
    var mutableScoreStream: MutableScoreStream {
        return loggedInComponent.mutableScoreStream
    }
    private let loggedInComponent: LoggedInComponent
    init(loggedInComponent: LoggedInComponent) {
        self.loggedInComponent = loggedInComponent
    }
}
/// ^->Root->LoggedInComponent->RandomWinComponent
private class RandomWinDependencyb8e547682e0f82da7ce5Provider: RandomWinDependencyb8e547682e0f82da7ce5BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent as! LoggedInComponent)
    }
}
private class TicTacToeDependencyd8da033f5693c655b017BaseProvider: TicTacToeDependency {
    var player1Name: String {
        return loggedInComponent.player1Name
    }
    var player2Name: String {
        return loggedInComponent.player2Name
    }
    var mutableScoreStream: MutableScoreStream {
        return loggedInComponent.mutableScoreStream
    }
    private let loggedInComponent: LoggedInComponent
    init(loggedInComponent: LoggedInComponent) {
        self.loggedInComponent = loggedInComponent
    }
}
/// ^->Root->LoggedInComponent->TicTacToeComponent
private class TicTacToeDependencyd8da033f5693c655b017Provider: TicTacToeDependencyd8da033f5693c655b017BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent as! LoggedInComponent)
    }
}
private class LoggedOutDependencyf9a3847ddf2c334fa1cbBaseProvider: LoggedOutDependency {
    var loggedOutListener: LoggedOutListener {
        return root.loggedOutListener
    }
    private let root: Root
    init(root: Root) {
        self.root = root
    }
}
/// ^->Root->LoggedOutComponent
private class LoggedOutDependencyf9a3847ddf2c334fa1cbProvider: LoggedOutDependencyf9a3847ddf2c334fa1cbBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(root: component.parent as! Root)
    }
}
private class BasicScoreBoardDependency38b1143b1830ad844ca5BaseProvider: BasicScoreBoardDependency {
    var player1Name: String {
        return loggedInComponent.player1Name
    }
    var player2Name: String {
        return loggedInComponent.player2Name
    }
    var scoreStream: ScoreStream {
        return loggedInComponent.scoreStream
    }
    private let loggedInComponent: LoggedInComponent
    init(loggedInComponent: LoggedInComponent) {
        self.loggedInComponent = loggedInComponent
    }
}
/// ^->Root->LoggedInComponent->OffGameComponent->BasicScoreBoard
private class BasicScoreBoardDependency38b1143b1830ad844ca5Provider: BasicScoreBoardDependency38b1143b1830ad844ca5BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent.parent as! LoggedInComponent)
    }
}
private class LoggedInDependency00a48680f6ff3c35fee7BaseProvider: LoggedInDependency {
    var loggedInPresenter: LoggedInPresentable {
        return root.loggedInPresenter
    }
    private let root: Root
    init(root: Root) {
        self.root = root
    }
}
/// ^->Root->LoggedInComponent
private class LoggedInDependency00a48680f6ff3c35fee7Provider: LoggedInDependency00a48680f6ff3c35fee7BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(root: component.parent as! Root)
    }
}
