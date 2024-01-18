import SwiftUI

import SwiftUI
import Vision
import VisionKit
import AVFoundation
import NaturalLanguage


struct HomeView: View {
    @StateObject private var sharedViewModel = SharedViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var recognizedText = ""
    @State private var isShowingNewMedicineScreen = false
    @EnvironmentObject var databaseManager: DatabaseManager
    
    
    @State private var recognizedMedicineName: String = ""
    @State private var recognizedQuantity: String = ""
    @State private var noRefill: Bool = false

    
    @Binding var selectedTab: Int
    @State private var remindersOn = false
    @State private var scheduleData: [Schedule] = []
    private let medicineWidth: CGFloat = 100
    private let timingsWidth: CGFloat = 50
    private let takenWidth: CGFloat = 70
    @State private var newReminderHomes: [ReminderHome] = []
    
    @State private var showMedicationReminder = false
    
    @State private var isActive = false // State to control navigation
    
    @State private var notificationsEnabled: Bool = false
    
    let primaryBlue = Color.blue // Adjust this to match the logo's blue
    let lightBlue = Color.blue.opacity(0.3) // Adjust this to match the logo's light blue
    let backgroundColor = Color.white // For background elements
    
    
    
    func checkCameraAvailabilityAndOpen() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
        
        if let _ = deviceDiscoverySession.devices.first {
            // Camera is available, proceed to show image picker with camera
            showingImagePicker = true
        } else {
            // Handle the case where the camera is not available
            // For example, show an alert to the user
            print("Camera not available")
        }
    }
    
    
    
    
    
    
    
    var body: some View {
        VStack {
            
        

            
           
            
            
            
            
            
            
            
            Text("Welcome! ")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .foregroundColor(primaryBlue) // Use primary blue here
            
            
            Text("Your Medication Summary")
                .font(.title2)
                .padding(.top)
                .padding(.bottom)
          //
            Image(systemName: "camera.fill")
            Button("Add Medicine") {
                checkCameraAvailabilityAndOpen()
            }
          
            
            .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(
                                image: $inputImage,
                                recognizedText: $recognizedText,
                                showingImagePicker: $showingImagePicker,
                                isShowingNewMedicineScreen: $isShowingNewMedicineScreen,
                                onRecognitionComplete: { medicineName, quantity, noRefill in
                                    // Update the state variables here
                                    self.recognizedMedicineName = medicineName
                                    self.recognizedQuantity = quantity
                                    self.noRefill = noRefill
                                    self.isShowingNewMedicineScreen = true // This triggers the presentation of NewMedicineScreen_H
                                    
                                    print("*******recognizedMedicineName**********\(recognizedMedicineName)")
                                    print("*******medicineNamee**********\(medicineName)")
                                    
                                    sharedViewModel.medicineName = recognizedMedicineName
                                        sharedViewModel.qtyNumbers = recognizedQuantity
                                        sharedViewModel.foundNoRefillPhrase = noRefill
                                    
                                }
                            )
                        }

            
            
            
             
             
 /*xfox
      
            .sheet(isPresented: $isShowingNewMedicineScreen) {
                NewMedicineScreen_H(viewModel: sharedViewModel)
            }


         xfox   */

            
            
            .sheet(isPresented: $isShowingNewMedicineScreen) {
                NewMedicineScreen_H(viewModel: sharedViewModel, onDismiss: reloadData)
            }

            
            
            
            
            
            
            
            
            Spacer() // Pushes everything to the right
            
         /* xoxo
       
            Button(action: {
                self.selectedTab = 3 // Change to the tab index for MedicationReminderView
            }) {
                HStack {
                    Image(systemName: "bell") // System image (bell icon)
                    Text("Add Reminders")
                }
            }*/
          //  .padding()
            List {
                Section(header: HStack {
                    Text("Medicine")
                        .font(.headline)
                        .foregroundColor(.blue)
                   
                    
                    
                    
                    
                    
                        .frame(width: medicineWidth+50,height: 40, alignment: .leading )
                    
                    
                    
                    
  
                   
                    Image(systemName: "clock.badge.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue) // Custom dark blue
                        .frame(width: 50, height: 30)
                        .frame(width: timingsWidth+60, alignment: .center)
                    Text("Taken?")
                    
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(width: takenWidth, alignment: .leading)
                    
                }//Hstack
                )
                
                {
                    
                    
             
                    
                    ForEach(sortedReminders.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 5) {
                            // First row for the Medicine Name
                            Text(sortedReminders[index].r_S_medicine)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Second row for the rest of the entries, starting with two spaces for alignment
                            HStack {
                                Spacer() // Pushes everything to the right
                                
                                // Check specific conditions for displaying the bell button
                                if (sortedReminders[index].r_I_dosageIter == "1" && sortedReminders[index].r_T_rem1.isEmpty) ||
                                    (sortedReminders[index].r_I_dosageIter == "2" && sortedReminders[index].r_T_rem2.isEmpty) ||
                                    (sortedReminders[index].r_I_dosageIter == "3" && sortedReminders[index].r_T_rem3.isEmpty) ||
                                    (sortedReminders[index].r_I_dosageIter == "4" && sortedReminders[index].r_T_rem4.isEmpty) {
                                    Button(action: {
                                        self.selectedTab = 3 // Change to the tab index for MedicationReminderView
                                    }) {
                                        HStack {
                                            Image(systemName: "bell.fill") // System image (bell icon)
                                            Text("Set Reminder")
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                
                                // No `else` statement before the switch as per requirement
                                
                                // Displaying the reminder times using switch
                                Group {
                                    switch sortedReminders[index].r_I_dosageIter {
                                    case "1":
                                        if !sortedReminders[index].r_T_rem1.isEmpty {
                                            Text(formatTime(sortedReminders[index].r_T_rem1))
                                        }
                                    case "2":
                                        if !sortedReminders[index].r_T_rem2.isEmpty {
                                            Text(formatTime(sortedReminders[index].r_T_rem2))
                                        }
                                    case "3":
                                        if !sortedReminders[index].r_T_rem3.isEmpty {
                                            Text(formatTime(sortedReminders[index].r_T_rem3))
                                        }
                                    case "4":
                                        if !sortedReminders[index].r_T_rem4.isEmpty {
                                            Text(formatTime(sortedReminders[index].r_T_rem4))
                                        }
                                    default:
                                        EmptyView() // For values other than 1, 2, 3, and 4
                                    }
                                }
                                .frame(width: timingsWidth+60, alignment: .leading) // Adjust this as needed
                                
                                // Toggle for taken status
                                Toggle("", isOn: Binding<Bool>(
                                    get: { self.sortedReminders[index].r_B_takentoggle },
                                    set: { newValue in
                                        // Update logic as previously defined
                                        if let originalIndex = self.newReminderHomes.firstIndex(where: { $0.r_I_ID == self.sortedReminders[index].r_I_ID }) {
                                            self.newReminderHomes[originalIndex].r_B_takentoggle = newValue
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            do {
                                                try DatabaseManager.shared.updateTakenToggle(reminderID: self.sortedReminders[index].r_I_ID, newStatus: newValue)
                                                databaseManager.checkAndUpdateRemindersHome() 
                                                self.loadRemindersHome()
                                                
                                            } catch {
                                                print("Error updating reminder status: \(error)")
                                            }
                                        }
                                    }
                                ))
                                .labelsHidden()
                                .frame(width: takenWidth, alignment: .trailing) // Adjust alignment as needed
                            }
                        }
                        .padding(.vertical, 5) // Add some padding to separate the rows visually
                    }



                    
                    
                    
                    
                    
                    


                    
                }
          
                
                
                
            }
            
            
            .listStyle(GroupedListStyle())
            
            
            
            
            
            
            
            
        
            
            
            
        }
       
        .onAppear {
            
            
            // Request permission for notifications
            
            
            
            
            LocalNotificationManager.requestPermission()
            LocalNotificationManager.registerNotificationCategory()
            
            // #loadScheduleData()
            
            loadRemindersHome()
            
            //scheduleTodayReminders()
            RemindersManager.shared.updateRemindersAndNotifications()
            
           
         //   LocalNotificationManager.scheduleTestNotification()
            LocalNotificationManager.checkNotificationPermission { enabled in
                self.notificationsEnabled = enabled
                
                
                
                
                
                
                
                
            }
            
            RemindersManager.shared.printScheduledNotifications()
            
            databaseManager.checkAndUpdateRemindersHome()
            self.reloadData() //- camera add.
            
            
            
        }// on appear
    }
    
    
    
    
    
    
    
    
    
    
    
    private func loadRemindersHome() {
        do {
            let reminders = try DatabaseManager.shared.fetchRemindersHome()
            // Filter out reminders that are marked as taken or deleted
            let activeReminders = reminders.filter { !$0.r_B_takentoggle && !$0.r_B_deleted }
            // updateRemindersAndNotifications()
            DispatchQueue.main.async {
                
                
                // fox
                
                
                
                //fox
                
                
                
                self.newReminderHomes = activeReminders
                
                
            }
        }
        catch {
            print("Error fetching reminders: \(error)")
        }
    }
    
    
    
    // Computed property to sort reminders by time
    private var sortedReminders: [ReminderHome] {
        newReminderHomes.sorted { lhs, rhs in
            // Extract the time strings for both reminders
            let lhsTime = getTimeFromReminder(lhs)
            let rhsTime = getTimeFromReminder(rhs)
            return lhsTime < rhsTime
        }
    }
    
    
    // Example of a method in HomeView
    private func reloadData() {
        loadRemindersHome() // Or any other logic to load/display the new data
    }

    
    
    
    
    
    
    
    private func formatTime(_ timeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Input format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: timeString) {
            dateFormatter.dateFormat = "hh:mm a" // Desired output format
            return dateFormatter.string(from: date)
        } else {
            return timeString // Return the original string if conversion fails
        }
    }
    
    
    
    
    
    
    
    
    
    
    // Helper function to extract time from a ReminderHome object
    private func getTimeFromReminder(_ reminder: ReminderHome) -> String {
        switch reminder.r_I_dosageIter {
        case "1":
            return reminder.r_T_rem1
        case "2":
            return reminder.r_T_rem2
        case "3":
            return reminder.r_T_rem3
        case "4":
            return reminder.r_T_rem4
        default:
            return "" // Default or an appropriate value if no time is set
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(selectedTab: .constant(0)) // Provide a constant binding value for the preview
        }
    }

    
    
    
    
   
 
    
}









struct NewMedicineScreen_H: View {
    
    
    
    
       var onDismiss: (() -> Void)?
    
    
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SharedViewModel

    @State private var isShowingNewMedicineScreen = false

   @State private var isValidTimes: Bool = true // New state variable
   @State private var isErrorMessageVisible: Bool = false // New state variable to control error message visibility
    @State private var isQuantityValid: Bool = false// New state variable
    //@State private var selectedFrequency: String = "D"  // Default to "Daily"
    
    
    private var isFormValid: Bool {
        !medicine.isEmpty && !quantity.isEmpty
    }


   @State private var medicine: String = ""
   @State private var frequency: String = "D"
   @State private var quantity: String = "" // Using String to capture input and then convert to Int
   @State private var refill: Bool = false
   @State private var deleted: Bool = false
   @State private var times: String = "1" // Using String for times for similar reasons
   @State private var rem1: String = ""
   @State private var rem2: String = ""
   @State private var rem3: String = ""
   @State private var rem4: String = ""
   @State private var day1: String = ""
   @State private var day2: String = ""
   @State private var day3: String = ""
   @State private var day4: String = ""
   @State private var day5: String = ""
   @State private var day6: String = ""
   @State private var day7: String = ""
   @State private var isValidFrequency: Bool = true
    

   
    @State private var showDatePicker = false
    @State private var isDatePickerPresented = false
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false //Kido 1h
    
    var medicineName: String="" // Use a regular property instead of @State
       var qtyNumbers: String=""
       var foundNoRefillPhrase: Bool=false
 
    
    
  //  init(medicineName: String, qtyNumbers: String, foundNoRefillPhrase: Bool) {
   /*xfox
    init(viewModel: SharedViewModel){
          
           
        self.viewModel = viewModel
        print("*****ViewModel*****")
        print(viewModel)
        print(viewModel.medicineName)
        
        
       
    }
    
    xfox*/
    init(viewModel: SharedViewModel, onDismiss: (() -> Void)? = nil) {
            self.viewModel = viewModel
            self.onDismiss = onDismiss
        print("*****ViewModel*****")
        print(viewModel)
        print(viewModel.medicineName)
        }

    
  
   
   @State private var insertionSuccessful: Bool = false // New state variable
   @State private var isValidFrequency_new: Bool = true // New state variable
   // Make Riya write the code for the above and make Riya write code for the times restriction on Edit and New screen.
   @State private var created = Date() // State variable for the creation date

    // DateFormatter to format the display of the date
 
    private var dateFormatter2_N: DateFormatter {
        let formatter = DateFormatter()
        // Set the locale if you want to ensure the format works well with specific locale settings, e.g., 24-hour clock
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Combine medium date style with custom time format
        formatter.dateFormat = "MMM d, yyyy h:mm a" // Example: Jan 3, 2024 9:30 PM
        return formatter
    }

    
    
    
    // Method to dismiss the keyboard
       private func hideKeyboard() {
           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
       }
    
    
    
    
    
    
    
    
    
    
    
   var body: some View {
    //kido 1h v
       NavigationView {
           ScrollView {
               VStack {
                   Divider()
                  /* Text("New Medicine Screen")
                       .font(.title)
                       .foregroundColor(.blue)
                       .padding()*/
                   
                   // Medicine Name
                   TextField("Medicine Name", text: $medicine)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()
                       .accessibility(identifier: "medicineNameField")
                       .onAppear {
                           // This will set the medicine state when the view appears
                           medicine = viewModel.medicineName
                       }
                   // Frequency
                   
                  
                   
                   if !isValidFrequency {
                       Text("Invalid frequency. Enter 'D', 'W', or 'M'")
                           .foregroundColor(.red)
                           .font(.caption)
                           .padding(.leading, 30)
                   }
                   
                   
                   // Frequency Buttons
                   
                   HStack {
                       Button("Daily") {
                           frequency = "D"
                          
                           isQuantityValid = !viewModel.qtyNumbers.isEmpty
                       }
                       .buttonStyle(FrequencyButtonStyle_AV(isSelected: frequency == "D"))
                       
                       Button("Weekly") {
                           frequency = "W"
                           
                           isQuantityValid = !viewModel.qtyNumbers.isEmpty
                       }
                       .buttonStyle(FrequencyButtonStyle_AV(isSelected: frequency == "W"))
                       
                       Button("Custom") {
                           frequency = "M"
                           isQuantityValid = !viewModel.qtyNumbers.isEmpty
                       }
                       .buttonStyle(FrequencyButtonStyle_AV(isSelected: frequency == "M"))
                   }
                   
                   
                   
                   
                   
                   .padding()
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                 
                   
                   // Inside NewMedicineScreen's body
                   if frequency == "W" {
                       
                       HStack {
                           ForEach(1...6, id: \.self) { number in
                               Button("\(number)") {
                                   // Set the times variable when a button is tapped
                                   self.times = "\(number)"
                                   //quantity = "" // Clear quantity when times changes
                                   quantity = viewModel.qtyNumbers
                                   isQuantityValid = !viewModel.qtyNumbers.isEmpty
                               }
                               .buttonStyle(TimesButtonStyle(isSelected: self.times == "\(number)"))
                           }
                       }
                       .padding()
                   }
                   
                   // Inside NewMedicineScreen's body
                   if frequency == "D" {
                       HStack {
                           ForEach(1...4, id: \.self) { number in
                               Button("\(number)") {
                                   // Set the times variable when a button is tapped
                                   self.times = "\(number)"
                                   //quantity = "" // Clear quantity when times changes
                                   quantity = viewModel.qtyNumbers
                                   isQuantityValid = !viewModel.qtyNumbers.isEmpty
                               }
                               .buttonStyle(TimesButtonStyle(isSelected: self.times == "\(number)"))
                           }
                       }
                       .padding()
                   }
                   
                   
                   
                 
                   
                   
                   if(frequency == "M") {
                       VStack {
                           HStack {
                               Text("Number of Days for 1 dose: ")
                                   .foregroundColor(.blue)
                                   .font(.title2)
                                   .padding(.leading) // Add space on the left side
                               
                               Spacer() // Use a spacer to push the text and text field apart
                               
                               TextField("", text: $times)
                                   .keyboardType(.numberPad)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .frame(width: 100) // Explicitly set the width of the TextField
                                   .padding(.trailing) // Add padding on the right for spacing
                                   .onChange(of: times) { newValue in
                                       validateQuantity()
                                       isValidTimes = true
                                       isValidFrequency_new = true
                                   }
                           }
                           .padding(.horizontal) // Add horizontal padding to the HStack for overall spacing
                       }
                   }
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   // Quantity
                   
                   TextField("Total Quantity", text: $quantity)
                       .keyboardType(.numberPad) // To get numeric keyboard
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()
                       .onAppear {
                           // This will set the medicine state when the view appears
                           quantity = viewModel.qtyNumbers
                           refill = !(viewModel.foundNoRefillPhrase)
                           
                       }
                
                       .onChange(of: quantity) { newValue in
                           if newValue.isEmpty || newValue.allSatisfy({ $0.isNumber }) {
                               validateQuantity()
                           } else {
                               // Revert to previous numeric value if new value is not numeric
                               quantity = String(newValue.dropLast())
                           }
                       }
                   
                   if !isQuantityValid {
                       Text("Invalid Quantity: please recheck")
                           .foregroundColor(.red)
                     //  Text("Quantity should be a multiple of times")
                         //  .foregroundColor(.red)
                       // .font(.caption)
                           .padding()
                       
                   }
                   
                   
                   
                 
                   VStack{
                       HStack {
                           
                           Text("Fulfillment Date/Time: ")
                               .foregroundColor(.blue)
                               .font(.title3)
                           
                           Text("\(created, formatter: dateFormatter2_N)")
                       }
                       .padding()
                       Button("Click to set Fulfill Date/Time") {
                           isDatePickerPresented = true
                       }
                       .buttonStyle(CustomButtonStyle_A())
                   }
                   .sheet(isPresented: $isDatePickerPresented) {
                       VStack {
                           //DatePicker("Date Fulfilled", selection: $created, displayedComponents: .date)
                           
                           DatePicker("Date and Time Fulfilled", selection: $created, displayedComponents: [.date, .hourAndMinute])
                           
                           
                           
                           
                               .datePickerStyle(WheelDatePickerStyle())
                               .labelsHidden()
                           
                           Button("Done") {
                               isDatePickerPresented = false
                           }
                           .padding()
                       }
                   }
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   // Refill Toggle
                   Toggle(isOn: $refill) {
                       Text("Refill Needed")
                   }
                   .padding()
                   
                   
                   // Add Button
                   Button(action: {
                       if isValidTimes && isValidFrequency && isQuantityValid && isFormValid{
                           // Add medicine to database
                           addMedicineToDatabase()
                       }
                   }) {
                       Text("Add")
                           .foregroundColor(.white)
                           .padding()
                           .frame(maxWidth: .infinity)
                       // .background(isValidTimes && isValidFrequency && isQuantityValid ? Color.blue : Color.gray)
                       //.cornerRadius(10)
                       
                           .background(isValidTimes && isValidFrequency && isQuantityValid && isFormValid ? Color.blue : Color.gray)
                           .cornerRadius(10)
                       
                       
                       
                   }
                   .padding()
                   .disabled(!isValidTimes || !isValidFrequency || !isQuantityValid || !isFormValid) // Disable button based on the new condition
                   // Error Message
                   
                   // Display an error message if times input is invalid and not already displaying a success message
                   if !isValidTimes && !insertionSuccessful && isErrorMessageVisible {
                       Text("Check the values")
                           .foregroundColor(.red)
                           .font(.caption)
                           .padding()
                   }
                   
                   
                 
                   
                   
                   
                   if insertionSuccessful && showSuccessMessage {
                       
                       Text("Medicine added successfully")
                       
                           .foregroundColor(.green)
                           .padding()
                           .onAppear {
                               DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                   showSuccessMessage = false
                                   // Reset the SharedViewModel values here
                                                 viewModel.medicineName = ""
                                                 viewModel.qtyNumbers = ""
                                              viewModel.foundNoRefillPhrase = false
                               }
                               
                               
                               print("NewMedicineScreen_H appeared with medicineName: \(medicineName)")
                               
                               
                               
                           }
                   }
                   
                   
                   
                   
                   
                   
                   
                   Spacer() // Pushes everything to the top
               }
               .navigationBarTitle("Add New Medicine", displayMode: .inline)
               .navigationBarItems(leading: Button(action: {
                   self.presentationMode.wrappedValue.dismiss()
               }) {
                   Image(systemName: "xmark")
                       .imageScale(.large)
                       .accessibility(label: Text("Close"))
               })
               
               
               
               .padding()
               
               .onTapGesture {
                   self.hideKeyboard()
               }
               .keyboardResponsive()    //Kido 1h
               
               
           }// Scroll view end.  //kido 1h
           
           .onTapGesture {
                              self.hideKeyboard()
                          }
           
           
           
           
       }// Navigation View
       .onDisappear {
           self.onDismiss?()
           // Action to perform when the view disappears
       }
       
   }
   
   private func addMedicineToDatabase() {
        let quantityInt = Int(quantity) ?? 0
       let timesInt = Int(times) ?? 0
       let createdDateStr = ISO8601DateFormatter().string(from: created) // Convert Date to String

       let newMedicineRow = MedicineRow(
           medicine: medicine,
           frequency: frequency,
           quantity: quantityInt,
           refill: refill,
           times: timesInt,
           deleted: deleted,
           created: created,
           rem1: rem1,
           rem2: rem2,
           rem3: rem3,
           rem4: rem4,
           wday1: day1,
           wday2: day2,
           wday3: day3,
           wday4: day4,
           wday5: day5,
           wday6: day6,
           wday7: day7
       )
           
           
       
 
       
       do {
              try DatabaseManager.shared.insertMedicineRow(newMedicineRow)
              insertionSuccessful = true
              showSuccessMessage = true
              clearInputFields() // Call function to clear fields
              print("Medicine added successfully")
           frequency="D"
           times="1"
           
          } catch {
              print("Error adding medicine: \(error)")
              insertionSuccessful = false
          }
       
       
       
       
   }
   
   private func clearInputFields() {
          medicine = ""
          frequency = ""
          quantity = ""
          refill = false
          times = ""
       
      }
    
    // Function to validate quantity
      private func validateQuantity() {
          if frequency == "D" || frequency == "W",
             let quantityInt = Int(quantity), let timesInt = Int(times), timesInt > 0 {
              isQuantityValid = quantityInt >= timesInt && quantityInt % timesInt == 0
          } else {
              isQuantityValid = true // Always valid for frequencies other than "D" and "W"
          }
      }
   
}


struct NewMedicineScreen_H_Previews: PreviewProvider {
    
   static var previews: some View {
      // NewMedicineScreen_H()
       @StateObject var sharedViewModel = SharedViewModel()
       NewMedicineScreen_H(viewModel: sharedViewModel)
       
          
   }
}
class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: ImagePicker
    var recognizedText: String = ""
    @Binding var showingImagePicker: Bool // Add this line
    @Binding var isShowingNewMedicineScreen: Bool // Add this line
   

    
    var onRecognitionComplete: ((String, String, Bool) -> Void)?
    
    
    init(_ parent: ImagePicker, showingImagePicker: Binding<Bool>, isShowingNewMedicineScreen: Binding<Bool>, onRecognitionComplete: ((String, String, Bool) -> Void)?) {
            self.parent = parent
            self._showingImagePicker = showingImagePicker
            self._isShowingNewMedicineScreen = isShowingNewMedicineScreen
            self.onRecognitionComplete = onRecognitionComplete
            super.init() // Now all properties are initialized before this call
        }

    
    
    
    
    
    

   //xoxo init(_ parent: ImagePicker, showingImagePicker: Binding<Bool>) { // Modify this line
    init(_ parent: ImagePicker, showingImagePicker: Binding<Bool>, isShowingNewMedicineScreen: Binding<Bool>) {
        self.parent = parent
        self._showingImagePicker = showingImagePicker // Modify this line
        self._isShowingNewMedicineScreen = isShowingNewMedicineScreen // Assign the new binding
    }
    
    
   
    
    
    
 
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                recognizeText(from: uiImage)
            }
            self.showingImagePicker = false // Modify this line to hide the picker
        }
 

    
    func checkCameraAvailabilityAndOpen() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
        
        if let _ = deviceDiscoverySession.devices.first {
            // Camera is available, proceed to show image picker with camera
            showingImagePicker = true
        } else {
            // Handle the case where the camera is not available
            // For example, show an alert to the user
            print("Camera not available")
        }
    }
    
    
    
  /* Fox M  3/19/8:30PM
    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self?.parent.recognizedText = recognizedStrings
           //     self?.analyzeTextForMedication(recognizedStrings) // Analyze the recognized text for medication names
               
                
                self?.analyzeTextForChemicalTerms(recognizedStrings) // Analyze the recognized text for medication names
                
                
                
                   
                print("Recognized Text: \(recognizedStrings)") // Print the recognized text
            }

        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    } */ // Fox M 3/19/8:30PM

    

    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self?.parent.recognizedText = recognizedStrings
           //     self?.analyzeTextForMedication(recognizedStrings) // Analyze the recognized text for medication names
               
                
                //self?.analyzeTextForChemicalTerms(recognizedStrings) // Analyze the recognized text for medication names
                
                self?.analyzeTextForChemicalTerms(recognizedStrings, image: image)
                
                   
                print("Recognized Text: \(recognizedStrings)") // Print the recognized text
            }

        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    
    
    
    
    
    
    


    // The new function for analyzing the text for chemical terms
//Fox M 3/19/8:30PM

  /*  private func analyzeTextForChemicalTerms(_ text: String) {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameTypeOrLexicalClass])
        tagger.string = text
        var uniqueTerms = Set<String>()
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let tags: [NLTag] = [.noun, .otherWord]

        var termFrequencies = [String: Int]() // Dictionary to track frequency of each term
        let excludedWords = Set(["TABLET", "TABLETS", "STORE"]) // Words to be excluded

        // Check for "NO REFILL", "NO REFILLS", and "0 REFILLS" presence
        let noRefillPhrases = ["NO REFILL", "NO REFILLS", "0 REFILLS"]
        var foundNoRefillPhrase = false

        for phrase in noRefillPhrases {
            if text.localizedStandardContains(phrase) {
                foundNoRefillPhrase = true
                break // Stop searching once any of the phrases is found
            }
        }

        // Regular expression to find "QTY: numbers" and "OTY: numbers"
        let qtyRegex = try! NSRegularExpression(pattern: "(QTY|OTY):\\s*(\\d+)", options: [])
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        var qtyNumbers = [String]()

        qtyRegex.enumerateMatches(in: text, options: [], range: nsRange) { match, _, _ in
            if let matchRange = match?.range(at: 2), let range = Range(matchRange, in: text) { // Note: changed to match.range(at: 2) to capture the number group
                let number = String(text[range])
                qtyNumbers.append(number)
            }
        }

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange -> Bool in
            let token = String(text[tokenRange])
            // Check if the token meets all conditions and is not in the excluded words list
            
            
            if let tag = tag, tags.contains(tag), token == token.uppercased(), token.count > 3, !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: token)), !excludedWords.contains(token) {
                termFrequencies[token, default: 0] += 1 // Increment the frequency count for the token
                uniqueTerms.insert(token)
            }
            return true
        }
        
        let medicineName = termFrequencies.filter { $0.value >= 2 }.map { $0.key }
        

        
        
        
        // Filter for terms that appear twice or more, which gives us repeated terms
          let repeatedTerms = termFrequencies.filter { $0.value >= 2 }.map { $0.key }

        print("zMedicine Name\(medicineName.first)")
        print("zMedicine Name count\(medicineName.count)")
        print("Found 'NO REFILL', 'NO REFILLS', or '0 REFILLS' phrase: \(foundNoRefillPhrase)")
        print("Quantities found: \(qtyNumbers)")
        isShowingNewMedicineScreen=true
       // =medicineName
        // Check if the array is not empty and assign the first element to recognizedText
       
       
        
        
        
        
          // Now, check if the repeatedTerms array contains exactly one unique word
          if medicineName.count == 1 {
              // If there is exactly one repeated term, proceed
     
              
              DispatchQueue.main.async {
                          self.onRecognitionComplete?(medicineName.first ?? "", qtyNumbers.first ?? "", foundNoRefillPhrase)
                      }
              
              
              
              
          }
        
        
        
        
        
        
    }

    
    */ // fox M 3/19/8:30PM for capturing text in line
    
    
    //fox N for the above
    private func analyzeTextForChemicalTerms(_ text: String, image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var foundMedicineNames = [String]()
            var foundQuantities = [String]()
            var foundNoRefill = false
            var captureNextLine = false  // Flag to start capturing lines
            
            
            for observation in observations {
                let topCandidate = observation.topCandidates(1).first
                guard let recognizedText = topCandidate?.string else { continue }
                
                // Split the recognized text by spaces to analyze each word
                let words = recognizedText.split(separator: " ").map(String.init)
                let uniqueWords = Set(words)
                var wordCounts = [String: Int]()
                
                // Check if we have found "Prescription Information"
                            if recognizedText.contains("Prescription Information") {
                                captureNextLine = true
                                continue  // Skip this line and go to the next one
                            }
                
                
                // If the flag is set, start capturing the lines
                if captureNextLine {
                               // You can process this line as per your requirement
                               // Here, we are just adding the whole line to the foundMedicineNames array
                               foundMedicineNames.append(recognizedText)
                               captureNextLine = false  // Reset the flag if you only want the next line
                           }
                
                
                
                
                // Check for no refill phrases within the recognized line
                if recognizedText.contains("NO REFILL") || recognizedText.contains("NO REFILLS") || recognizedText.contains("0 REFILLS") {
                    foundNoRefill = true
                }
                
                // Example for finding quantities, looking for "QTY: number" or "OTY: number"
                let qtyPattern = "(QTY|OTY):\\s*(\\d+)"
                let regex = try! NSRegularExpression(pattern: qtyPattern, options: [])
                let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)

                // Find matches in the recognized text
                regex.enumerateMatches(in: text, options: [], range: nsRange) { match, _, _ in
                    if let matchRange = match?.range(at: 2), let swiftRange = Range(matchRange, in: text) {
                        // Extract the quantity number from the recognized text
                        let qtyNumber = String(text[swiftRange])
                        foundQuantities.append(qtyNumber)
                    }
                }

            }
            
            DispatchQueue.main.async {
                // Update your UI or process data here
                // For simplicity, let's just log the found names and quantities
                print("Found Medicine Names: \(foundMedicineNames)")
                print("Found Quantities: \(foundQuantities)")
                print("Found No Refill: \(foundNoRefill)")
                
                // Use the first found medicine name and quantity for onRecognitionComplete callback
                // This is a simplification; you might want to handle multiple results differently
                if let firstMedicineName = foundMedicineNames.first, let firstQuantity = foundQuantities.first {
                    self?.onRecognitionComplete?(firstMedicineName, firstQuantity, foundNoRefill)
                }
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var recognizedText: String
    @Binding var showingImagePicker: Bool // Add this line
    @Binding var isShowingNewMedicineScreen: Bool // Add this line
    var onRecognitionComplete: ((String, String, Bool) -> Void)? // Add this line


    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator // This should not cause an error now
        return picker
    }

    
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
  
    
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(self, showingImagePicker: $showingImagePicker, isShowingNewMedicineScreen: $isShowingNewMedicineScreen, onRecognitionComplete: onRecognitionComplete)
    }


    

}
class SharedViewModel: ObservableObject {
    @Published var medicineName: String = ""
    @Published var qtyNumbers: String = ""
    @Published var foundNoRefillPhrase: Bool = false
}
