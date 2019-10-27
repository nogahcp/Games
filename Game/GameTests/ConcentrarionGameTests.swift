//
//  ConcentrarionGameTests.swift
//  GameTests
//
//  Created by Nogah Melamed Cohen on 27/10/2019.
//  Copyright © 2019 Nogah Melamed Cohen. All rights reserved.
//
import XCTest
@testable import Game

//import Foundation

class ConcentrationGameTests: XCTestCase {
    var concentrationGame = ConcentrationModel(numberOfCardsPairs: 8)
    
    override func setUp() {
        concentrationGame = ConcentrationModel(numberOfCardsPairs: 8)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //check if after card flip the card is now face up
    func testCardFlip() {
        concentrationGame.cardFlip(cardIndex: 0)
        XCTAssertTrue(concentrationGame.cards[0].isFaceUp)
    }

    //check if after flipping two cards they both faceUp
    func testFlipTwoCards() {
        concentrationGame.cardFlip(cardIndex: 0)
        concentrationGame.cardFlip(cardIndex: 1)
        XCTAssertTrue(concentrationGame.cards[0].isFaceUp && concentrationGame.cards[1].isFaceUp)
    }
    
    //check if after flipping three cards only the last one is face up
    func testFlipThreeCards() {
        concentrationGame.cardFlip(cardIndex: 0)
        concentrationGame.cardFlip(cardIndex: 1)
        concentrationGame.cardFlip(cardIndex: 2)

        XCTAssertTrue(!concentrationGame.cards[0].isFaceUp && !concentrationGame.cards[1].isFaceUp && concentrationGame.cards[2].isFaceUp)
    }

}
