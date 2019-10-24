//
//  Card.swift
//  ConcentrationGame
//
//  Created by Nogah Melamed Cohen on 03/10/2019.
//  Copyright © 2019 Nogah Melamed Cohen. All rights reserved.
//

import Foundation

struct Card {
    var ID:Int
    var isFaceUp=false
    var isMatch=false
    var countFlips=0
    
    static var idGenerate=0
    init() {
        Card.idGenerate+=1
        self.ID=Card.idGenerate
    }
}
