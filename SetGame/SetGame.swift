//
//  SetGame.swift
//  SetGame
//
//  Created by Apple User on 09.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import Foundation

struct SetGame {
    
    private(set) var deck = [Card]()
    private(set) var cardOnTable = [Card]()
    private var selectedCard = [Card]()
    var score: (points: Int, progress: String)
    var hintCard = [Int]()
    private var coefficient = 0
    
    var numberOfCards: Int {
        return deck.count
    }
    
    mutating func calculateCoefficient(of value: Int) {
        switch value {
        case ..<14:
            coefficient = 3
        case 15...20:
            coefficient = 2
        case 21...24:
            coefficient = 1
        default:
            coefficient = 0
        }
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cardOnTable.indices.contains(index),
               "SetGame.chooseCard(at: \(index)): chosen index not in the deck")
        if selectedCard.contains(cardOnTable[index]) {
            selectedCard.remove(at: selectedCard.firstIndex(of: cardOnTable[index])!)
            return
        }
        
        if selectedCard.count == 3 {
            if isSet(on: selectedCard) {
                score.points += 1 * coefficient
                score.progress = "+\(1 * coefficient)"
                for card in selectedCard {
                    cardOnTable.remove(at: cardOnTable.firstIndex(of: card)!)
                }
                selectedCard.removeAll()
                draw()
            } else {
                score.points -= 2 * coefficient
                score.progress = "-\(2 * coefficient)"
            }
        }
        if index < cardOnTable.count {
            selectedCard += [cardOnTable[index]]
        }
    }
    
    mutating func isSet(on selectedCard: [Card]) -> Bool {
//
//        let color = Set(selectedCard.map { (selectedCard) in selectedCard.color }).count
//        let shape = Set(selectedCard.map { $0.shape }).count
//        let number = Set(selectedCard.map { $0.number }).count
//        let fill = Set(selectedCard.map { $0.fill }).count
//
//        return color != 2 && shape != 2 && number != 2 && fill != 2
        return true
    }
    
    mutating func hint() {
        hintCard.removeAll()
        for i in 0..<cardOnTable.count {
            for j in (i + 1)..<cardOnTable.count {
                for k in (j + 1)..<cardOnTable.count {
                    let hints = [cardOnTable[i], cardOnTable[j], cardOnTable[k]]
                    if isSet(on: hints) {
                        hintCard += [i, j, k]
                    }
                }
            }
        }
    }
    
    mutating func isGameOver() -> Bool {
        if deck.count == 0 {
            hint()
            if hintCard.isEmpty || cardOnTable.count <= 3 {
                return true
            }
        }
        return false
    }
    
    mutating func draw() {
        print("\(deck.count)")
        if deck.count > 0 {
            for _ in 1...3 {
                cardOnTable += [deck.remove(at: deck.randomIndex)]
            }
            calculateCoefficient(of: cardOnTable.count)
        }
    }
    
    private mutating func initDeck() {
        for _ in 1...4 {
            draw()
        }
    }
    
    init() {
        score = (0, " ")
        for color in Card.Color.all {
            for number in Card.Number.all {
                for shape in Card.Shape.all {
                    for fill in Card.Fill.all {
                        let card = Card(with: color, shape, number, fill)
                        deck += [card]
                    }
                }
            }
        }
        initDeck()
    }
    
}

extension Array {
    var randomIndex: Int {
        return Int(arc4random_uniform(UInt32(count - 1)))
    }
}
