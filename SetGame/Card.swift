//
//  SetCard.swift
//  SetGame
//
//  Created by Apple User on 09.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import Foundation

struct Card {
    
    let shape: Shape
    let color: Color
    let number: Number
    let fill: Fill
    
    // lazy var matrix = [color.rawValue, number.rawValue, shape.rawValue, fill.rawValue] as [Any]
    lazy var matrix = (color: color.rawValue,
                       number: number.rawValue,
                       shape: shape.rawValue,
                       fill: fill.rawValue)
    
    enum Shape: String, CustomStringConvertible {
        case circle = "circle"
        case square = "square"
        case triangle = "triangle"
        var description: String { return rawValue }
        static let all = [Shape.circle, .square, .triangle]
    }
    
    enum Color: String, CustomStringConvertible {
        case red = "red"
        case purple = "purple"
        case green = "green"
        var description: String { return rawValue }
        static var all = [Color.red, .purple, .green]
    }
    
    enum Number: Int, CustomStringConvertible {
        case one = 1
        case two
        case three
        var description: String { return "\(rawValue)" }
        static var all = [Number.one, .two, .three]
    }
    
    enum Fill: String, CustomStringConvertible {
        case solid = "solid"
        case stripe = "stripe"
        case empty = "empty"
        var description: String { return rawValue }
        static let all = [Fill.solid, .stripe, .empty]
    }
    
    init(with c: Color, _ s: Shape, _ n: Number, _ f: Fill) {
        color = c
        shape = s
        number = n
        fill = f
    }
}

extension Card: CustomStringConvertible {
    
    var description: String {
        return "color: \(color), shape: \(shape), number: \(number), fill: \(fill)"
    }
}

extension Card: Equatable {
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.shape == rhs.shape &&
            lhs.color == rhs.color &&
            lhs.number == rhs.number &&
            lhs.fill == rhs.fill
    }
}
