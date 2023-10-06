//
//  DAQView.swift
//  PM Inventory
//
//  Created by Peter Khouly on 10/5/23.
//

import SwiftUI
import RealmSwift
import Charts

struct DAQView: View {
    @ObservedResults(DAQ.self, sortDescriptor: newSortDescriptor) var daqs
    @StateObject private var vm = DAQViewModel()
    
    @State private var testName = ""
    @State private var isTesting = false
    
    var body: some View {
        List {
            if vm.isConnected {
                if isTesting {
                    Chart(daqs) { daq in
                        PointMark(
                            x: .value("X Accel", daq.accelerationX),
                            y: .value("Y Accel", daq.accelerationY)
                        )
                    }
                    ForEach(daqs) { daq in
                        Section {
                            Text("X: " + String(daq.accelerationX))
                            Text("Y: " + String(daq.accelerationY))
                            Text("Z: " + String(daq.accelerationZ))
                            Text("Time: " + daq.createdAt.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                } else {
                    TextField("Test Name", text: $testName)
                    Button("Start Test", action: startTest)
                        .disabled(testName.isEmpty)
                }
            } else {
                Button("Connect to PM-DAQ", action: vm.initializeCentralManager)
            }
        }
        .onChange(of: vm.recievedAccelData, perform: { newValue in
            if let newValue {
                self.$daqs.append(.init(testName: self.testName, accelerationX: newValue.x, accelerationY: newValue.y, accelerationZ: newValue.z))
            }
        })
        .toolbar {
            if isTesting {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: stopTest) {
                        Image(systemName: "xmark.circle")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("DAQ")
    }
    
    func startTest() {
        isTesting = true
        Task {
            while(true) {
                if let characteristic = vm.characteristic {
                    await vm.readValueFromChar(withCharacteristic: characteristic)
                    // on change will handle delegate function callback of read data
                }
                try? await Task.sleep(for: .seconds(0.5))
                if vm.peripheral == nil {
                    break
                }
            }
        }

    }
    func stopTest() {
        isTesting = false
        testName = ""
    }
}

struct DAQView_Previews: PreviewProvider {
    static var previews: some View {
        DAQView()
    }
}
