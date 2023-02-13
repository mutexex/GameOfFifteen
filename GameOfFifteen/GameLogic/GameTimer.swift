//
//  GameTimer.swift
//  FifteenGame
//
//  Created by Dmitry on 27.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class GameTimer: GameTimerProtocol {
    
    //
    // MARK: - Public Interface
    //
    private(set) var timerStarted = false
    
    private(set) var gameTime: TimeInterval = 0
    
    var tickAction: ((TimeInterval) -> Void)?
    
    func startTimer() {
        
        guard !timerStarted else {
            return
        }
        
        gameTime = 0
        timerStarted = true
        
        subscribeNotifications()
        resumeTimer()
    }
    
    func stopTimer() {
        
        guard timerStarted else {
            return
        }
        
        timerStarted = false
        timer?.invalidate()
        timer = nil
        
        unsubscribeNotifications()
    }
        
    //
    // MARK: - Private Logic
    //
    private var timer: Timer?
    private var prevTickInterval: TimeInterval = 0
    
    private func onTimerTick() {
        
        let newTick = Date.timeIntervalSinceReferenceDate
        gameTime += newTick - prevTickInterval
        prevTickInterval = newTick
        
        tickAction?(gameTime)
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resumeTimer() {
        
        guard timerStarted else {
            return
        }
        
        prevTickInterval = Date.timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.onTimerTick()
        }
    }
    
    //
    // MARK: - Notifications
    //
    
    private func subscribeNotifications() {
        
        NotificationCenter.default
            .addObserver(self, selector:
              #selector(onApplicationDidEnterBackground),
              name: UIApplication.didEnterBackgroundNotification,
              object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector:
                #selector(onApplicationWillEnterForeground),
                name: UIApplication.willEnterForegroundNotification,
                object: nil)
    }
    
    private func unsubscribeNotifications() {
        NotificationCenter.default
            .removeObserver(self,
              name: UIApplication.didEnterBackgroundNotification,
              object: nil)
        
        NotificationCenter.default
            .removeObserver(self,
              name: UIApplication.willEnterForegroundNotification,
              object: nil)
    }
    
    @objc private func onApplicationDidEnterBackground() {
        pauseTimer()
    }
    
    @objc private func onApplicationWillEnterForeground() {
        resumeTimer()
    }
    
    deinit {
        pauseTimer()
    }
}
