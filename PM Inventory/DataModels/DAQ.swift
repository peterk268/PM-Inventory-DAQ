//
//  DAQ.swift
//  PM Inventory
//
//  Created by Peter Khouly on 10/5/23.
//

import Foundation
import RealmSwift

class DAQ: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var testName: String
    
    @Persisted var accelerationX: Int
    @Persisted var accelerationY: Int
    @Persisted var accelerationZ: Int
    
    var createdAt: Date {
        self._id.timestamp
    }
    
    
    convenience init(testName: String, accelerationX: Int, accelerationY: Int, accelerationZ: Int) {
        self.init()
        self.testName = testName
        self.accelerationX = accelerationX
        self.accelerationY = accelerationY
        self.accelerationZ = accelerationZ
    }
}
