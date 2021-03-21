//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by Milos Rankovic on 21/03/2021.
//

import SwiftUI

@main
struct ExampleAppApp: App {
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
