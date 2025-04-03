//
//  PasswordManagerApp.swift
//  PasswordManager
//
//  Created by chetu on 02/04/25.
//

import SwiftUI

@main
struct PasswordManagerApp: App {
    let persistenceController = CoreDataManager.shared
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
