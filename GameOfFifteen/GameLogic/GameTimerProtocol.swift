//
//  GameTimerProtocol.swift
//  FifteenGame
//
//  Created by Dmitry on 28.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

protocol GameTimerProtocol: AnyObject {
    
    typealias TimerAction = (TimeInterval) -> Void
    
    var timerStarted: Bool { get }
   
    var gameTime: TimeInterval { get }
    
    var tickAction: TimerAction? { get set }
    
    func startTimer()
    
    func stopTimer()
}
