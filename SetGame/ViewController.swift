//
//  ViewController.swift
//  SetGame
//
//  Created by Apple User on 09.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
        
    @IBOutlet private var cardButtons: [UIButton]!
    @IBOutlet weak private var moreThreeButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var hintButton: UIButton!
    
    private var game = SetGame() {
        didSet {
            if game.deck.count == 0 {
//                hideCard()
                if game.isGameOver() {
                    winAlertController()
                    return
                }
            }
        }
    }
    private var selectedButtons = [UIButton]()
    private var hintedButtons = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
        scoreLabel.text = "Try to make a Set!"
    }
    
    @IBAction private func cardButtonPressed(_ sender: UIButton) {
        if let cardIndex = cardButtons.lastIndex(of: sender) {
            if cardIndex < game.cardOnTable.count {
                game.chooseCard(at: cardIndex)
                chooseButton(at: sender)
                updateViewFromModel()
            }
        } else {
            print("chosen card was not in cardButtons")
        }
        print("@@ \(selectedButtons.count) @@")
    }
    
    @IBAction private func moreThreeButtonPresseed(_ sender: UIButton) {
        game.score.points -= 1
        game.score.progress = "-1"
        game.draw()
        updateViewFromModel()
        hiddenButtonIfNeed()
    }
    
    @IBAction func hintButtonPressed(_ sender: UIButton) {
        game.hint()
        if game.hintCard.count > 0 {
            for hintCardIndex in 0...2 {
                let index = game.hintCard[hintCardIndex]
                if cardButtons[index].layer.borderColor != #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) {
                    cardButtons[index].layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                    cardButtons[index].layer.borderWidth = 3.0
                }
                hintedButtons.append(cardButtons[index])
            }
            hintedButtons.removeAll()
        }
    }
    
    
//    private func hideCard() {
//        if game.cardOnTable.count > cardButtons.count - 1 { return }
//        for index in game.cardOnTable.count - 1...cardButtons.count - 1 {
//            let card = cardButtons[index]
//            if card.backgroundColor == #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
//                let nsAttributedString = NSAttributedString(string: "")
//                card.setAttributedTitle(nsAttributedString, for: .normal)
//                card.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
//            }
//        }
//    }
    
    private func winAlertController() {
        let alertController = UIAlertController(title: "This game is yours", message: "🎊💃🕺🎉", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let startNewGame = UIAlertAction(title: "New Game", style: .default) { [weak self] (startNewGame) in
            self?.newGame()
        }
        alertController.addAction(cancel)
        alertController.addAction(startNewGame)
        present(alertController, animated: true)
    }
    
    @IBAction func newGameButtonPressed(_ sender: UIButton) {
        self.newGame()
    }
    
    private func newGame() {
        game = SetGame()
        resetButtons()
        updateViewFromModel()
        hiddenButtonIfNeed()
        selectedButtons.removeAll()
        hintedButtons.removeAll()
    }
    
    private func updateScore() {
        scoreLabel.text = "Score: \(game.score.points)  (\(game.score.progress))"
    }
    
    private func hiddenButtonIfNeed() {
        if game.cardOnTable.count == 21 || game.numberOfCards == 0 {
            moreThreeButton.isHidden = true
        } else {
            moreThreeButton.isHidden = false
        }
    }
    
    private func resetButtons() {
        for button in cardButtons {
            let nsAttributedString = NSAttributedString(string: "")
            button.setAttributedTitle(nsAttributedString, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0)
            button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            button.layer.borderWidth = 3.0
        }
    }
    
    private func chooseButton(at card: UIButton) {
        if selectedButtons.contains(card) {
            card.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            card.layer.borderWidth = 3.0
            selectedButtons.remove(at: selectedButtons.firstIndex(of: card)!)
            return
        } else if selectedButtons.count == 3 {
            cardButtons.forEach() { $0.layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0) }
            selectedButtons.removeAll()
            updateScore()
        }
        selectedButtons += [card]
        card.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        card.layer.borderWidth = 3.0
    }
    
    private func updateViewFromModel() {
        updateScore()
        for index in game.cardOnTable.indices {
            cardButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cardButtons[index].titleLabel?.numberOfLines = 0
            cardButtons[index].setAttributedTitle(
                setupCardTitle(with: game.cardOnTable[index]), for: .normal)
            cardButtons[index].layer.cornerRadius = 8.0
        }
    }
    
    private func setupCardTitle(with card: Card) -> NSAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .strokeColor: SetTheme.colors[card.color]!,
            .strokeWidth: SetTheme.strokeWidth[card.fill]!,
            .foregroundColor: SetTheme.colors[card.color]!
                .withAlphaComponent(SetTheme.alpha[card.fill]!)]
        
        var cardTitle = SetTheme.shapes[card.shape]!
        
        switch card.number {
        case .two:
            cardTitle = "\(cardTitle)\n\(cardTitle)"
        case .three:
            cardTitle = "\(cardTitle)\n\(cardTitle)\n\(cardTitle)"
        default:
            break
        }
        return NSAttributedString(string: cardTitle, attributes: attributes)
    }
}

struct SetTheme {
    
    static let shapes: [Card.Shape: String] = [.circle: "●", .triangle: "▲", .square: "■"]
    static var colors: [Card.Color: UIColor] = [.red: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), .purple: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), .green: #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1)]
    static var alpha: [Card.Fill: CGFloat] = [.solid: 1.0, .empty: 0.40, .stripe: 0.15]
    static var strokeWidth: [Card.Fill: CGFloat] = [.solid: -5, .empty: 5, .stripe: -5]
}
