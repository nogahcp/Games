//
//  Theme.swift
//  ConcentrationGame
//
//  Created by Nogah Melamed Cohen on 06/10/2019.
//  Copyright © 2019 Nogah Melamed Cohen. All rights reserved.
//

import Foundation
import UIKit


struct Theme {
    var cardColor:UIColor
    var backgroundColor:UIColor
    var cardEmojis:[String]
    
    init(cardColor:UIColor, backgroundColor:UIColor, cardEmojis:[String]){
        self.cardColor=cardColor
        self.backgroundColor=backgroundColor
        self.cardEmojis=cardEmojis
    }
}
