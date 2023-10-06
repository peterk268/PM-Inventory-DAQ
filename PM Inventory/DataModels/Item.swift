//
//  Item.swift
//  PM Inventory
//
//  Created by Peter Khouly on 5/21/23.
//

import Foundation
import RealmSwift
import CryptoKit

class Item: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var caption: String
    @Persisted var location: String
    @Persisted var amount: Int
    
    var createdAt: Date {
        self._id.timestamp
    }
    
    
    convenience init(name: String, caption: String, location: String, amount: Int) {
        self.init()
        self.name = name
        self.caption = caption
        self.location = location
        self.amount = amount
    }
}

var newSortDescriptor: RealmSwift.SortDescriptor {
    return .init(keyPath: "_id", ascending: false)
}
