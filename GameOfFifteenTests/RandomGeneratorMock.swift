//
//  RandomGeneratorMock.swift
//  GameOfFifteenTests
//
//  Created by Dmitry Bordyug on 14.02.2023.
//

import Foundation
@testable import GameOfFifteen

struct RandomGeneratorMock: RandomNumberGenerating {
    
    var nextValue: Int = 0
    
    func nextInt() -> Int {
        return nextValue
    }
    
}
