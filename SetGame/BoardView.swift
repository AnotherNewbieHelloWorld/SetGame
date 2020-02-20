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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var grid = Grid(layout: Grid.Layout.aspectRatio(Constant.cellAspectRatio), frame: bounds)
        grid.cellCount = cardViews.count
        
        for row in 0..<grid.dimensions.rowCount {
            for column in 0..<grid.dimensions.columnCount {
                if cardViews.count > (row * grid.dimensions.columnCount + column) {
                    
                    cardViews[row * grid.dimensions.columnCount + column].frame = grid[row,column]!.insetBy(dx: Constant.spacingDx, dy: Constant.spacingDy)
                }
            }
        }
    }
    
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let spacingDx: CGFloat  = 5.0
        static let spacingDy: CGFloat  = 5.0
    }
}
