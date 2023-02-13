//
//  RandomNumberGenerator.swift
//  GameOfFifteen
//
//  Created by Dmitry Bordyug on 14.02.2023.
//

import Foundation

protocol RandomNumberGenerating {
    func nextInt() -> Int
}

struct RandomNumberGenerator: RandomNumberGenerating {
    func nextInt() -> Int {
        return Int.random(in: 0...Int.max)
    }
}
