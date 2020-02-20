//
//  SetCard.swift
//  SetGame
//
//  Created by Apple User on 09.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import Foundation

struct SetCard: CustomStringConvertible {
    
    
     let number: Variant // number - 1, 2, 3
     let color: Variant  // color  - 1, 2, 3 (например, red, green, purple)
     let shape: Variant  // symbol - 1, 2, 3 (например, diamond, squiggle, oval)
     let fill: Variant   // fill   - 1, 2, 3 (например, solid, striped, open)
    
     var description: String {return "\(number)-\(color)-\(shape)-\(fill)"}
     
     enum Variant: Int, CustomStringConvertible  {
         case v1 = 1
         case v2
         case v3
         
         static var all: [Variant] { return [.v1, .v2, .v3] }
         var description: String { return String(self.rawValue) }
         var idx: Int { return (self.rawValue - 1) }
     }
    
    static func isSet(cards: [SetCard]) -> Bool {
         guard cards.count == 3 else { return false }
         let color = Set(cards.map { (selectedCard) in selectedCard.color }).count
         let shape = Set(cards.map { $0.shape }).count
         let number = Set(cards.map { $0.number }).count
         let fill = Set(cards.map { $0.fill }).count

         return color != 2 && shape != 2 && number != 2 && fill != 2
     }
}

extension SetCard: Equatable {
    
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.shape == rhs.shape &&
            lhs.color == rhs.color &&
            lhs.number == rhs.number &&
            lhs.fill == rhs.fill
    }
}
