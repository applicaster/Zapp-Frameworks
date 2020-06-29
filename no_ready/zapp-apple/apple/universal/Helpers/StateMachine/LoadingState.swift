//
//  LoadingState.swift
//  Zapp-App
//
//  Created by Anton Kononenko on 26/06/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import os.log

public class LoadingState {
    /// Readable name for debugging
    var readableName: String?

    /// General completion handler of the loading state. Containens `successCompletion` and `failCompletion`
    public var stateHandler: StateHandler?

    /// Completion success handler of the loading state
    var successCompletion: StateCallBack?

    /// Completion fail handler of the loading state
    var failCompletion: StateCallBack?

    /// Parameter defines if state should ignore auto invocation call in case it is dependant state.
    var willSkipingStateAutoInvocation: Bool = false

    /// Checks if Loading state machine objects are equal
    ///
    /// - Parameters:
    ///   - from: first state machine instance to compare
    ///   - to: second state machine instance to compare
    /// - Returns: True if both object has same LoadingStateMachineGroups enum value, otherwise false
    static func == (from: LoadingState,
                    to: LoadingState) -> Bool {
        return from.name == to.name && from.dependantStates == to.dependantStates
    }

    /// Defines state loading status
    private(set) var loadingState: LoadingStateTypes = .initial {
        didSet {
            os_log("STATE %@ LOADING_STATE: %@ \n", readableName ?? name, loadingState.toString())
        }
    }

    /// Delegate instance uses to pass information when Loading state changed loading status or finished work
    var delegate: LoadingStateMachineDelegate?

    /// State dependancies that will be called after current state will finish it's work
    var dependantStates: [String] = []

    /// Type of the loading state
    let name = UUID().uuidString

    /// Create new state instance with state type and dependant states
    ///
    /// - Parameters:
    ///   - name: State type
    ///   - dependantStates: State dependancies that will be called after current state will finish it's work
    public init(dependantStatesIds: [String] = []) {
        if dependantStatesIds.count > 0 {
            let filteredDependecies = removeDependancyOnSelf(dependantStatesIds: dependantStates)
            dependantStates = removeDuplicationDependancies(dependantStatesIds: filteredDependecies)
        }
    }

    /// Remove dependancy on same state from current state
    ///
    /// - Parameter dependantStates: Array of dependancies states to check
    /// - Returns: return filtered dependencies list without state duplication of Self State
    func removeDependancyOnSelf(dependantStatesIds: [String]) -> [String] {
        return dependantStates.filter { $0 != name }
    }

    /// Remove duplication from dependecies if was added, we are not allowing to have same dependency twice in a list
    ///
    /// - Parameter dependantStates: Array of dependancies states to check
    /// - Returns:  return filtered dependencies list duplication state
    func removeDuplicationDependancies(dependantStatesIds: [String]) -> [String] {
        var retVal: [String: Bool] = [:]

        return dependantStatesIds.filter {
            retVal.updateValue(true, forKey: $0) == nil
        }
    }

    /// Start load state if state has not dependant states
    @discardableResult func setStartLoadState() -> Bool {
        if dependantStates.count == 0,
            loadingState == .initial {
            loadState()
            return true
        }
        return false
    }

    /// Force load state
    private func loadState() {
        if let stateHandler = stateHandler {
            loadingState = .loading
            stateHandler({ [weak self] in
                if let weakSelf = self {
                    weakSelf.loadingState = .success
                    weakSelf.successCompletion?()
                    weakSelf.delegate?.stateDidUpdated(state: weakSelf)
                }

            }) { [weak self] in
                if let weakSelf = self {
                    weakSelf.loadingState = .failed
                    weakSelf.failCompletion?()
                    weakSelf.delegate?.stateDidUpdated(state: weakSelf)
                }
            }
        }
    }

    /// Pass inforamtion that other state finish its job
    ///
    /// - Parameter stateType: state that finished job
    func stateDidFinishedJob(stateId: String) {
        if name != stateId,
            dependantStates.contains(stateId),
            willSkipingStateAutoInvocation == false {
            var isDependantStatesReady = true

            for currentStateId in dependantStates {
                if let dependentState = delegate?.state(by: currentStateId),
                    dependentState.loadingState.isStateFinishedTask() == false {
                    isDependantStatesReady = false
                    break
                } else if delegate?.state(by: currentStateId) == nil {
                    isDependantStatesReady = false
                    break
                }
            }

            if isDependantStatesReady == true,
                loadingState == .initial {
                loadState()
            }
        }
    }
}
