//
//  FifteenGameModel.swift
//  FifteenGame
//
//  Created by Dmitry on 27.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

class FifteenGameModel {
    
    //
    // MARK: - Constants
    //
    private let shuffleIterationsCount = 150
    
    //
    // MARK: - Public Interface
    //
    struct ItemPos: Equatable {
        var row: Int
        var column: Int
    }
    
    let fieldSize: Int
    
    init(size: Int, randomGenerator: RandomNumberGenerating) {
        precondition(size > 1)
        
        fieldSize = size
        cells = Array<Int>(repeating: emptyCell, count: size * size)
        self.randomGenerator = randomGenerator
        
        arrange()
    }
    
    convenience init(size: Int) {
        self.init(size: size, randomGenerator: RandomNumberGenerator())
    }
    
    func enumerateItems() -> [(Int, ItemPos)] {
        return cells.filter { $0 != self.emptyCell }
                    .map { ($0, self.position(for: $0)!) }
    }
    
    func arrange() {
        cells = buildArrangedOrder()
    }
    
    func shuffle() {
        arrange()
        
        var counter = shuffleIterationsCount
        var emptyCellPos = ItemPos(row: fieldSize - 1, column: fieldSize - 1)
        var excludePos = ItemPos(row: fieldSize, column: fieldSize)
        
        while counter > 0 {
            
            let (item, newPos) = getRandomNeighbor(for: emptyCellPos, exclude: excludePos)
            excludePos = emptyCellPos
            
            setItem(item, at: emptyCellPos)
            setItem(emptyCell, at: newPos)
            
            emptyCellPos = newPos
            counter -= 1
        }
    }
    
    func tryMove(item: Int) -> ItemPos? {
        
        guard item != emptyCell, let position = position(for: item) else {
            return nil
        }
        
        let leftPos = ItemPos(row: position.row, column: position.column - 1)
        let rightPos = ItemPos(row: position.row, column: position.column + 1)
        let topPos = ItemPos(row: position.row - 1, column: position.column)
        let bottomPos = ItemPos(row: position.row + 1, column: position.column)
        
        let posList = [leftPos, rightPos, topPos, bottomPos]
        for testedPos in posList {
            
            if isEmptyCell(at: testedPos) {
                setItem(item, at: testedPos)
                setItem(emptyCell, at: position)
                return testedPos
            }
        }
        
        return nil
    }
    
    
    func position(for item: Int) -> ItemPos? {
        
        guard let index = cells.firstIndex(of: item) else {
            return nil
        }
        
        return ItemPos(row: index / fieldSize, column: index % fieldSize)
    }
    
    func checkFinished() -> Bool {
        let expectedOrder = buildArrangedOrder()
        return cells == expectedOrder
    }
    
    //
    // MARK: - Private Logic
    //
    
    private let emptyCell = 0
    private var cells: [Int]
    
    private let randomGenerator: RandomNumberGenerating
    
    private func item(at position: ItemPos) -> Int {
        return cells[position.row * fieldSize + position.column]
    }
    
    private func setItem(_ item: Int, at position: ItemPos) {
        cells[position.row * fieldSize + position.column] = item
    }
    
    private func getRandomNeighbor(for position: ItemPos, exclude: ItemPos) -> (Int, ItemPos) {
        
        let leftPos = ItemPos(row: position.row, column: position.column - 1)
        let rightPos = ItemPos(row: position.row, column: position.column + 1)
        let topPos = ItemPos(row: position.row - 1, column: position.column)
        let bottomPos = ItemPos(row: position.row + 1, column: position.column)
        
        let posList = [leftPos, rightPos, topPos, bottomPos]
            .filter(isValidPosition)
            .filter({$0 != exclude})
        
        let resultPos = posList[randomGenerator.nextInt() % posList.count]
        return (item(at: resultPos), resultPos)
    }
    
    private func isValidPosition(_ position: ItemPos) -> Bool {
        return position.column < fieldSize && position.column >= 0 &&
            position.row < fieldSize && position.row >= 0
    }
    
    private func isEmptyCell(at position: ItemPos) -> Bool {
        guard isValidPosition(position) else {
            return false
        }
        return item(at: position) == emptyCell
    }
    
    private func buildArrangedOrder() -> [Int] {
        return Array(1...(fieldSize * fieldSize - 1)) + [emptyCell]
    }
}
