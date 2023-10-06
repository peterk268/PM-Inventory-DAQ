//
//  AddItemView.swift
//  PM Inventory
//
//  Created by Peter Khouly on 5/21/23.
//

import SwiftUI
import RealmSwift

struct AddItemView: View {
    @ObservedResults(Item.self, sortDescriptor: newSortDescriptor) var items
    
    @Environment (\.dismiss) var dismiss
    @State var itemName = ""
    @State var description = ""
    @State var location = ""
    @State var amount = 1

    var body: some View {
        Form {
            TextField("Item Name", text: $itemName)
            TextField("Description", text: $description)
            TextField("Location", text: $location)
            Stepper("Amount: \(amount)", value: $amount, in: 0...100)

            Button {
                $items.append(.init(name: itemName, caption: description, location: location, amount: amount))
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Add Item")
                    Spacer()
                }
            }
            .disabled(itemName.isEmpty || location.isEmpty)
        }
        .navigationTitle("Add Item")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
            }
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
    }
}
