//
//  ViewController.swift
//  SetGame
//
//  Created by Nogah Melamed Cohen on 10/10/2019.
//  Copyright © 2019 Nogah Melamed Cohen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var cardsOnBoard: [UIButton]!
    var setGame = SetGameModel()
    let cardColorDict = [CardProperty.p1 : #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1), CardProperty.p2 : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), CardProperty.p3 : #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)]
    let cardFillingDict = [CardProperty.p1 : 0, CardProperty.p2 : 0.15, CardProperty.p3: 1]
    let cardShapeDict = [CardProperty.p1 : "▲", CardProperty.p2 : "●", CardProperty.p3: "■"]
    let cardShapeCountDict = [CardProperty.p1 : 1, CardProperty.p2 : 2, CardProperty.p3: 3]
    let borderColorDict : [CardState : CGColor] = [CardState.chosen : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), CardState.match : #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), CardState.mismatch : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)]
    var hintIndexes: (Int, Int, Int)? = nil
    var againstIphoneGame = false
    var timer = Timer()
    var iPhoneFace = "🤔"
    
    @IBOutlet weak var playerVSphoneTxt: UITextField!
    @IBOutlet weak var dealThreeMoreCardsButton: UIButton!
    @IBOutlet weak var scoreText: UITextField!
    
    @IBOutlet weak var setBoardView: SetBoardView! {
        didSet {
            //when tap - select card
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnCard))
            setBoardView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet var screen: UIView! {
        didSet {
            //when swipe down - add three cards to board
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(addThreeCards(_:)))
            swipe.direction = .down
            screen.addGestureRecognizer(swipe)
            //when rotate - shuffle cards
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards))
            screen.addGestureRecognizer(rotate)

        } }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateViewFromModel()
        //after updating view - turn hint indexes to nil
        self.hintIndexes = nil
    }
    
    //recalculate grid and draw when phone rotates
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.updateViewFromModel()
    }
    
    //shuffle cards on board
    @objc private func shuffleCards() {
        setGame.shuffleCards()
        self.updateViewFromModel()
    }
    
    //select card by position of tap
    @objc private func tapOnCard(touch: UITapGestureRecognizer) {
        let touchLocation = touch.location(in: self.setBoardView)
        //find which card was taped by position in grid
        let cardIndex = getCardIndexFromGrid(location: touchLocation)
        self.cardTouched(index: cardIndex)
    }
    
    //return card index on board by position on grid
    private func getCardIndexFromGrid(location: CGPoint) -> Int? {
        for index in 0..<self.setBoardView!.boardGrid.cellCount {
            let currCard = self.setBoardView!.boardGrid[index]
            if currCard!.contains(location) {
                return index
            }
        }
        return nil
    }
    
    func updateViewFromModel() {
        let cardsCount = setGame.cardOnBoard.count
        //remove old cards from view
        setBoardView.subviews.forEach { $0.removeFromSuperview() }
        //calculate grid
        setBoardView.boardGrid = Grid(layout: .aspectRatio(1), frame: setBoardView.bounds)
        setBoardView.boardGrid.cellCount = cardsCount
        //add cards to board
        self.createNewCardsViewFromGrid()
        //set button "3 more cards" access
        self.dealThreeMoreCardsButton.isEnabled = (setGame.stackCards.count > 0)
        //set score text
        self.scoreText.text = "Score: \(setGame.score)"
        self.playerVSphoneTxt.text = "You: \(setGame.playerPoints) iPhone: \(setGame.phonePoints)  \(self.iPhoneFace)"
        //set scores hidden by game type
        scoreText.isHidden = self.againstIphoneGame
        playerVSphoneTxt.isHidden = !self.againstIphoneGame
    }
    
    //go through cardOnBoard and create cards for view (using grid)
    private func createNewCardsViewFromGrid() {
        for index in setGame.cardOnBoard.indices {
            let card = setGame.cardOnBoard[index]
            let frame = setBoardView.boardGrid[index]!
            let cardView =  SetCardView(frame: frame)
            //set cardView parameters
            cardView.cardContent = self.getCardString(card: card)
            cardView.color = cardColorDict[card.color] as! UIColor
            cardView.filling = cardFillingDict[card.filling]!
            //add mark if needed
            self.updateCardOutline(to: cardView, at: index)
            //add cardView to board
            self.setBoardView.addSubview(cardView)
        }
    }
    
    //set card outline if selected (color by choosenCardState)
    private func updateCardOutline(to card: SetCardView, at index:Int) {
        let currCard = setGame.cardOnBoard[index]
        //if is hint - mark in yellow
        if self.hintIndexes != nil && (self.hintIndexes?.0 == index || self.hintIndexes?.1 == index || self.hintIndexes?.2 == index) {
            card.layer.borderWidth = 2.0
            card.layer.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
        }
        //if chosen card - mark according to state
        else if setGame.selectedCards.contains(currCard) {
            card.layer.borderWidth = 2.0
            card.layer.borderColor = borderColorDict[setGame.choosenCardsState]
        }
        else {
            card.layer.borderWidth = 0
        }
    }
    
    //return card shapes as a string
    private func getCardString(card: SetCard) -> String {
        var res = ""
        for _ in 0..<(self.cardShapeCountDict[card.shapeCount] ?? 0) {
            res += self.cardShapeDict[card.shape] ?? "?"
        }
        return res
    }
    
    //select card when card touched
    private func cardTouched(index: Int?) {
        if let cardIndex = index {
            setGame.cardSelected(cardIndex: cardIndex, isByPlayer: true)
            updateViewFromModel()
            //if game against phone - after a match restart the timer for more random times
            if self.againstIphoneGame, self.setGame.choosenCardsState == .match {
                self.timer.invalidate()
                self.makePhoneMove()
            }
        }
        else {
            print("touch not on card")
        }
        //if no more sets and no cards in stack - game ended
        if self.setGame.findSet() == nil && self.setGame.stackCards.count == 0 {
            self.gameEnded()
        }
    }
    
    @IBAction func addThreeCards(_ sender: Any) {
        setGame.addThreeCardsButtonPressed()
        self.updateViewFromModel()
    }
    
    @IBAction func NewGame(_ sender: Any?) {
        self.setGame = SetGameModel()
        //stop game with phone (if was befor)
        self.againstIphoneGame = false
        self.timer.invalidate()
        self.updateViewFromModel()
    }
    
    //if there is set - color 3 cards in yellow
    @IBAction func getHint(_ sender: Any) {
        self.hintIndexes = setGame.getHint()
        self.updateViewFromModel()
    }
    

    //pop alert when game is ended
    func gameEnded() {
        var message = "your score: \(setGame.score)"
        //different message for game against phone
        if self.againstIphoneGame {
            switch setGame.playerPoints {
            case let player where player > setGame.phonePoints:
                message = "You won! you: \(player) iPhone: \(setGame.phonePoints)"
                self.iPhoneFace = "😢"
            case let player where player < setGame.phonePoints:
                message = "iPhone won! you: \(player) iPhone: \(setGame.phonePoints)"
                self.iPhoneFace = "😂"
            default:
                message = "Its a tie!"
                self.iPhoneFace = "😬"
            }
        }
        self.updateViewFromModel()
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
            let alert = UIAlertController(title: "Game Ended!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: { action in
                self.NewGame(nil)
            }))
            self.timer.invalidate()
            self.present(alert, animated: true)
        })
        
    }
    
    //start a new game against the iphone
    @IBAction func playAgainstIPhone(_ sender: Any) {
        self.againstIphoneGame = true
        //start a new game
        self.setGame = SetGameModel()
        self.updateViewFromModel()
        //make a move until player find a set
        self.makePhoneMove()
    }
    
    private func getRandomTime() -> Double {
        return Double.random(in: 5.0...10.0)
    }
    
    private func makePhoneMove() {
        self.timer = Timer.scheduledTimer(withTimeInterval: self.getRandomTime(), repeats: true, block: { timer in
            if self.setGame.possibleMoveExist() {
                self.iPhoneFace = "😁"
                self.updateViewFromModel()
                _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in
                    self.view.isUserInteractionEnabled = false
                    self.setGame.makePhoneMove()
                    self.view.isUserInteractionEnabled = true
                    self.iPhoneFace = "🤔"
                    self.updateViewFromModel()
                })
            }
        })
    }
}

