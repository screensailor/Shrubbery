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
        "count": 1,
        "sources": [
            "Source No 1": ["message": "Yay"]
        ]
    ]
    
    var body: some Scene {
        return WindowGroup {
            Sources(count: $json["count", default: 1], json: $json["sources"])
        }
    }
}

extension View {
    
    public func eraseToAnyView() -> AnyView {
        AnyView(erasing: self)
    }
}

public protocol TryView: View where Body == AnyView {
    
    associatedtype DoBody: View
    associatedtype CatchBody: View
    
    func doBody() throws -> DoBody
    func catchBody(_ error: Error) -> CatchBody
}

extension TryView {
    
    public var body: Body {
        do { return try doBody().eraseToAnyView() }
        catch { return catchBody(error).eraseToAnyView() }
    }
}

struct Sources: View {
    
    @Binding var count: Int
    @Binding var json: JSON
    
    var body: some View {
        NavigationView {
            Group {
                List {
                    ForEach(json.branches.sorted()) { branch in
                        VStack {
                            Text(branch.stringValue).font(.headline)
                            Text(json[branch, "message", default: "😱"] as String).font(.subheadline)
                        }
                    }
                    .onDelete{ indices in
                        for i in indices.peek() {
                            let key = json.branches.sorted()[i]
                            json[key] = nil
                        }
                    }
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
        count += 1
        json["Source No \(count)", "message"] = "Yay 😃"
    }
}
