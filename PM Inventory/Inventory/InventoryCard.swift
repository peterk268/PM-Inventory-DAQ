//
//  InventoryCard.swift
//  PM Inventory
//
//  Created by Peter Khouly on 5/21/23.
//

import SwiftUI
import RealmSwift

struct InventoryCard: View {
    @ObservedRealmObject var item: Item
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(item.name)
                    .font(.headline)

                Spacer()
                Text(self.item.createdAt.formatted(date: .numeric, time: .shortened))
                    .foregroundColor(.secondary)
                    .font(.caption2)
            }
            
            if !item.caption.isEmpty {
                Divider()
                
                Text(item.caption)
                    .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                Text("\(Image(systemName: "location.fill")) \(item.location)")
                Spacer()
                Text("\(item.amount)")
                    .foregroundColor(.primary)
            }
            .foregroundColor(.secondary)
            .font(.caption2)
        }
        .multilineTextAlignment(.leading)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct InventoryCard_Previews: PreviewProvider {
    static var previews: some View {
        InventoryCard(item: .init(name: "Steering Wheel", caption: "The Steering Wheel for the car", location: "Attached to the car downstairs on the stand.", amount: 1))
    }
}
