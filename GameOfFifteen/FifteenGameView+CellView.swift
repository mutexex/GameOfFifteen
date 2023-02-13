//
//  FifteenGameView+CellView.swift
//  LearnSwiftUI
//
//  Created by Dmitry Bordyug on 25.01.2022.
//

import Combine
import SwiftUI

extension FifteenGameView {
    
    struct CellView: View {
        
        // MARK: - Properties
        
        @Environment(\.colorScheme) var colorScheme
        
        var title: String
        
        var id: Int
        
        var size: CGFloat
        
        var winSignal: AnyPublisher<Void, Never>
        
        var action: (Int) -> Void
        
        // MARK: - State
        
        @State private var showGreenBackground = false
        
        // MARK: - Body
        
        var body: some View {
            
            Button(action: {
                action(id)
            }, label: {
                Text(title)
                    .frame(width: size, height: size, alignment: .center)
            })
            .background(cellBackground())
            .onReceive(winSignal) { _ in
                animateBackground()
            }
        }
        
        private func cellBackground() -> some View {
            let color: Color
            if showGreenBackground {
                color = .green
            } else {
                color = colorScheme == .dark ? .black : .white
            }
            
            return RoundedRectangle(cornerRadius: 6)
                .stroke(Color.brown, lineWidth: 1)
                .background(color)
        }
        
        // MARK: - Private Logic
        
        private func animateBackground() {
            let step: Double = 0.3
            var delay: Double = 0
            
            withAnimation(.easeIn(duration: step)) {
                showGreenBackground = true
            }
            
            for _ in 1...3 {
                delay += step
                withAnimation(.easeIn(duration: step).delay(delay)) {
                    showGreenBackground.toggle()
                }
            }
        }
    }
}

struct FifteenGameView_CellView_Previews: PreviewProvider {
    static var previews: some View {
        FifteenGameView.CellView(title: "Cell",
                                 id: 1,
                                 size: 90,
                                 winSignal: PassthroughSubject<Void, Never>().eraseToAnyPublisher(),
                                 action: { _ in
        })
            .preferredColorScheme(.light)
    }
}
