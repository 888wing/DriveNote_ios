//
//  drivenoteApp.swift
//  drivenote
//
//  Created by nelson on 18/4/2025.
//

import SwiftUI

@main
struct drivenoteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
