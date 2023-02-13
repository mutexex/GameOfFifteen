//
//  FifteenGameView.swift
//  LearnSwiftUI
//
//  Created by Dmitry Bordyug on 25.01.2022.
//

import Combine
import SwiftUI

struct FifteenGameView: View {
    
    // MARK: - Properties
    
    private static let fieldPadding: CGFloat = 10
    private static let cellPadding: CGFloat = 6
    
    // MARK: - State
    
    @StateObject private var viewModel = FifteenGameViewModel()
    @State private var showingAlert = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            
            buildTitleView()
            
            GeometryReader { screenGeometry in
                buildGameFieldView(screenGeometry: screenGeometry)
            }
            .alert("New Game", isPresented: $viewModel.isNewGameAlertShown) {
                Button("Yes", role: .destructive) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        viewModel.processNewGameAlertOkDidTap()
                    }
                }
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("Are you sure you want to start a new game?")
            }
        }
    }
    
    private func buildTitleView() -> some View {
        ZStack() {
            Text("Game of Fifteen")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top, 10)
                .transaction { transaction in
                    transaction.animation = nil
                }
            
            HStack {
                Spacer()
                
                Button {
                    onStartDidTap()
                } label: {
                    Text("Start")
                }
                .padding(.trailing, 20)
                .padding(.top, 12)
            }
        }
    }
    
    private func buildGameFieldView(screenGeometry geo: GeometryProxy) -> some View {
        
        let labelsHeight: CGFloat = 70
        let fieldWidth = min(geo.size.height - labelsHeight, geo.size.width) - 2 * Self.fieldPadding
        
        let space = fieldWidth - CGFloat(viewModel.fieldSize + 1) * Self.cellPadding
        let cellSize = floor(space / CGFloat(viewModel.fieldSize))
        
        return VStack {
            Spacer()
            
            Text(viewModel.timeTitle)
                .foregroundColor(viewModel.showWinnerTime ? .green : .secondary)
                .padding(.bottom, 8)
                .animation(nil, value: UUID())
            
            Text("Moves: \(viewModel.moveCount)")
                .foregroundColor(viewModel.showWinnerTime ? .green : .secondary)
                .padding(.bottom, 16)
                .animation(nil, value: UUID())
            
            GeometryReader { geo in

                ForEach(viewModel.cellList) { cellModel in
                    buildCellView(cellModel: cellModel, cellSize: cellSize)
                }
            }
            .frame(width: fieldWidth, height: fieldWidth)
            .border(.gray, width: 1.5)
            
            Spacer()
        }
        .frame(width: geo.size.width,
               height: geo.size.height,
               alignment: .top)
    }
    
    private func buildCellView(cellModel: FifteenGameViewModel.CellModel, cellSize: CGFloat) -> some View {
        let cellPos = cellFrame(for: cellModel.pos, cellSize: cellSize)
        let winSignal = viewModel.winPublisher.eraseToAnyPublisher()
        
        return CellView(title: cellModel.title,
                        id: cellModel.id,
                        size: cellSize,
                        winSignal: winSignal) { id in
            onCellDidTap(cellId: id)
        }
        .offset(CGSize(width: cellPos.minX, height: cellPos.minY))
    }
    
    // MARK: - User Actions
    
    private func onCellDidTap(cellId: Int) {
        let animationTime: TimeInterval = 0.15
        
        withAnimation(.linear(duration: animationTime)) {
            viewModel.processCellDidTap(cellId: cellId, animationDelay: animationTime)
        }
    }
    
    private func onStartDidTap() {
        withAnimation(.easeIn(duration: 0.5)) {
            viewModel.processStartDidTap()
        }
    }
    
   // MARK:  - Private Logic
    
    private func cellFrame(for pos: FifteenGameViewModel.CellPos, cellSize: CGFloat) -> CGRect {
        
        let xPos = Self.cellPadding * CGFloat(pos.column + 1) + cellSize * CGFloat(pos.column)
        
        let yPos =  Self.cellPadding * CGFloat(pos.row + 1) + cellSize * CGFloat(pos.row)
        
       return CGRect(x: xPos, y: yPos, width: cellSize, height: cellSize)
    }
}

struct FifteenGameView_Previews: PreviewProvider {
    static var previews: some View {
        FifteenGameView()
    }
}
