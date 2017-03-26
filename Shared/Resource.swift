//
//  Resource.swift
//  sim
//
//  Created by Snorri Sturluson on 26/03/2017.
//  Copyright © 2017 Snorri Sturluson. All rights reserved.
//

import Foundation
class Resource {
    var type: String
    var quantity: Int
    
    init(type: String, quantity: Int) {
        self.type = type
        self.quantity = quantity
    }
}
