//
//  BoardView.swift
//  SetGame
//
//  Created by Apple User on 17.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var cardViews = [SetCardView]()
    
    var rowGrid: Int {
        return gridCards?.dimensions.rowCount ?? 0
    }
    private var gridCards: Grid?
    
    private func layoutSetCards() {
        if let grid = gridCards {
            let columnsGrid = grid.dimensions.columnCount
            for row in 0..<rowGrid {
                for column in 0..<columnsGrid {
                    let currentIndex = row * columnsGrid + column
                    if cardViews.count > currentIndex {
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.3,
                            delay: TimeInterval(row+column) * 0.05,
                            options: [.curveEaseInOut],
                            animations: {
                                self.cardViews[currentIndex].frame =
                                    grid[row,column]!.insetBy(
                                        dx: Constant.spacingDx,
                                        dy: Constant.spacingDy)}
                        )
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gridCards = Grid(layout: Grid.Layout.aspectRatio(Constant.cellAspectRatio), frame: bounds)
        gridCards?.cellCount = cardViews.count
        layoutSetCards()
    }
    
    func addCardViews(newCardViews: [SetCardView]) {
        cardViews += newCardViews
        newCardViews.forEach { addSubview($0) }
        layoutIfNeeded()
    }
    
    func removaCardViews(removedCardViews: [SetCardView]) {
        removedCardViews.forEach {
            cardViews.remove(elements: [$0])
            $0.removeFromSuperview()
        }
        layoutIfNeeded()
    }
    
    func resetCards() {
        cardViews.forEach {
            $0.removeFromSuperview()
        }
        cardViews = []
        layoutIfNeeded()
    }
    
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let spacingDx: CGFloat  = 5.0
        static let spacingDy: CGFloat  = 5.0
    }
}
