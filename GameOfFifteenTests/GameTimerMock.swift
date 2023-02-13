//
//  GameTimerMock.swift
//  LearnSwiftUITests
//
//  Created by Dmitry Bordyug on 01.02.2022.
//

import Foundation
@testable import GameOfFifteen

class GameTimerMock: GameTimer {
    
    private(set) var startCallsCount = 0
    private(set) var stopCallsCount = 0
    
    override func startTimer() {
        startCallsCount += 1
        super.startTimer()
    }
    
    override func stopTimer() {
        stopCallsCount += 1
        super.stopTimer()
    }
}
