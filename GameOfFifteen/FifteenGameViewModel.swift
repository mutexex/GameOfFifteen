//
//  FifteenGameViewModel.swift
//  LearnSwiftUI
//
//  Created by Dmitry Bordyug on 25.01.2022.
//

import Foundation
import Combine

class FifteenGameViewModel: ObservableObject {
    
    typealias CellPos = FifteenGameModel.ItemPos
    
    struct CellModel: Identifiable, Equatable {
        let id: Int
        let title: String
        let pos: FifteenGameModel.ItemPos
    }
    
    // MARK: - Properties
    
    static let defaultFieldSize = 4
    
    var fieldSize: Int {
        return gameLogic.fieldSize
    }
    
    @Published private(set) var cellList: [CellModel] = []
    
    @Published private(set) var moveCount: Int = 0
    
    @Published private(set) var timeTitle = "00:00:00"
    
    @Published private(set) var showWinnerTime = false
    
    @Published var isNewGameAlertShown = false
    
    let winPublisher = PassthroughSubject<Void, Never>()
    
    private let gameLogic: FifteenGameModel
    private let timer: GameTimerProtocol
    private let hapticFeedback: HapticFeedback
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.maximumUnitCount = 0
        formatter.zeroFormattingBehavior = DateComponentsFormatter.ZeroFormattingBehavior.pad
        return formatter
    }()
    
    // MARK: - Initialization
    
    init(gameLogic: FifteenGameModel,
         timer: GameTimerProtocol,
         hapticFeedback: HapticFeedback) {
        
        self.timer = timer
        self.gameLogic = gameLogic
        self.hapticFeedback = hapticFeedback
        updateCellList()
    }
    
    convenience init() {
        let logic = FifteenGameModel(size: Self.defaultFieldSize)
        let timer = GameTimer()
        
        self.init(gameLogic: logic, timer: timer, hapticFeedback: HapticFeedbackGenerator.shared)
    }
    
    deinit {
        timer.stopTimer()
    }
    
    // MARK: - Public Interface
    
    func processNewGameAlertOkDidTap() {
        startNewGame()
    }
    
    func processStartDidTap() {
        if moveCount > 0 && !gameLogic.checkFinished() {
            isNewGameAlertShown = true
        } else {
            startNewGame()
        }
    }
    
    func processCellDidTap(cellId: Int, animationDelay: TimeInterval) {
        
        guard let _ = gameLogic.tryMove(item: cellId) else {
            return
        }
        
        updateCellList()
        moveCount += 1
        
        let isFinished = gameLogic.checkFinished()
        
        if isFinished {
            showWinnerTime = true
            timer.stopTimer()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) { [weak self] in
            if isFinished {
                self?.winPublisher.send()
                self?.runHapticSuccess()
            } else {
                self?.runHapticImpact()
            }
        }
    }
    
    // MARK: - Private Logic
    
    private func runHapticImpact() {
        hapticFeedback.runImpact()
        hapticFeedback.prepareImpact()
    }
    
    private func runHapticSuccess() {
        hapticFeedback.runSuccess()
    }
    
    private func startNewGame() {
        gameLogic.shuffle()
        
        moveCount = 0
        showWinnerTime = false
        
        timer.tickAction = { [weak self] time in
           self?.updateTimeTitle(with: time)
        }
        
        if timer.timerStarted {
            timer.stopTimer()
        }
        updateTimeTitle(with: 0)
        timer.startTimer()
        hapticFeedback.prepareImpact()
        
        updateCellList()
    }
    
    private func updateCellList() {
        
        var modelList: [CellModel] = []
        
        for item in gameLogic.enumerateItems() {
            modelList.append(CellModel(id: item.0, title: "\(item.0)", pos: item.1))
        }
        
        self.cellList = modelList
    }
    
    private func updateTimeTitle(with time: TimeInterval) {
        timeTitle = timeFormatter.string(from: time) ?? ""
    }
}
