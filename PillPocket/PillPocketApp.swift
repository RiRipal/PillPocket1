//
//  PillPocketApp.swift
//  PillPocket
//
//  Created by ramya nomula on 1/18/24.
//

import SwiftUI

@main

// Refactored to use asynchronous data loading in PillPocketApp.swift

struct PillPocketApp: App {
    @State private var isDataLoaded = false
    
    init() {
        NotificationManager.shared
        
       LocalNotificationManager.requestPermission()
       LocalNotificationManager.registerNotificationCategory()
    }
    
    
  

    
    
    
    
    
    
    var body: some Scene {
        WindowGroup {
            
            
            
            if isDataLoaded {
                ContentView()
                
            // Your main content view
                
                    .environmentObject(RemindersManager.shared) // Inject here
                
                    .environmentObject(DatabaseManager.shared)
                
                
            } else {
                LoadingView()
                    .onAppear {
                        loadDataAsync()
                        
                    }
            }
        }
    }
    
    private func loadDataAsync() {
        DispatchQueue.global(qos: .background).async {
            // Simulate data loading
            sleep(2) // Simulate a network request or heavy computation
            
            DispatchQueue.main.async {
                self.isDataLoaded = true
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        Text("Loading...")
            .font(.title)
            .foregroundColor(.gray)
    }
}

