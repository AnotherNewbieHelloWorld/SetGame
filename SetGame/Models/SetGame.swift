//
//  SetGame.swift
//  SetGame
//
//  Created by Apple User on 09.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import Foundation

struct SetGame {
    
    private var deck = SetCardDeck()
    var deckCount: Int {
        return deck.cards.count
    }
    
    private(set) var cardsOnTable = [SetCard]()
    private(set) var selectedCards = [SetCard]()
    private(set) var cardsTryMatched = [SetCard]()
    private(set) var cardsRemoved = [SetCard]()
    
    private(set) var numberOfSets = 0
    private(set) var score: (points: Int, progress: String)
    
    var isSet: Bool? {
        get {
            guard cardsTryMatched.count == 3 else { return nil }
            return SetCard.isSet(cards: cardsTryMatched)
        }
        set {
            if newValue != nil {
                if newValue! {          //cards matchs
                    score.points += 3
                    score.progress = "+\(3)"
                    numberOfSets += 1
                } else {               //cards didn't match - Penalize
                    score.points -= 5
                    score.progress = "-\(5)"
                }
                cardsTryMatched = selectedCards
                selectedCards.removeAll()
            } else {
                cardsTryMatched.removeAll()
            }
        }
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cardsOnTable.indices.contains(index),
               "SetGame.chooseCard(at: \(index)): chosen index not in the deck")
        
        let cardChoosen = cardsOnTable[index]
        if !cardsRemoved.contains(cardChoosen) && !cardsTryMatched.contains(cardChoosen) {
            if isSet != nil {
                if isSet! {
                    replaceOrRemove3Cards()
                }
                isSet = nil
            }
            if selectedCards.count == 2, !selectedCards.contains(cardChoosen) {
                selectedCards += [cardChoosen]
                isSet = SetCard.isSet(cards: selectedCards)
            } else {
                selectedCards.inOut(element: cardChoosen)
            }
        }
    }
    
    private mutating func replaceOrRemove3Cards() {
        //        if let take3Cards =  take3FromDeck() { // less complicated game
        if cardsOnTable.count == Constants.startNumberCards, let take3Cards = takeThreeFromDeck() {
            cardsOnTable.replace(elements: cardsTryMatched, with: take3Cards)
        } else {
            cardsOnTable.remove(elements: cardsTryMatched)
        }
        cardsRemoved += cardsTryMatched
        cardsTryMatched.removeAll()
    }
    
    mutating func takeThreeFromDeck() -> [SetCard]? {
        var threeCards = [SetCard]()
        for _ in 0...2 {
            if let card = deck.draw() {
                threeCards += [card]
            } else {
                return nil
            }
        }
        return threeCards
    }
    
    mutating func dealThree() {
        if let dealThreeCards = takeThreeFromDeck() {
            cardsOnTable += dealThreeCards
        }
    }
    
    init() {
        score = (0,"")
        for _ in 1...Constants.startNumberCards {
            if let card = deck.draw() {
                cardsOnTable += [card]
            }
        }
    }
    
    mutating func shuffle(){
        cardsOnTable.shuffle()
    }
    
    var hints: [[Int]] {
        var hints = [[Int]]()
        if cardsOnTable.count > 2 {
            for i in 0..<cardsOnTable.count {
                for j in (i+1)..<cardsOnTable.count {
                    for k in (j+1)..<cardsOnTable.count {
                        let cards = [cardsOnTable[i], cardsOnTable[j], cardsOnTable[k]]
                        if SetCard.isSet(cards: cards) {
                            hints.append([i,j,k])
                        }
                    }
                }
            }
        }
        if let itIsSet = isSet, itIsSet {
            let matchIndices = cardsOnTable.indices(of: cardsTryMatched)
            return hints.map{ Set($0)}
                .filter{$0.intersection(Set(matchIndices)).isEmpty}
                .map{Array($0)}
        }
        return hints
    }
    
//    mutating func hint() {
//        hintCards.removeAll()
//        for i in 0..<cardsOnTable.count {
//            for j in (i + 1)..<cardsOnTable.count {
//                for k in (j + 1)..<cardsOnTable.count {
//                    let hints = [cardsOnTable[i], cardsOnTable[j], cardsOnTable[k]]
//                    if SetCard.isSet(cards: hints) {
//                        hintCards += [i, j, k]
//                    }
//                }
//            }
//        }
//    }
    
    mutating func isGameOver() -> Bool {
        if deckCount == 0 && hints.count < 2 { return true }
        else { return false }
    }
    
    private struct Constants {
        static let startNumberCards = 12
    }
}

extension Array where Element: Equatable {
    mutating func inOut(element: Element) {
        if let from = self.firstIndex(of: element) {
            self.remove(at: from)
        } else {
            self.append(element)
        }
    }
    
    mutating func remove(elements: [Element]) {
        self = self.filter { !elements.contains($0) }
    }
    
    mutating func replace(elements: [Element], with new: [Element]) {
        guard elements.count == new.count else { return }
        for idx in 0..<new.count {
            if let indexMatched = self.firstIndex(of: elements[idx]) {
                self [indexMatched ] = new[idx]
            }
        }
    }
    
    func indices(of elements: [Element]) ->[Int] {
        guard self.count >= elements.count, elements.count > 0 else { return [] }
        return elements.map{ self.firstIndex(of: $0) }.compactMap{$0}
    }
}

extension Array {

    mutating func shuffle() {
        if count < 2 { return }
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: diff.arc4random)
            swapAt(i, j)
        }
    }
}
