//
//  FifteenGameLogicMock.swift
//  LearnSwiftUITests
//
//  Created by Dmitry Bordyug on 01.02.2022.
//

import Foundation
@testable import GameOfFifteen

class FifteenGameLogicMock: FifteenGameModel {
    
    private(set) var shuffleCallsCount = 0
    
    var ignoreShuffle = false
    
    override func shuffle() {
        shuffleCallsCount += 1
        
        guard !ignoreShuffle else { return }
        super.shuffle()
    }
}
