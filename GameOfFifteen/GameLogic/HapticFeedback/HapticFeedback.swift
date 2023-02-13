//
//  HapticFeedback.swift
//  LearnSwiftUI
//
//  Created by Dmitry Bordyug on 16.01.2023.
//

import UIKit

protocol HapticFeedback {
    
    func prepareImpact()
    
    func runImpact()
    
    func prepareSuccess()
    
    func runSuccess()
}

class HapticFeedbackGenerator: HapticFeedback {
    
    //  MARK: -  Public Interface
    
    static let shared = HapticFeedbackGenerator()
    
    //  MARK: - Private Logic
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    //  MARK: - HapticFeedback implementation
    
    func prepareImpact() {
        impactGenerator.prepare()
    }
    
    func runImpact() {
        impactGenerator.impactOccurred()
    }
    
    func prepareSuccess() {
        notificationGenerator.prepare()
    }
    
    func runSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
}


