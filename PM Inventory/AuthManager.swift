//
//  AuthManager.swift
//  PM Inventory
//
//  Created by Peter Khouly on 5/21/23.
//

import Foundation
import RealmSwift

class AuthManager: ObservableObject {
    @Published var syncUser: RealmSwift.User?
    
    static var shared = AuthManager.init()
    private init() {
        self.startAuthListener()
    }
    func startAuthListener() {
        Task {
            try? await self.logIntoMongoDB()
        }
    }
    
    private func logIntoMongoDB() async throws {
        let syncUser: RealmSwift.User
        if let currentSyncUser = app.currentUser, currentSyncUser.isLoggedIn {
            syncUser = currentSyncUser
        } else {
            syncUser = try await app.login(credentials: .anonymous)
        }
        
        configureSync(syncUser: syncUser)

        let _ = try? await getDataRealm(downloadBefore: true)

        await MainActor.run {
            self.syncUser = syncUser
        }
    }
    
}

// Opening a realm and accessing it must be done from the same thread.
// Marking this function as `@MainActor` avoids threading-related issues.
@MainActor
func getDataRealm(downloadBefore: Bool = false) async throws -> Realm {
    let realm = try await Realm(downloadBeforeOpen: downloadBefore ? .always : .once)
    let subscriptions = realm.subscriptions
    let foundSubscription = subscriptions.first(named: "all_daq")
    // connection check needed to not stop user from loading up w/o internet as subscriptions stops Realm from going through.
    if foundSubscription == nil, realm.syncSession?.connectionState == .connected {
        try await subscriptions.update {
            subscriptions.append(QuerySubscription<Item>(name: "all_items"))
            subscriptions.append(QuerySubscription<DAQ>(name: "all_daq"))
        }
    }
    return realm
}
