//
//  ExampleApp.swift
//  ExampleApp
//
//  Created by Milos Rankovic on 21/03/2021.
//

@_exported import CoreData
@_exported import SwiftUI
@_exported import Shrub

@main
struct ExampleApp: App {

    @State private var json: JSON = [
        "sources": [
            ["name": "Yay"],
            ["name": "Double Yay"],
        ]
    ]
    
    var body: some Scene {
        return WindowGroup {
            Group {
                Sources(json: $json["sources"])
            }
        }
    }
}

struct Sources: View {
    
    @Binding var json: JSON
    
    var body: some View {
        NavigationView {
            Group {
                List {
                    ForEach(json.branches.sorted()) { branch in
                        Text("\(json[branch, "name"] ?? "😱")")
                    }
                    .onDelete(perform: {_ in})
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Sources", displayMode: .large)
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: add) {
                    Label("Add", systemImage: "plus")
                }
            )
        }
    }
    
    func add() {
        let i = json.branches.count
        json[^i, "name"] = "Yay ✕ \(i)"
    }
}
