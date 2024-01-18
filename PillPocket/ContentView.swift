/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct ContentView: View {
    @State  var selectedTab = 0
   // @State private var showAlert = false
    @EnvironmentObject var remindersManager: RemindersManager

    var body: some View {
        /*TabView {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "clock")
                        
                }*/

        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Today", systemImage: "clock")
                }
                .tag(0)
            
            
            
            
            
        AddView(selectedTab: $selectedTab) // Pass the binding here
                .tabItem {
                    Label("Add", systemImage: "plus")
                }
            
            

           
            
            
            
                .tag(1)
            RefillsView()
                .tabItem {
                    Label("Refills", systemImage: "waterbottle.fill")
                }
                .tag(2)
            /*FunFactsView()
             .tabItem {
             Label("Reminder", systemImage: "bell")
             }*/
           /* ReminderView() // Assuming this is the "Reminder" view
                .tabItem {
                    Label("Reminder", systemImage: "bell")
                }
                .tag(3) // Assuming this is the fourth tab*/
            
            MedicationReminderView() // Assuming this is the "Reminder" view
                            .tabItem {
                                Label("Reminders", systemImage: "bell")
                            }
                            .tag(3)
        }
        
        
       
        
        
        
        
    }//body
    
    
    
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
// test github
