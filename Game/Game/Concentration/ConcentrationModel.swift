//
//  ConcentrationModel.swift
//  ConcentrationGame
//
//  Created by Nogah Melamed Cohen on 03/10/2019.
//  Copyright © 2019 Nogah Melamed Cohen. All rights reserved.
//

import Foundation

class ConcentrationModel
{
    var cards = [Card]()
    var flippedCard:Int?
    var score=0
    var moves=0
    init(numberOfCardsPairs:Int) {
        for _ in 0..<numberOfCardsPairs
        {
            let tempCard=Card()
            cards+=[tempCard, tempCard]
        }
        shuffleCards()
    }
    
    
    func cardFlip(cardIndex:Int)
    {
        if !cards[cardIndex].isMatch
        {
            // this is where we need to explain the logic
            if let matchIndex = flippedCard, matchIndex != cardIndex {
                if cards[matchIndex].ID == cards[cardIndex].ID
                {
                    cards[cardIndex].isMatch = true
                    cards[matchIndex].isMatch = true
                    score+=2
                }
                else
                {
                    if cards[cardIndex].countFlips > 0
                    {
                        score -= 1
                    }
                    if cards[matchIndex].countFlips > 1
                    {
                        score -= 1
                    }
                }
                cards[cardIndex].isFaceUp = true
                cards[cardIndex].countFlips += 1
                flippedCard = nil
            }
            else
            {
                for currCard in cards.indices
                {
                    cards[currCard].isFaceUp = false
                }
                flippedCard = cardIndex
                cards[cardIndex].isFaceUp = true
                cards[cardIndex].countFlips += 1
            }
        }
        
        moves+=1
    }
    
    func shuffleCards(){
        var newCards=[Card]()
        while cards.count>0
        {
            let index=Int.random(in: 0..<cards.count)
            newCards.append(cards.remove(at: index))
        }
        cards=newCards
    }
}
