//
//  Item.swift
//  incident-overview
//
//  Created by Tom Wentworth on 7/30/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
