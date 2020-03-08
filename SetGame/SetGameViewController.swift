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
    private var matchedSetCardViews: [SetCardView] { boardView.cardViews.filter { $0.isMatched == true } }
    private var dealSetCardViews: [SetCardView] { boardView.cardViews.filter { $0.alpha == 0 } }
    private var deckCenter: CGPoint { view.convert(dealButton.center, to: boardView) }
    private var discardPileCenter: CGPoint { view.convert(setButton.center, to: boardView) }
    private var tmpCards = [SetCardView]()
    var _lastHint = 0
    
    @IBOutlet weak var boardView: BoardView! {
        didSet {
//            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealThreeMoreButtonPressed))
//            swipe.direction = .down
//            boardView.addGestureRecognizer(swipe)
//
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle))
            boardView.addGestureRecognizer(rotate)
        }
    }
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in: animator)
    
    @IBOutlet weak private var dealButton: UIButton!
    @IBOutlet weak private var setButton: UIButton!
    @IBOutlet private var newGameButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    // @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deckCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dealButton.layer.cornerRadius = 10.0
        setButton.layer.cornerRadius = 10.0
        updateViewFromModel()
        //scoreLabel.text = "Try to make a Set!"
    }
    
    private func updateViewFromModel() {
        updateCardViewsFromModel()
        _lastHint = 0
        updateScore()
        deckCountLabel.text = "Deck: \(game.deckCount)"
        dealButton.isHidden = game.deckCount == 0
    }
    
    private func updateCardViewsFromModel() {
        var newCardViews = [SetCardView]()
        
        // remove matched cards from boardView at the end of the game
        if boardView.cardViews.count - game.cardsOnTable.count > 0 {
            boardView.removaCardViews(removedCardViews: matchedSetCardViews)
        }
        let numberOfCardViews = boardView.cardViews.count

        for index in game.cardsOnTable.indices {
            let card = game.cardsOnTable[index]
            if index > (numberOfCardViews - 1) { // new cards
                let cardView = SetCardView()
                updateCardView(cardView, for: card)
                cardView.alpha = 0
                addTapGestureRecognizer(for: cardView)
                newCardViews += [cardView]
            } else {                             // old cards
                let cardView = boardView.cardViews[index]
                if cardView.alpha < 1 && cardView.alpha > 0 && game.isSet != true {
                    cardView.alpha = 0
                }
                updateCardView(cardView, for: card)
            }
        }
        // add new cards to boardView
        boardView.addCardViews(newCardViews: newCardViews)
        
        // Matched card animation
        flyAwayAnimation()
        
        // Deal cad animation
        dealAnimation()
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
    
    private func dealAnimation() {
        var currentDealCard = 0
        let timeInterval = 0.15 * Double(boardView.rowGrid + 1)
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { (timer) in
            self.dealSetCardViews.forEach {
                $0.animateDeal(from: self.deckCenter, delay: TimeInterval(currentDealCard) * 0.25)
                currentDealCard += 1
            }
        }
    }
    
    private func flyAwayAnimation() {
        let fliedCardsCount = matchedSetCardViews.filter{$0.alpha<1 && $0.alpha>0}.count
        if game.isSet != nil, game.isSet!, fliedCardsCount == 0 {
            
            tmpCards.forEach { $0.removeFromSuperview() }
            tmpCards = []
            
            matchedSetCardViews.forEach {
                $0.alpha = 0.2
                tmpCards += [$0.copyCard()]
            }
            
            tmpCards.forEach {
                boardView.addSubview($0)
                cardBehavior.addItem($0)
            }
            
            tmpCards[0].addDiscardPile = { [weak self] in
                if let countSets = self?.game.numberOfSets, countSets > 0 {
                    self?.setButton.alpha = 0
                }
            }
            
            tmpCards[2].addDiscardPile = { [weak self] in
                if let countSets = self?.game.numberOfSets, countSets > 0 {
                    self?.setButton.setTitle("\(countSets) Sets", for: .normal)
                    self?.setButton.alpha = 1
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                var j = 1
                for tmpCard in self.tmpCards {
                    self.cardBehavior.removeItem(tmpCard)
                    tmpCard.animateFly(to: self.discardPileCenter, delay: TimeInterval(j)*0.25)
                    j += 1
                }
            }
        }
    }
    
    //      MARK: Tap Gesture Deck
    @IBAction func deal3() {
        game.dealThree()
        updateViewFromModel()
    }

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
        //scoreLabel.text = "Try to make a Set!"
        _lastHint = 0
    }
    
    private func updateScore() {
        //scoreLabel.text = "Score: \(game.score.points)  (\(game.score.progress))"
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
