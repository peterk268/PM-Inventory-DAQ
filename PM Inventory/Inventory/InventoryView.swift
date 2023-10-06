//
//  InventoryView.swift
//  PM Inventory
//
//  Created by Peter Khouly on 5/21/23.
//

import SwiftUI
import RealmSwift

struct InventoryView: View {
    @ObservedResults(Item.self, sortDescriptor: newSortDescriptor) var items
    @State var search: String = ""
    @State var showAdd: Bool = false
    
    var filteredItems: Results<Item> {
        return items.where({ item in
            if search.isEmpty {
                // generic true query
                return item.amount > -1
            } else {
                return item.name.contains(search, options: .caseInsensitive) || item.caption.contains(search, options: .caseInsensitive) || item.location.contains(search, options: .caseInsensitive)
            }
        })
    }
    var body: some View {
        List {
            ForEach(filteredItems) { item in
                InventoryCard(item: item)
                    .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                if let index = indexSet.first, filteredItems.indices.contains(index) {
                    $items.remove(filteredItems[index])
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("PM Inventory")
        .searchable(text: $search)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {showAdd = true}) {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                AddItemView()
            }
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InventoryView()
        }
    }
}
