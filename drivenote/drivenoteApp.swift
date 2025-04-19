//
//  drivenoteApp.swift
//  drivenote
//
//  Created by nelson on 18/4/2025.
//

import SwiftUI

// 已被 DriveNoteApp.swift 取代，保留此檔案僅作參考
struct drivenoteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
