//
//  FifteenGameViewModelTests.swift
//  LearnSwiftUITests
//
//  Created by Dmitry Bordyug on 31.01.2022.
//

import XCTest
import Combine

@testable import GameOfFifteen

class FifteenGameViewModelTests: XCTestCase {
    
    private static let fieldSize = 4
    
    private var testedViewModel: FifteenGameViewModel!
    private var gameLogicMock: FifteenGameLogicMock!
    private var timerMock: GameTimerMock!
    private var randomGeneratorMock: RandomNumberGenerating!
    
    private var tokens = Set<AnyCancellable>()

    override func setUp() {
        var randomGenerator = RandomGeneratorMock()
        randomGenerator.nextValue = 3
        randomGeneratorMock = randomGenerator
        
        gameLogicMock = FifteenGameLogicMock(size: Self.fieldSize, randomGenerator: randomGeneratorMock)
        timerMock = GameTimerMock()
        testedViewModel = FifteenGameViewModel(gameLogic: gameLogicMock,
                                               timer: timerMock,
                                               hapticFeedback: HapticFeedbackMock())
    }

    override func tearDown() {
        testedViewModel = nil
        gameLogicMock = nil
        timerMock = nil
        
        tokens.removeAll()
    }

    func testModelInitialization() throws {
        
        // Assert
        XCTAssertEqual(testedViewModel.moveCount, 0)
        XCTAssertEqual(testedViewModel.timeTitle, "00:00:00")
        XCTAssertEqual(testedViewModel.showWinnerTime, false)
        XCTAssertEqual(testedViewModel.isNewGameAlertShown, false)
        
        let cellList = testedViewModel.cellList
        let fieldSize = testedViewModel.fieldSize
        
        var counter = 1
        
        for cell in cellList {
            XCTAssertEqual(cell.id, counter)
            XCTAssertEqual(cell.title, "\(cell.id)")
            
            let expectedPos = FifteenGameViewModel.CellPos(row: (counter - 1) / fieldSize,
                                                           column: (counter - 1) % fieldSize)
            
            XCTAssertEqual(cell.pos, expectedPos)
            
            counter += 1
        }
    }
    
    func testProcessStartDidTap() {

        // Arrange
        let initialItems = testedViewModel.cellList

        // Act
        testedViewModel.processStartDidTap()

        // Assert
        XCTAssertEqual(testedViewModel.moveCount, 0)
        XCTAssertEqual(testedViewModel.timeTitle, "00:00:00")
        XCTAssertEqual(testedViewModel.showWinnerTime, false)
        XCTAssertEqual(testedViewModel.isNewGameAlertShown, false)

        XCTAssertEqual(timerMock.startCallsCount, 1)

        // Items must be shuffled
        XCTAssertNotEqual(testedViewModel.cellList, initialItems)
    }
    
    func testProcessNewGameAlertOkDidTap() {
        // Arrange
        let initialItems = testedViewModel.cellList

        // Act
        testedViewModel.processNewGameAlertOkDidTap()

        // Assert
        XCTAssertEqual(testedViewModel.moveCount, 0)
        XCTAssertEqual(testedViewModel.timeTitle, "00:00:00")
        XCTAssertEqual(testedViewModel.showWinnerTime, false)
        XCTAssertEqual(testedViewModel.isNewGameAlertShown, false)

        XCTAssertEqual(timerMock.startCallsCount, 1)

        // Items must be shuffled
        XCTAssertNotEqual(testedViewModel.cellList, initialItems)
    }
    
    func testProcessStartDidTapShouldStopRunningTimer() {
        
        // Arrange
        timerMock.startTimer()
        
        // Act
        testedViewModel.processStartDidTap()
        
        // Assert
        XCTAssertEqual(timerMock.startCallsCount, 2)
        XCTAssertEqual(timerMock.stopCallsCount, 1)
    }
    
    func testProcessStartDidTapShouldShowNewGameAlertIfUserMadeMoves() {
        
        // Arrange
        testedViewModel.processCellDidTap(cellId: 12, animationDelay: 0) // make one move
        
        // Act
        testedViewModel.processStartDidTap()
        
        // Assert
        XCTAssertTrue(testedViewModel.isNewGameAlertShown)
    }
    
    func testProcessCellDidTapWithLockedCells() {
        
        // Arrange
        let initialItems = testedViewModel.cellList
        
        // Act
        var indexSet = Set(0...(Self.fieldSize * Self.fieldSize - 1))
        indexSet.remove(12)
        indexSet.remove(15)
        
        for itemId in indexSet {
            testedViewModel.processCellDidTap(cellId: itemId, animationDelay: 0)
            
            // Assert
            XCTAssertEqual(testedViewModel.moveCount, 0)
            XCTAssertEqual(testedViewModel.cellList, initialItems)
            XCTAssertEqual(testedViewModel.showWinnerTime, false)
        }
    }
    
    func testProcessCellDidTapWithOpenedCells() {
        
        // Arrange
        let cells0 = testedViewModel.cellList
        
        // Act
        testedViewModel.processCellDidTap(cellId: 15, animationDelay: 0)
        let cells1 = testedViewModel.cellList
        
        testedViewModel.processCellDidTap(cellId: 11, animationDelay: 0)
        let cells2 = testedViewModel.cellList
        
        testedViewModel.processCellDidTap(cellId: 12, animationDelay: 0)
        let cells3 = testedViewModel.cellList
        
        testedViewModel.processCellDidTap(cellId: 8, animationDelay: 0)
        let cells4 = testedViewModel.cellList
        
        testedViewModel.processCellDidTap(cellId: 7, animationDelay: 0)
        let cellsFinal = testedViewModel.cellList
        
        let pos15 = cellsFinal.first { $0.id == 15 }.map { $0.pos }
        let pos11 = cellsFinal.first { $0.id == 11 }.map { $0.pos }
        let pos12 = cellsFinal.first { $0.id == 12 }.map { $0.pos }
        let pos8 = cellsFinal.first { $0.id == 8 }.map { $0.pos }
        let pos7 = cellsFinal.first { $0.id == 7 }.map { $0.pos }
        
        // Assert
        XCTAssertEqual(testedViewModel.moveCount, 5)
        
        XCTAssertNotEqual(cells1, cells0)
        XCTAssertNotEqual(cells2, cells1)
        XCTAssertNotEqual(cells3, cells2)
        XCTAssertNotEqual(cells4, cells3)
        XCTAssertNotEqual(cellsFinal, cells4)
        
        XCTAssertEqual(pos15!, .init(row: 3, column: 3))
        XCTAssertEqual(pos11!, .init(row: 3, column: 2))
        XCTAssertEqual(pos12!, .init(row: 2, column: 2))
        XCTAssertEqual(pos8!, .init(row: 2, column: 3))
        XCTAssertEqual(pos7!, .init(row: 1, column: 3))
    }
    
    func testProcessCellDidTapChecksFinish() {
        
        // Arrange
        let winSignal = XCTestExpectation()
        
        testedViewModel
            .winPublisher
            .sink { _ in
                winSignal.fulfill()
            }
            .store(in: &tokens)
        
        // Act
        testedViewModel.processCellDidTap(cellId: 12, animationDelay: 0)
        testedViewModel.processCellDidTap(cellId: 12, animationDelay: 1)
        
        // Assert
        XCTAssertTrue(testedViewModel.showWinnerTime)
        XCTAssertEqual(timerMock.stopCallsCount, 1)
        
        wait(for: [winSignal], timeout: 3)
    }
}
