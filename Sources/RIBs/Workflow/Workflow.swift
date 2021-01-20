//
//  Copyright (c) 2021. Adam Share
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

import Combine

/// Defines the base class for a sequence of steps that execute a flow through the application RIB tree.
///
/// At each step of a `Workflow` is a pair of value and actionable item. The value can be used to make logic decisions.
/// The actionable item is invoked to perform logic for the step. Typically the actionable item is the `Interactor` of a
/// RIB.
///
/// A workflow should always start at the root of the tree.
open class Workflow<ActionableItemType> {

    /// Called when the last step publisher is completed.
    ///
    /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
    /// The default implementation does nothing.
    open func didComplete() {
        // No-op
    }

    /// Called when the `Workflow` is forked.
    ///
    /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
    /// The default implementation does nothing.
    open func didFork() {
        // No-op
    }

    /// Called when the last step publisher is has error.
    ///
    /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
    /// The default implementation does nothing.
    open func didReceiveError(_ error: Error) {
        // No-op
    }

    /// Initializer.
    public init() {}

    /// Execute the given closure as the root step.
    ///
    /// - parameter onStep: The closure to execute for the root step.
    /// - returns: The next step.
    public final func onStep<NextActionableItemType, NextValueType, NextFailure: Error>(_ onStep: @escaping (ActionableItemType) -> AnyPublisher<(NextActionableItemType, NextValueType), NextFailure>) -> Step<ActionableItemType, NextActionableItemType, NextValueType, NextFailure> {
        return Step(workflow: self, publisher: subject.first())
            .onStep { (actionableItem: ActionableItemType, _) -> AnyPublisher<(NextActionableItemType, NextValueType), NextFailure> in
                onStep(actionableItem)
            }
    }

    /// Subscribe and start the `Workflow` sequence.
    ///
    /// - parameter actionableItem: The initial actionable item for the first step.
    /// - returns: The disposable of this workflow.
    public final func sink(_ actionableItem: ActionableItemType) -> AnyCancellable {
        guard compositeCancellable.count > 0 else {
            assertionFailure("Attempt to subscribe to \(self) before it is comitted.")
            return AnyCancellable {}
        }

        subject.send((actionableItem, ()))
        return AnyCancellable { self.compositeCancellable.forEach { $0.cancel() } }
    }

    // MARK: - Private

    private let subject = PassthroughSubject<(ActionableItemType, ()), Never>()
    private var didInvokeComplete = false

    /// The composite disposable that contains all subscriptions including the original workflow
    /// as well as all the forked ones.
    fileprivate var compositeCancellable: [AnyCancellable] = []

    fileprivate func didCompleteIfNotYet() {
        // Since a workflow may be forked to produce multiple subscribed Rx chains, we should
        // ensure the didComplete method is only invoked once per Workflow instance. See `Step.commit`
        // on why the side-effects must be added at the end of the Rx chains.
        guard !didInvokeComplete else {
            return
        }
        didInvokeComplete = true
        didComplete()
    }
}

public extension Workflow where ActionableItemType == Void {

    final func sink() -> AnyCancellable {
        return sink(())
    }
}

/// Defines a single step in a `Workflow`.
///
/// A step may produce a next step with a new value and actionable item, eventually forming a sequence of `Workflow`
/// steps.
///
/// Steps are asynchronous by nature.
open class Step<WorkflowActionableItemType, ActionableItemType, ValueType, Failure: Error> {

    private let workflow: Workflow<WorkflowActionableItemType>
    private var publisher: AnyPublisher<(ActionableItemType, ValueType), Failure>

    fileprivate init<P: Publisher>(workflow: Workflow<WorkflowActionableItemType>, publisher: P) where P.Output == (ActionableItemType, ValueType), P.Failure == Failure {
        self.workflow = workflow
        self.publisher = publisher.eraseToAnyPublisher()
    }

    /// Executes the given closure for this step.
    ///
    /// - parameter onStep: The closure to execute for the `Step`.
    /// - returns: The next step.
    public final func onStep<NextActionableItemType, NextValueType, NextFailure: Error>(_ onStep: @escaping (ActionableItemType, ValueType) -> AnyPublisher<(NextActionableItemType, NextValueType), NextFailure>, mapError: @escaping (Failure) -> NextFailure) -> Step<WorkflowActionableItemType, NextActionableItemType, NextValueType, NextFailure> {
        let confinedNextStep =
            publisher
                .map { (actionableItem, value) -> AnyPublisher<(Bool, ActionableItemType, ValueType), Failure> in
                    // We cannot use generic constraint here since Swift requires constraints be
                    // satisfied by concrete types, preventing using protocol as actionable type.
                    if let interactor = actionableItem as? Interactable {
                        return interactor
                            .isActiveStream
                            .map { (isActive: Bool) -> (Bool, ActionableItemType, ValueType) in
                                (isActive, actionableItem, value)
                            }
                            .mapError()
                            .eraseToAnyPublisher()
                    } else {
                        return Just((true, actionableItem, value)).mapError().eraseToAnyPublisher()
                    }
                }
                .switchToLatest()
                .filter { (isActive: Bool, _, _) -> Bool in
                    isActive
                }
                .first()
                .map { (_, actionableItem: ActionableItemType, value: ValueType) -> AnyPublisher<(NextActionableItemType, NextValueType), NextFailure> in
                    onStep(actionableItem, value)
                }
                .mapError(mapError)
                .switchToLatest()
                .first()
                .share()

        return Step<WorkflowActionableItemType, NextActionableItemType, NextValueType, NextFailure>(workflow: workflow, publisher: confinedNextStep)
    }

    public final func onStep<NextActionableItemType, NextValueType>(_ transform: @escaping (ActionableItemType, ValueType) -> AnyPublisher<(NextActionableItemType, NextValueType), Failure>) -> Step<WorkflowActionableItemType, NextActionableItemType, NextValueType, Failure> {
        return onStep(transform) { error -> Failure in error }
    }

    /// Executes the given closure when the `Step` produces an error.
    ///
    /// - parameter onError: The closure to execute when an error occurs.
    /// - returns: This step.
    public final func onError(_ onError: @escaping ((Failure) -> Void)) -> Step<WorkflowActionableItemType, ActionableItemType, ValueType, Failure> {
        publisher = publisher
            .handleEvents(receiveFailure: onError)
            .eraseToAnyPublisher()
        return self
    }

    /// Commit the steps of the `Workflow` sequence.
    ///
    /// - returns: The committed `Workflow`.
    @discardableResult
    public final func commit() -> Workflow<WorkflowActionableItemType> {
        // Side-effects must be chained at the last publisher sequence, since errors and complete
        // events can be emitted by any publishers on any steps of the workflow.
        let disposable = publisher
            .sink(receiveFailure: workflow.didReceiveError, receiveFinished: workflow.didCompleteIfNotYet)
        workflow.compositeCancellable.append(disposable)
        return workflow
    }

    /// Convert the `Workflow` into an obseravble.
    ///
    /// - returns: The publisher representation of this `Workflow`.
    public final func eraseToAnyPublisher() -> AnyPublisher<(ActionableItemType, ValueType), Failure> {
        return publisher
    }
}

public extension Step where Failure == Never {
    final func onStep<NextActionableItemType, NextValueType, NextFailure>(_ transform: @escaping (ActionableItemType, ValueType) -> AnyPublisher<(NextActionableItemType, NextValueType), NextFailure>) -> Step<WorkflowActionableItemType, NextActionableItemType, NextValueType, NextFailure> {
        return onStep(transform) { error -> NextFailure in }
    }

    final func onStep<NextActionableItemType, NextValueType>(_ transform: @escaping (ActionableItemType, ValueType) -> AnyPublisher<(NextActionableItemType, NextValueType), Never>) -> Step<WorkflowActionableItemType, NextActionableItemType, NextValueType, Never> {
        return onStep(transform) { error -> Never in }
    }
}

/// `Workflow` related obervable extensions.
public extension Publisher {

    /// Fork the step from this obervable.
    ///
    /// - parameter workflow: The workflow this step belongs to.
    /// - returns: The newly forked step in the workflow. `nil` if this publisher does not conform to the required
    ///   generic type of (ActionableItemType, ValueType).
    func fork<WorkflowActionableItemType, ActionableItemType, ValueType, Failure>(_ workflow: Workflow<WorkflowActionableItemType>) -> Step<WorkflowActionableItemType, ActionableItemType, ValueType, Failure> where Self.Output == (ActionableItemType, ValueType), Self.Failure == Failure {
        workflow.didFork()
        return Step(workflow: workflow, publisher: self)
    }
}

/// `Workflow` related `AnyCancellable` extensions.
public extension AnyCancellable {

    /// Cancel the subscription when the given `Workflow` is cancelled.
    ///
    /// When using this composition, the subscription closure may freely retain the workflow itself, since the
    /// subscription closure is cancelled once the workflow is cancelled, thus releasing the retain cycle before the
    /// `Workflow` needs to be deallocated.
    ///
    /// - note: This is the preferred method when trying to confine a subscription to the lifecycle of a `Workflow`.
    ///
    /// - parameter workflow: The workflow to cancel the subscription with.
    func cancelWith<ActionableItemType>(worflow: Workflow<ActionableItemType>) {
        worflow.compositeCancellable.append(self)
    }
}
