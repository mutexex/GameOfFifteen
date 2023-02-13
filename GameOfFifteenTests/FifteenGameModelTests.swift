//
//  FifteenGameModelTests.swift
//  LearnSwiftUITests
//
//  Created by Dmitry Bordyug on 30.01.2022.
//

import XCTest
@testable import GameOfFifteen

class FifteenGameModelTests: XCTestCase {
    
    fileprivate typealias ItemPos = FifteenGameModel.ItemPos

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModelInitialization() throws {
        
        for fieldSize in 2...10 {
            
            // Arrange
            let model = FifteenGameModel(size: fieldSize)
            let extectedList = Array(1...(fieldSize * fieldSize - 1))
            
            // Act
            let itemList = model.enumerateItems().map { $0.0 }
            
            // Assert
            XCTAssertEqual(model.fieldSize, fieldSize)
            XCTAssertEqual(itemList, extectedList)
        }
    }
    
    func testEnumerateItems() throws {
        
        for fieldSize in 2...10 {
            
            // Arrange
            let model = FifteenGameModel(size: fieldSize)
            
            // Act
            let items = model.enumerateItems()
            
            // Assert
            for (itemId, itemPos) in items {
                let index = itemId - 1
                let expectedColumn = index % fieldSize
                let expectedRow = index / fieldSize
                
                XCTAssertEqual(itemPos.column, expectedColumn)
                XCTAssertEqual(itemPos.row, expectedRow)
            }
        }
    }
    
    func testArrange() {

        // Arrange
        let fieldSize = 4
        let model = FifteenGameModel(size: fieldSize)
        [12, 8, 7, 6, 5, 1].forEach {
            _ = model.tryMove(item: $0)
        }

        // Act
        model.arrange()
        
        // Assert
        XCTAssertTrue(model.checkFinished())
    }
    
    func testShuffle() {

        let fieldSize = 4

        // Arrange
        var randomGenerator = RandomGeneratorMock()
        randomGenerator.nextValue = 5
        
        let model = FifteenGameModel(size: fieldSize, randomGenerator: randomGenerator)
        
        let arrangedCells = model.enumerateItems().map { $0.0 }
        let initialSet = Set(arrangedCells)

        // Act
        model.shuffle()
        
        // Assert
        let shuffledCells = model.enumerateItems().map { $0.0 }
        let shuffledSet = Set(shuffledCells)

        XCTAssertNotEqual(shuffledCells, arrangedCells)
        XCTAssertEqual(initialSet, shuffledSet)
    }
    
    func testTryMoveReturnsNil() {
        
        // Arrange
        let fieldSize = 4
        let model = FifteenGameModel(size: fieldSize)
        
        var indexSet = Set(0...(fieldSize * fieldSize - 1))
        indexSet.remove(12) // Is able to move thus remove from set
        indexSet.remove(15) // Is able to move thus remove from set
        
        // Act
        for index in indexSet {
            let moveResult = model.tryMove(item: index)
            
            // Assert
            XCTAssertNil(moveResult)
        }
    }
    
    func testTryMove() {
        
        let fieldSize = 4
        
        // Arrange
        let model = FifteenGameModel(size: fieldSize)
        
        // Act
        let pos1 = model.tryMove(item: 15)
        let pos2 = model.tryMove(item: 11)
        let pos3 = model.tryMove(item: 10)
        let pos4 = model.tryMove(item: 10)
        let pos5 = model.tryMove(item: 12)
        
        // Assert
        XCTAssertNotNil(pos1)
        XCTAssertNotNil(pos2)
        XCTAssertNotNil(pos3)
        XCTAssertNotNil(pos4)
        XCTAssertNotNil(pos5)
        
        XCTAssertEqual(pos1!, .init(row: 3, column: 3))
        XCTAssertEqual(pos2!, .init(row: 3, column: 2))
        XCTAssertEqual(pos3!, .init(row: 2, column: 2))
        XCTAssertEqual(pos4!, .init(row: 2, column: 1))
        XCTAssertEqual(pos5!, .init(row: 2, column: 2))
    }
    
    func testPositionForItem() {
        
        let fieldSize = 4
        
        // Arrange
        let model = FifteenGameModel(size: fieldSize)
        
        // Act
        let positionForIncorrectItem = model.position(for: 17)
        let positionForItem1 = model.position(for: 1)
        let positionForItem4 = model.position(for: 4)
        let positionForItem10 = model.position(for: 10)
        let positionForItem15 = model.position(for: 15)
        let positionForEmptyCell = model.position(for: 0)
        
        // Assert
        XCTAssertNil(positionForIncorrectItem)
        XCTAssertEqual(positionForItem1, ItemPos(row: 0, column: 0))
        XCTAssertEqual(positionForItem4, ItemPos(row: 0, column: 3))
        XCTAssertEqual(positionForItem10, ItemPos(row: 2, column: 1))
        XCTAssertEqual(positionForItem15, ItemPos(row: 3, column: 2))
        XCTAssertEqual(positionForEmptyCell, ItemPos(row: 3, column: 3))
    }
    
    func testCheckFinishedReturnsTrue() {

        let fieldSize = 4
        
        // Arrange
        let model = FifteenGameModel(size: fieldSize)

        // Act
        let isFinished = model.checkFinished()

        // Assert
        XCTAssertTrue(isFinished)
    }
    
    func testCheckFinishedReturnsFalse() {

        let fieldSize = 4
        
        // Arrange
        var randomGenerator = RandomGeneratorMock()
        randomGenerator.nextValue = 3
        let model = FifteenGameModel(size: fieldSize, randomGenerator: randomGenerator)
        model.shuffle()

        // Act
        let isFinished = model.checkFinished()

        // Assert
        XCTAssertFalse(isFinished)
    }
}
