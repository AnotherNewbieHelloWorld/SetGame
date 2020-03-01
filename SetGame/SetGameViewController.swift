//
//  ViewController.swift
//  SetGame
//
//  Created by Apple User on 09.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    
    private var game = SetGame() {
        didSet { if game.deckCount == 0 && game.isGameOver() { winAlertController() } }
    }
    
    private var matchedSetCardViews: [SetCardView] {
        return  boardView.cardViews.filter { $0.isMatched == true }
    }
    
    @IBOutlet weak var boardView: BoardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealThreeMoreButtonPressed))
            swipe.direction = .down
            boardView.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle))
            boardView.addGestureRecognizer(rotate)
        }
    }
    
    @IBOutlet private var newGameButton: UIButton!
    @IBOutlet weak private var dealThreeMoreButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deckCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
        scoreLabel.text = "Try to make a Set!"
    }
    
    private func updateViewFromModel() {
        updateCardViewsFromModel()
        _lastHint = 0
        updateScore()
        deckCountLabel.text = "Deck: \(game.deckCount)"
        dealThreeMoreButton.isHidden = game.deckCount == 0
    }
    
    private func updateCardViewsFromModel() {
        if boardView.cardViews.count - game.cardsOnTable.count > 0 {
            let cardViews = boardView.cardViews[..<game.cardsOnTable.count ]
            boardView.cardViews = Array(cardViews)
        }
        let numberOfCardViews = boardView.cardViews.count

        for index in game.cardsOnTable.indices {
            let card = game.cardsOnTable[index]
            if index > (numberOfCardViews - 1) { // new cards
                let cardView = SetCardView()
                updateCardView(cardView, for: card)
                addTapGestureRecognizer(for: cardView)
                boardView.cardViews.append(cardView)
            } else {                             // old cards
                let cardView = boardView.cardViews[index]
                updateCardView(cardView,for: card)
            }
        }
    }
    
    private func updateCardView(_ cardView: SetCardView, for card: SetCard) {
        cardView.symbolInt =  card.shape.rawValue
        cardView.fillInt = card.fill.rawValue
        cardView.colorInt = card.color.rawValue
        cardView.count =  card.number.rawValue
        cardView.isSelected = game.selectedCards.contains(card)
        if let itIsSet = game.isSet {
            if game.cardsTryMatched.contains(card) {
                cardView.isMatched = itIsSet
            }
        } else {
            cardView.isMatched = nil
        }
    }
    
    @IBAction func dealThreeMoreButtonPressed() {
        game.dealThree()
        updateViewFromModel()
    }
    
    private var _lastHint = 0
    
    @IBAction func hintButtonPressed() {
        if game.hints.count > 0 {
            game.hints[_lastHint].forEach { (idx) in
                boardView.cardViews[idx].hint()
            }
//            self.updateCardViewsFromModel()
//            self._lastHint = (self._lastHint).incrementCicle(in:(self.game.hints.count))
        }
    }
    
    @IBAction func newGameButtonPressed(_ sender: UIButton) {
        startNewGameAlertController()
    }
    
    private func newGame() {
        game = SetGame()
        boardView.cardViews.removeAll()
        updateViewFromModel()
        scoreLabel.text = "Try to make a Set!"
        _lastHint = 0
    }
    
    private func updateScore() {
        scoreLabel.text = "Score: \(game.score.points)  (\(game.score.progress))"
    }
    
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
    
    private func startNewGameAlertController() {
        let alertController = UIAlertController(title: nil, message: "Start a new game?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let newGame = UIAlertAction(title: "New Game", style: .default) { [weak self] (newGame) in
            self?.newGame()
        }
        alertController.addAction(cancel)
        alertController.addAction(newGame)
        present(alertController, animated: true)
    }
    
    private func addTapGestureRecognizer(for cardView: SetCardView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCard(recognizedBy:)))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    @objc func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cardView = recognizer.view! as? SetCardView {
                game.chooseCard(at: boardView.cardViews.firstIndex(of: cardView)!)
            }
        default:
            break
        }
        updateViewFromModel()
    }
    
    @objc func reshuffle(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            game.shuffle()
            updateViewFromModel()
        default:
            break
        }
    }
}

extension Int {
    func incrementCicle (in number: Int)-> Int {
        return (number - 1) > self ? self + 1: 0
    }
}
