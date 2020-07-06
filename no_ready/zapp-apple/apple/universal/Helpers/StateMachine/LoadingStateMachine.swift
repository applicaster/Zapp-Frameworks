//
//  LoadingStateMachine.swift
//  Zapp-App
//
//  Created by Anton Kononenko on 22/06/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation

public class LoadingStateMachine: LoadingStateMachineDelegate {
    
    var dataSource:LoadingStateMachineDataSource?
    
    public init(dataSource:LoadingStateMachineDataSource,
         withStates:[LoadingState]) {
        states = withStates
        states.forEach{ $0.delegate = self }
        self.dataSource = dataSource
    }
    
    let defaultCenter = NotificationCenter.default

    var states:[LoadingState] = []
    var applicastionLoadingState:LoadingStateTypes = .initial
    
    public func startStatesInvocation() {
        applicastionLoadingState = .loading
        forceStartAllIndependantsState()
    }
 
    func forceStartAllIndependantsState() {
        states.forEach{ $0.setStartLoadState()}
    }
    
    func updateAllStates(state:LoadingState) {
        states.forEach{ $0.stateDidFinishedJob(stateId: state.name)}
    }
    
    public func stateDidUpdated(state:LoadingState) {
        if state.loadingState == .failed &&
            applicastionLoadingState.isStateFinishedTask() == false {
            applicastionLoadingState = .failed
            dataSource?.stateMachineFinishedWork(with: .failed)
        }
        
        if applicastionLoadingState != .failed {
            updateAllStates(state: state)
        }

        if applicastionLoadingState != .success,
            allStateFinishedTask() {
            self.applicastionLoadingState = .success
            self.dataSource?.stateMachineFinishedWork(with: .success)
        }
    }
    
    func allStateFinishedTask() -> Bool {
        return states.filter { $0.loadingState == .success }.count == states.count
    }
    
    public func state(by stateId:String) -> LoadingState? {
        return states.first(where: { $0.name == stateId })
    }
    
    func setSkipingStateAutoInvocation(for stateId:String) {
        guard let currentState = state(by:stateId) else {
            return
        }
        currentState.willSkipingStateAutoInvocation = true
    }
}

