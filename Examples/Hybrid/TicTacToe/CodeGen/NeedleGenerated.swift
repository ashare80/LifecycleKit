

import Combine
import Foundation
import Lifecycle
import MVVM
import SPIR
import SwiftUI
import NeedleFoundation

let needleDependenciesHash : String? = nil

// MARK: - Registration

public func registerProviderFactories() {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedIn->OffGame") { component in
        return OffGameDependency749fae7c81404a42d06eProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedIn->RandomWin") { component in
        return RandomWinDependencyf6fe7378aa31d9a21382Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedIn->TicTacToe") { component in
        return TicTacToeDependency83659b4ab5b815019184Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedOut") { component in
        return LoggedOutDependencyb21f53823a083e9d041eProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedIn->OffGame->BasicScoreBoard") { component in
        return BasicScoreBoardDependencye82582c13a823aae9649Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root->LoggedIn") { component in
        return LoggedInDependencycf8c09c6bc15c83132ceProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->Root") { component in
        return EmptyDependencyProvider(component: component)
    }
    
}

// MARK: - Providers

private class OffGameDependency749fae7c81404a42d06eBaseProvider: OffGameDependency {
    var player1Name: String {
        return loggedIn.player1Name
    }
    var player2Name: String {
        return loggedIn.player2Name
    }
    var scorePublisher: ScorePublisher {
        return loggedIn.scorePublisher
    }
    var games: [Game] {
        return loggedIn.games
    }
    var offGameListener: OffGameListener {
        return loggedIn.offGameListener
    }
    private let loggedIn: LoggedIn
    init(loggedIn: LoggedIn) {
        self.loggedIn = loggedIn
    }
}
/// ^->Root->LoggedIn->OffGame
private class OffGameDependency749fae7c81404a42d06eProvider: OffGameDependency749fae7c81404a42d06eBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedIn: component.parent as! LoggedIn)
    }
}
private class RandomWinDependencyf6fe7378aa31d9a21382BaseProvider: RandomWinDependency {
    var player1Name: String {
        return loggedIn.player1Name
    }
    var player2Name: String {
        return loggedIn.player2Name
    }
    var scoreRelay: ScoreRelay {
        return loggedIn.scoreRelay
    }
    private let loggedIn: LoggedIn
    init(loggedIn: LoggedIn) {
        self.loggedIn = loggedIn
    }
}
/// ^->Root->LoggedIn->RandomWin
private class RandomWinDependencyf6fe7378aa31d9a21382Provider: RandomWinDependencyf6fe7378aa31d9a21382BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedIn: component.parent as! LoggedIn)
    }
}
private class TicTacToeDependency83659b4ab5b815019184BaseProvider: TicTacToeDependency {
    var player1Name: String {
        return loggedIn.player1Name
    }
    var player2Name: String {
        return loggedIn.player2Name
    }
    var scoreRelay: ScoreRelay {
        return loggedIn.scoreRelay
    }
    private let loggedIn: LoggedIn
    init(loggedIn: LoggedIn) {
        self.loggedIn = loggedIn
    }
}
/// ^->Root->LoggedIn->TicTacToe
private class TicTacToeDependency83659b4ab5b815019184Provider: TicTacToeDependency83659b4ab5b815019184BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedIn: component.parent as! LoggedIn)
    }
}
private class LoggedOutDependencyb21f53823a083e9d041eBaseProvider: LoggedOutDependency {
    var loggedOutListener: LoggedOutListener {
        return root.loggedOutListener
    }
    private let root: Root
    init(root: Root) {
        self.root = root
    }
}
/// ^->Root->LoggedOut
private class LoggedOutDependencyb21f53823a083e9d041eProvider: LoggedOutDependencyb21f53823a083e9d041eBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(root: component.parent as! Root)
    }
}
private class BasicScoreBoardDependencye82582c13a823aae9649BaseProvider: BasicScoreBoardDependency {
    var player1Name: String {
        return loggedIn.player1Name
    }
    var player2Name: String {
        return loggedIn.player2Name
    }
    var scorePublisher: ScorePublisher {
        return loggedIn.scorePublisher
    }
    private let loggedIn: LoggedIn
    init(loggedIn: LoggedIn) {
        self.loggedIn = loggedIn
    }
}
/// ^->Root->LoggedIn->OffGame->BasicScoreBoard
private class BasicScoreBoardDependencye82582c13a823aae9649Provider: BasicScoreBoardDependencye82582c13a823aae9649BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedIn: component.parent.parent as! LoggedIn)
    }
}
private class LoggedInDependencycf8c09c6bc15c83132ceBaseProvider: LoggedInDependency {
    var loggedInPresenter: LoggedInPresentable {
        return root.loggedInPresenter
    }
    private let root: Root
    init(root: Root) {
        self.root = root
    }
}
/// ^->Root->LoggedIn
private class LoggedInDependencycf8c09c6bc15c83132ceProvider: LoggedInDependencycf8c09c6bc15c83132ceBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(root: component.parent as! Root)
    }
}
