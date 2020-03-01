//
//  BoardView.swift
//  SetGame
//
//  Created by Apple User on 17.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var cardViews = [SetCardView]() {
        willSet {
            removeSubviews()
        }
        didSet {
            addSubviews()
            setNeedsLayout()
        }
    }
    
    private func removeSubviews() {
        for card in cardViews {
            card.removeFromSuperview()
        }
    }
    
    private func addSubviews() {
        for card in cardViews {
            addSubview(card)
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var grid = Grid(layout: Grid.Layout.aspectRatio(Constant.cellAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.7,
            delay: 0,
            options: [.allowUserInteraction],
            animations: { [weak self] in
                for row in 0..<grid.dimensions.rowCount {
                    for column in 0..<grid.dimensions.columnCount {
                        if (self?.cardViews.count) != nil {
                            if (self?.cardViews.count)! > (row * grid.dimensions.columnCount + column) {
                                
                                self?.cardViews[row * grid.dimensions.columnCount + column].frame = grid[row,column]!.insetBy(dx: Constant.spacingDx, dy: Constant.spacingDy)
                            }
                        }
                    }
                }
            }
        )
    }
    
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let spacingDx: CGFloat  = 5.0
        static let spacingDy: CGFloat  = 5.0
    }
}
