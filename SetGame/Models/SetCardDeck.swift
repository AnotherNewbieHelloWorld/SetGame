//
//  SetCardDeck.swift
//  SetGame
//
//  Created by Apple User on 17.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import Foundation

struct SetCardDeck {
    private(set) var cards = [SetCard]()
    
    init() {
        for color in SetCard.Variant.all {
            for number in SetCard.Variant.all {
                for shape in SetCard.Variant.all {
                    for fill in SetCard.Variant.all {
                        let card = SetCard(number: number, color: color, shape: shape, fill: fill)
                        cards += [card]
                    }
                }
            }
        }
    }
    
    mutating func draw() -> SetCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
