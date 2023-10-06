//
//  ContentView.swift
//  PM Inventory
//
//  Created by Peter Khouly on 5/21/23.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @StateObject var authManager: AuthManager = .shared
    
    @ViewBuilder
    var body: some View {
        if authManager.syncUser != nil {
            TabView {
                NavigationStack {
                    DAQView()
                }
                .tabItem {
                    Label("DAQ", systemImage: "car.front.waves.up")
                }

                NavigationStack {
                    InventoryView()
                }
                .tabItem {
                    Label("Inventory", systemImage: "wrench.and.screwdriver")
                }

            }
        } else {
            ProgressView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

let app = App(id: "application-0-lpeou")
let config = Realm.Configuration(schemaVersion: 10, migrationBlock: nil, deleteRealmIfMigrationNeeded: true)

func configureSync(syncUser: RealmSwift.User) {
    var config = syncUser.flexibleSyncConfiguration(clientResetMode: .discardUnsyncedChanges())
    // Pass object types to the Flexible Sync configuration
    // as a temporary workaround for not being able to add a
    // complete schema for a Flexible Sync app.
    config.objectTypes = [Item.self, DAQ.self]
    

    config.schemaVersion = 10
    config.migrationBlock = nil
//    config.deleteRealmIfMigrationNeeded = true
    Realm.Configuration.defaultConfiguration = config
}
