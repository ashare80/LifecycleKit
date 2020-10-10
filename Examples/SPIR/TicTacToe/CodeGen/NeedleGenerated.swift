

import Combine
import SPIR
import SwiftUI
import NeedleFoundation

let needleDependenciesHash : String? = nil

// MARK: - Registration

public func registerProviderFactories() {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->LoggedInComponent->OffGameComponent") { component in
        return OffGameDependency19a483c7a4199f31827fProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->LoggedInComponent->RandomWinComponent") { component in
        return RandomWinDependencydf572f38235b3dd4a3ffProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->LoggedInComponent->TicTacToeComponent") { component in
        return TicTacToeDependency116f7b2429d569089340Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->LoggedOutComponent") { component in
        return LoggedOutDependencyacada53ea78d270efa2fProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->LoggedInComponent->OffGameComponent->BasicScoreBoard") { component in
        return BasicScoreBoardDependency699de4e23ddb78e22b46Provider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->LoggedInComponent") { component in
        return LoggedInDependency637c07bfce1b5ccf0a6eProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent") { component in
        return EmptyDependencyProvider(component: component)
    }
    
}

// MARK: - Providers

private class OffGameDependency19a483c7a4199f31827fBaseProvider: OffGameDependency {
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
/// ^->RootComponent->LoggedInComponent->OffGameComponent
private class OffGameDependency19a483c7a4199f31827fProvider: OffGameDependency19a483c7a4199f31827fBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent as! LoggedInComponent)
    }
}
private class RandomWinDependencydf572f38235b3dd4a3ffBaseProvider: RandomWinDependency {
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
/// ^->RootComponent->LoggedInComponent->RandomWinComponent
private class RandomWinDependencydf572f38235b3dd4a3ffProvider: RandomWinDependencydf572f38235b3dd4a3ffBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent as! LoggedInComponent)
    }
}
private class TicTacToeDependency116f7b2429d569089340BaseProvider: TicTacToeDependency {
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
/// ^->RootComponent->LoggedInComponent->TicTacToeComponent
private class TicTacToeDependency116f7b2429d569089340Provider: TicTacToeDependency116f7b2429d569089340BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent as! LoggedInComponent)
    }
}
private class LoggedOutDependencyacada53ea78d270efa2fBaseProvider: LoggedOutDependency {
    var loggedOutListener: LoggedOutListener {
        return rootComponent.loggedOutListener
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->LoggedOutComponent
private class LoggedOutDependencyacada53ea78d270efa2fProvider: LoggedOutDependencyacada53ea78d270efa2fBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(rootComponent: component.parent as! RootComponent)
    }
}
private class BasicScoreBoardDependency699de4e23ddb78e22b46BaseProvider: BasicScoreBoardDependency {
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
/// ^->RootComponent->LoggedInComponent->OffGameComponent->BasicScoreBoard
private class BasicScoreBoardDependency699de4e23ddb78e22b46Provider: BasicScoreBoardDependency699de4e23ddb78e22b46BaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(loggedInComponent: component.parent.parent as! LoggedInComponent)
    }
}
private class LoggedInDependency637c07bfce1b5ccf0a6eBaseProvider: LoggedInDependency {
    var loggedInPresenter: LoggedInPresentable {
        return rootComponent.loggedInPresenter
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->LoggedInComponent
private class LoggedInDependency637c07bfce1b5ccf0a6eProvider: LoggedInDependency637c07bfce1b5ccf0a6eBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(rootComponent: component.parent as! RootComponent)
    }
}
