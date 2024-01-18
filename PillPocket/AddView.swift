import SwiftUI
import Foundation


// Extension goes here
extension Binding {
   func unwrap<Wrapped>(or defaultValue: Wrapped) -> Binding<Wrapped> where Value == Wrapped? {
       return Binding<Wrapped>(
           get: { self.wrappedValue ?? defaultValue },
           set: { self.wrappedValue = $0 }
       )
   }
}

//Kido 1h
struct KeyboardResponsiveModifier: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
                    let value = notif.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height = value.height
                    
                    // Adjust to reduce the offset by the safe area's bottom value to prevent excessive movement.
                    let window = UIApplication.shared.windows.first
                    let bottomSafeAreaInset = window?.safeAreaInsets.bottom ?? 0
                    
                    offset = height - bottomSafeAreaInset // Adjusted to subtract the safe area bottom inset
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    offset = 0
                }
            }
            .onDisappear {
                // Remove observers to prevent memory leaks
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            }
    }
}

extension View {
    func keyboardResponsive() -> some View {
        self.modifier(KeyboardResponsiveModifier())
    }
}


//^kido 1h

var updatedScheduleValues: [String: Any] = [
   "medication": "empty",
   "timings": "empty",
   "taken": false,
   "frequency": "empty",
   "times": 0,
   "quantity": 0,
   "refill": false,
   "lastUpdated": ISO8601DateFormatter().string(from: Date()) // Current date in ISO8601 format
]
struct MedicineRow: Identifiable, Equatable {
   let id: Int64
   var medicine: String
   var frequency: String
   var quantity: Int
   var refill: Bool
   var times: Int
   var lastUpdated: Date // Added date field
   var created: Date
   var deleted: Bool  // New property for deleted status
   var rem1: String? // Added fields
      var rem2: String?
      var rem3: String?
      var rem4: String?
      var wday1: String?
      var wday2: String?
      var wday3: String?
      var wday4: String?
      var wday5: String?
      var wday6: String?
      var wday7: String?
   
   
   
   
   var daysSinceCreated: Int {
          Calendar.current.dateComponents([.day], from: created, to: Date()).day ?? 0
      }
   //Refills quantity left logic
    var quantityLeft_D: Int {
        let calendar = Calendar.current
        let dateComponents: DateComponents
        
        switch frequency {
        case "D":
            dateComponents = calendar.dateComponents([.day], from: created, to: Date())
        case "W":
            dateComponents = calendar.dateComponents([.weekOfYear], from: created, to: Date())
        case "M":
            dateComponents = calendar.dateComponents([.day], from: created, to: Date())
        default:
            return quantity // or some default value
        }
        
        guard let timePeriodCount = dateComponents.value(for: .day) ?? dateComponents.value(for: .weekOfYear) ?? dateComponents.value(for: .month) else {
            return quantity // or some default value
        }
        // print("**REFILL** timePeriodCount",timePeriodCount)
        
        if frequency == "W" || frequency == "D" {
            let daysPending = timePeriodCount * times
            return max(0, ((quantity / times) - daysPending)) // Ensures the result doesn't go below zero
        } else if frequency == "M" {
            return max(0, quantity - timePeriodCount) // For monthly frequency
        } else {
            return 0 // Optionally handle other cases, or return a default value
        }

        
        
        
    }



   // Add id as a parameter to the initializer
   init(id: Int64 = 0, medicine: String, frequency: String, quantity: Int, refill: Bool, times: Int, deleted: Bool, created: Date, rem1: String, rem2: String, rem3: String?, rem4: String, wday1: String, wday2: String, wday3: String, wday4: String?, wday5: String, wday6: String, wday7: String) {
      
       // Initialize lastUpdated
       self.lastUpdated = Date() // or some other initial value
           self.id = id
           self.medicine = medicine
           self.frequency = frequency
           self.quantity = quantity
           self.refill = refill
           self.times = times
           self.deleted = deleted
           self.created = created
           self.rem1 = rem1
           self.rem2 = rem2
           self.rem3 = rem3
           self.rem4 = rem4
           self.wday1 = wday1
           self.wday2 = wday2
           self.wday3 = wday3
           self.wday4 = wday4
           self.wday5 = wday5
           self.wday6 = wday6
           self.wday7 = wday7
   }
}


struct TimesButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isSelected ? .white : .black)
            .padding()
            .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
            .cornerRadius(8)
    }
}




struct CustomButtonStyle_A: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}








struct NewMedicineScreen: View {
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

    
    
    
    
    
    
    
    
    
    
    
    
    
   var body: some View {
    //kido 1h v
       ScrollView {
           VStack {
               Divider()
               Text("New Medicine Screen")
                   .font(.title)
                   .foregroundColor(.blue)
                   .padding()
               
               // Medicine Name
               TextField("Medicine Name", text: $medicine)
                   .textFieldStyle(RoundedBorderTextFieldStyle())
                   .padding()
                   .accessibility(identifier: "medicineNameField")
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
                isQuantityValid = false
                }
                .buttonStyle(FrequencyButtonStyle_AV(isSelected: frequency == "D"))
                
                Button("Weekly") {
                frequency = "W"
                isQuantityValid = false
                }
                .buttonStyle(FrequencyButtonStyle_AV(isSelected: frequency == "W"))
                
                Button("Custom") {
                frequency = "M"
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
                               quantity = "" // Clear quantity when times changes
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
                               quantity = "" // Clear quantity when times changes
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
            
                   .onChange(of: quantity) { newValue in
                       if newValue.isEmpty || newValue.allSatisfy({ $0.isNumber }) {
                           validateQuantity()
                       } else {
                           // Revert to previous numeric value if new value is not numeric
                           quantity = String(newValue.dropLast())
                       }
                   }
               
               if !isQuantityValid {
                   //Text("Quantity has to be > or = times")
                       //.foregroundColor(.red)
                   Text("Invalid Quantity: please recheck")
                       .foregroundColor(.red)
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
                           }
                       }
               }
               
               
               
               
               
               
               
               Spacer() // Pushes everything to the top
           }
           
           
           
           
           .padding()
           
           .onTapGesture {
               self.hideKeyboard()
           }
           .keyboardResponsive()    //Kido 1h
           
           
       }// Scroll view end.  //kido 1h
     
       
       
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
              // print("Medicine added successfully")
           frequency="D"
           times="1"
           
          } catch {
              // print("Error adding medicine: \(error)")
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


struct NewMedicineScreen_Previews: PreviewProvider {
   static var previews: some View {
       NewMedicineScreen()
   }
}

struct EditMedicineView: View {
   @Binding var medicine: MedicineRow
   @State private var updateSuccessful: Bool = false
   @State private var deleteSuccessful: Bool = false
   @State private var isValidFrequency: Bool = true // New state variable
   @State private var isValidTimes_edit: Bool = true
    @State private var isQuantityValid: Bool = false // New state variable for quantity validation
    @State private var isDatePickerPresented_edit: Bool = false
    @State private var newquantity1: Int = 0 // To store the converted quantity
    @State private var hasQuantityChanged: Bool = false
    @State private var tempDateSelection: Date//KIDO 2_3:1b for Edit: Date picker and fix insert

    @State private var showAlert_edit = false
    @State private var newtimes: Int
    @State private var selectedNumber: Int = 0 // Declare the variable here
   // Computed property for times
    @State private var quantityInput: String = ""
    @State private var created_edit = Date()

    
    @State private var showAlert = false
    @State private var alertMessage = ""

    
    
    
    
    
    
    
    
   private var timesString: Binding<String> {
          Binding<String>(
              get: { String(self.medicine.times) },
              set: {
                  if let value = Int($0) {
                      self.medicine.times = value
                  }
              }
          )
      }
   private var quantityString: Binding<String> {
       Binding<String>(
           get: { String(self.medicine.quantity) },
           set: {
               if let value = Int($0) {
                   self.medicine.quantity = value
               }
           }
       )
   }
    

 
    
    
    
    
    
    
    
    
    
  
    init(medicine: Binding<MedicineRow>) {
        self._medicine = medicine
        // Initialize newtimes with the current value of medicine.times
        self._newtimes = State(initialValue: medicine.wrappedValue.times)
       
        // Initialize tempDateSelection with the current created date from the medicine
            // Ensure to safely unwrap the binding's wrapped value or provide a fallback value
            self._tempDateSelection = State(initialValue: medicine.wrappedValue.created)
    }


   
    
    
    private var dateFormatter2_N_edit: DateFormatter {
        let formatter = DateFormatter()
        // Set the locale if you want to ensure the format works well with specific locale settings, e.g., 24-hour clock
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Combine medium date style with custom time format
        formatter.dateFormat = "MMM d, yyyy h:mm a" // Example: Jan 3, 2024 9:30 PM
        return formatter
    }

    
    
    
    
    
    
    

    var body: some View {
        
        let timesInt = medicine.times
        let quantityInt=medicine.quantity
        @State  var newfrequency=medicine.frequency
       
        // @State  var newtimes=medicine.times
        var newquantity=medicine.quantity
        
        
        
        
        
        
        
        
        //Kido 1I
        ScrollView {
            VStack(alignment: .leading) {
                Divider()
                Text("Edit/Delete Medicine Screen")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity) // Stretching the frame to the maximum width
                    .multilineTextAlignment(.center) // Aligning the text in the center
                
                
                
                // Medicine Name
                HStack {
                    Spacer().frame(width: 30)  // Adjust the width as needed
                    Text("Medicine Name")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)
                
                HStack {
                    Spacer().frame(width: 30)  // Adjust the width as needed
                    TextField("Enter Medicine Name", text: $medicine.medicine)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.bottom, 5)
                
                // Frequency
                HStack {
                    Spacer().frame(width: 30)  // Adjust the width as needed
                    Text("Frequency: Enter D for Daily, W for Weekly, M for Custom")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                }
                
                
                
                
                .padding(.vertical, 3)
                
                HStack {
                    Spacer().frame(width: 30)  // Adjust the width as needed
                    
              
                    
                    // Frequency Buttons
                    HStack {
                        Button("Daily") {
                            medicine.frequency = "D"
                            newfrequency = "D" // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.frequency == "D"))
                        
                        Button("Weekly") {
                            medicine.frequency = "W"
                            newfrequency = "W" // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.frequency == "W"))
                        
                        Button("Custom") {
                            medicine.frequency = "M"
                            newfrequency = "M" // Capturing the new value
                            
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.frequency == "M"))
                    }
                    .padding()
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
                .padding(.bottom, 10)
                // Display error message if invalid frequency
                if !isValidFrequency {
                    Text("Only 'D', 'W', or 'M' are accepted")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 30)
                }
                
                
                if medicine.frequency == "D" || medicine.frequency == "W"
                // Your code here
                
                
                
                {
                    
                    
                    
                    // Times
                    HStack {
                        Spacer().frame(width: 30)  // Adjust the width as needed
                        Text("Times")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    .padding(.vertical, 3)
                }
                
                
                if medicine.frequency == "M"
                // Your code here
                
                
                {   // Times
                    
                    HStack {
                        Spacer().frame(width: 30)  // Adjust the width as needed
                        Text("Number of days to take 1 dose")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        
                    }
                    
                    .padding(.vertical, 3)
                    
                }
                
                
                
             
                
                if medicine.frequency == "D" {
                    // Frequency Buttons
                    HStack {
                        Spacer().frame(width: 30)
                        
                        Button("1") {
                            medicine.times = 1
                            newtimes = 1 // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.times == 1))
                        
                        Button("2") {
                            medicine.times = 2
                            newtimes = 2 // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.times == 2))
                        
                        Button("3") {
                            medicine.times = 3
                            newtimes = 3 // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.times == 3))
                        
                        Button("4") {
                            medicine.times = 4
                            newtimes = 4 // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected:  medicine.times == 4))
                        
                        
                        
                        
                        
                        
                    }
                    .padding()
                }
                
                
                
                
                
                
                
                
                
                
                
             
                
                
                
                if medicine.frequency == "W" {
                    // Frequency Buttons
                    HStack {
                        Spacer().frame(width: 30)
                        Button("1") {
                            medicine.times = 1
                            newtimes = 1 // Capturing the new value
                            medicine.quantity = 0
                            
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.times == 1))
                        
                        Button("2") {
                            medicine.times = 2
                            newtimes = 2 // Capturing the new value
                            medicine.quantity = 0
                            
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.times == 2))
                        
                        Button("3") {
                            medicine.times = 3
                            newtimes = 3 // Capturing the new value
                            medicine.quantity = 0
                            
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.times == 3))
                        
                        Button("4") {
                            medicine.times = 4
                            newtimes = 4 // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected:  medicine.times == 4))
                        
                        Button("5") {
                            medicine.times = 5
                            newtimes = 5 // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected:  medicine.times == 5))
                        
                        
                        Button("6") {
                            medicine.times = 6
                            newtimes = 6 // Capturing the new value
                            medicine.quantity = 0
                        }
                        .buttonStyle(FrequencyButtonStyle_AV(isSelected: medicine.times == 6))
                        
                        
                        
                        
                        
                    }
                    .padding()
                }
                
                
                
                
                
                
                
                
                
                
                
                
                if medicine.frequency == "M"
                {
                    
                    HStack {
                        Spacer().frame(width: 30)  // Adjust the width as needed
                        TextField("Enter no.days you take 1 pill:", text: timesString)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        
                    }
                    .padding(.bottom, 5)
                    
                    
                }
                
                
                
                
                
                
                
                // Quantity
                HStack {
                    Spacer().frame(width: 30)  // Adjust the width as needed
                    Text("Total Quantity")
                        .font(.headline)
                        .foregroundColor(.blue)
              //  }
               // .padding(.vertical, 2)
               
                
                
                
                
                
                
                
                
                
                
               // HStack {
                    Spacer().frame(width: 30)  // Adjust the width as needed
                    TextField("Enter Total Quantity", text: quantityString)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                        .onChange(of: medicine.quantity) { newValue in
                            hasQuantityChanged = true
                            newquantity = newValue
                            
                            
                            
                            
                           
                            if newfrequency == "M" {
                                isQuantityValid = newquantity > 0
                            } else if (newfrequency == "D" || newfrequency == "W") {
                                isQuantityValid = newquantity >= newtimes && newquantity % newtimes == 0
                            } else {
                                isQuantityValid = true // Assume valid for all other frequencies
                            }

                            
                            
                            
                            
                            
                        
                            
                        }
                    
                    
                    
                }
                
                
                
                
                
                
                
                
                
                
                .onAppear {
                    
                    
                    if hasQuantityChanged {
                        if (newfrequency == "D" || newfrequency == "W") && newquantity > 0 {
                            isQuantityValid = newquantity >= newtimes && newquantity % newtimes == 0
                        } else {
                            isQuantityValid = true // Always valid for frequencies other than "D" and "W"
                        }
                    } else {
                        // If quantity has not been changed, check if it satisfies the conditions
                        if (newfrequency == "D" || newfrequency == "W") && medicine.quantity > 0 {
                            isQuantityValid = medicine.quantity >= newtimes && medicine.quantity % newtimes == 0
                        } else {
                            isQuantityValid = false
                        }
                    }
                    
                    
                    
                    
                    
                }
                
                
                
                
                
                
                
                .padding(.bottom, 10)
           
                if newfrequency == "W" || newfrequency == "D" {
                    if !isQuantityValid {
                        Text("Invalid Quantity: please recheck")
                            .foregroundColor(.red)
                       // Text("Quantity should be a multiple of times")
                          //  .foregroundColor(.red)
                        // .padding(.leading, 30) // Uncomment this if you want to add padding
                    }
                } else if newfrequency == "M" {
                    if !isQuantityValid { // Assuming you adjust `isQuantityValid` for "M" as per your condition
                        Text("Quantity must be > 0")
                            .foregroundColor(.red)
                        // .padding(.leading, 30) // Uncomment this if you want to add padding
                    }
                }

                
                
                
                
                
                
                
                
                
                
                
                // Refill Toggle
                HStack {
                    Spacer().frame(width: 30)  // Adjust the width as needed
                    Toggle(isOn: $medicine.refill) {
                        Text("Refill Needed")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                
          
                
                
                HStack {
                    
                    Spacer().frame(width: 30)
                    Text("Fullfillment Date/Time:")
                        .font(.headline)
                        .foregroundColor(.blue)
               
                }
                HStack {
                    Spacer().frame(width: 30)
                    Text(medicine.created, formatter: dateFormatter2_N_edit) // Ensure your dateFormatter2_N_edit can format time as well
                    Button("Click to change") {
                        tempDateSelection = medicine.created // Initialize the temporary date selection
                        isDatePickerPresented_edit = true
                    }
                    .buttonStyle(CustomButtonStyle_A())
                }
                    
            
                .sheet(isPresented: $isDatePickerPresented_edit) {
                    VStack {
                        Text("Fullfillment Date/Time:")
                            .foregroundColor(.blue)
                        DatePicker("Date and Time Fulfilled", selection: $tempDateSelection, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                        
                        Button("Done") {
                            if isDatePickerPresented_edit { // Check if the DatePicker is presented
                                medicine.created = tempDateSelection // Update only if the DatePicker is presented
                            }
                            isDatePickerPresented_edit = false // Then close the DatePicker
                        }
                        .padding()
                    }
                }

                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                //XOXO
                
               /*
                Button(action: {
                    // Action for Edit button
                    if isValidFrequency || isValidTimes_edit {
                        do {
                            try DatabaseManager.shared.updateMedicineRow(medicine)
                            // print("Medicine updated successfully")
                            updateSuccessful = true
                            // You might want to handle UI changes or navigation here after successful update
                            
                            
                            
                            
                            
                            
                            
                        } catch {
                            // print("Error updating medicine: \(error)")
                            updateSuccessful = false
                        }
                    }
                }) {
                    Text("Edit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isValidFrequency &&  isValidTimes_edit && isQuantityValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                
                */
                
                //XOXO
                
                
                Button(action: {
                    if isValidFrequency || isValidTimes_edit {
                        do {
                            try DatabaseManager.shared.updateMedicineRow(medicine)
                            alertMessage = "Medicine updated successfully"
                            showAlert = true
                            
                            // Automatically dismiss the alert after 2 seconds
                            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                                showAlert = false
                            }
                            
                        } catch {
                            // print("Error updating medicine: \(error)")
                            alertMessage = "Error updating medicine"
                            showAlert = true
                        }
                    }
                }) {
                    Text("Edit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isValidFrequency && isValidTimes_edit && isQuantityValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }

                
                
                
                
                
                
                
                
                
                
                
                
                .disabled(!isValidFrequency || !isValidTimes_edit || !isQuantityValid)
                
                
                
                
                
                
                
                Spacer() // Spacer between the buttons
                
                
                
                
                
                
                // Delete Button
                Button(action: {
                    do {
                        try DatabaseManager.shared.markMedicineRowAsDeleted(medicine)
                        // print("Medicine marked as deleted successfully")
                        deleteSuccessful = true
                    } catch {
                        // print("Error marking medicine as deleted: \(error)")
                        deleteSuccessful = false
                    }
                }) {
                    Text("Delete")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                
                
                
                if updateSuccessful {
                    Text("Edit successful")
                        .foregroundColor(.green)
                        .font(.title3)
                        .padding()
                }
                
                if deleteSuccessful {
                    Text("Delete successful")
                        .foregroundColor(.red)
                        .font(.title3)
                        .padding()
                }
                Spacer() // To center the buttons
                
                
                
                
                
                    .padding()
                
            }.padding(.horizontal)
            
            
            
            
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Update Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

            
                .onTapGesture {
                    self.hideKeyboard()
                }
                .keyboardResponsive()
        }// Kido 1I
           
           
    
   }
    
     
}



// Custom Button Style
struct FrequencyButtonStyle_AV: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isSelected ? .white : .gray)
            .padding()
            .background(isSelected ? Color.green : Color.gray.opacity(0.3))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}











struct AddView: View {
    
    
    @EnvironmentObject var databaseManager: DatabaseManager
    
    
    
    
    
   // Sample data for the table
   @State private var showNewMedicineScreen = false // Declare this new state variable
   @State private var selectedMedicine: MedicineRow?  // Changed: State variable to hold the selected medicine
      @State private var showingEditScreen = false  // Changed: State variable to control navigation to the edit screen
  
  
    
    
    
    
   private func loadMedicines() {
       do {
           let fetchedMedicines = try DatabaseManager.shared.fetchSchedule()
           self.medicines = fetchedMedicines
               .filter { !$0.deleted }  // Filter out records where deleted is true
               .map { schedule in
                   MedicineRow(
                       id: schedule.id, // Ensure this is the correct ID type
                       medicine: schedule.medication,
                       frequency: schedule.frequency,
                       quantity: schedule.quantity,
                       refill: schedule.refill,
                       times: schedule.times,
                       deleted: schedule.deleted,
                       created: ISO8601DateFormatter().date(from: schedule.created) ?? Date(),
                       rem1: schedule.rem1,
                       rem2: schedule.rem2,
                       rem3: schedule.rem3,
                       rem4: schedule.rem4,
                       wday1: schedule.wday1,
                       wday2: schedule.wday2,
                       wday3: schedule.wday3,
                       wday4: schedule.wday4,
                       wday5: schedule.wday5,
                       wday6: schedule.wday6,
                       wday7: schedule.wday7
                   )
               }.sorted { $0.lastUpdated > $1.lastUpdated }
       } catch {
           // print("Error loading medicines: \(error)")
       }
   }
    



       
   @Environment(\.presentationMode) var presentationMode
   @Binding var selectedTab: Int
   private let medicineWidth: CGFloat = 100
   private let timingsWidth: CGFloat = 60
   private let qtyWidth: CGFloat = 70
   private let refillwidth:CGFloat = 70
   private let imgwidth:CGFloat = 20
   @State private var newMedicineName: String = ""
   @State private var editingMedicine: MedicineRow? // A copy for editing purposes
   private let fallbackMedicineRow = MedicineRow(id: 0, medicine: "", frequency: "", quantity: 0, refill: false, times: 0,deleted: false,created: Date.now,rem1:"",rem2:"",rem3:"",rem4:"",wday1:"",wday2:"",wday3:"",wday4:"",wday5:"",wday6:"",wday7:"")

   
   // @State private var bottomText: String = "" // State variable for the textbox content
   @State private var bottomText: String = "Ex: MetaMorphin 1 tablet 3 times Daily No Refill"
   @State private var isInitialText: Bool = true // Flag to track initial text
  // @FocusState private var isTextEditorFocused: Bool
   @State private var medicines: [MedicineRow] = [] // This will hold your medicine data from the database
   

   
   
   
   var body: some View {
       NavigationView {
           
          VStack {
            
               Text("Add New/Update Medicines")
                   .font(.title2)
                   .fontWeight(.bold)
                   .foregroundColor(.blue)
                   .frame(maxWidth: .infinity, alignment: .center)
                   .padding()
       
               
               HStack {
                   Spacer()
                   
                   
                   // Add Button
                   Button(action: {
                       // print("Add button tapped")
                       showNewMedicineScreen = true
                       print(showNewMedicineScreen)
                   }) {
                       // HStack {
                       Image(systemName: "plus")
                           .padding()
                           .font(.system(size: 24, weight: .bold)) // Adjust size as needed and make the symbol bold
                           .foregroundColor(.white)
                           .background(Circle().fill(Color.blue))
                           .shadow(radius: 3)
                       Text("Add")
                   }
                   .accessibility(identifier: "addButton")
                   Spacer()
                   Spacer()
           
               
               NavigationLink(destination: NewMedicineScreen(), isActive: $showNewMedicineScreen) {
                   
                   EmptyView()
               }
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               
               Button(action: {
                   try? DatabaseManager.shared.clearScheduleTable()
                   // Refresh schedule data after clearing
                   loadMedicines()
               }//button
               ) {
         
                   
                   Image(systemName: "trash")
                           .font(.system(size: 24, weight: .bold)) // Make the trash icon thicker
                           .foregroundColor(.white) // Set the icon color to white
                           .padding() // Add padding around the icon
                           .background(Circle().fill(Color.red)) // Background circle red for contrast
                           .shadow(radius: 3) // Add shadow for a 3D effect
                   
                   Text("Delete All")
                   //##  }//hstack
                       .foregroundColor(.red) // Set the text color to white
                               .font(.system(size: 20, weight: .medium)) // Adjust the font size and weight as needed
                   
             
                   
                   
                   
                   
               }//(
                   
                   
                   
                   
                   
                   
               .padding(.leading, -50)
                   Spacer()
           }//--
               .padding(15)
               
               // Column Titles
         /*      HStack(spacing: 0) {
                   
             /*      Text("MEDICINE")
                   //.frame(width: geometry.size.width * 0.25, alignment: .leading)
                       .font(.headline)
                       .foregroundColor(.blue)
                       .frame(width: medicineWidth + 30, alignment: .center) // Changed: Increased width
                   // Changed: Added padding
                   
          */
           
                   
                   
               //now   Image(systemName: "calendar.circle.fill")
                   Color.clear
                      //now  .resizable()
                       .scaledToFit()
                       .foregroundColor(.blue) // This changes the color to blue
                       .frame(width: timingsWidth+20,height: 40, alignment: .leading) // Changed: Increased width
                   
                   
                   
                   // now QTY- Add new
                   
                 Text("")
                   //.frame(width: geometry.size.width * 0.15, alignment: .leading)
                       .font(.title3)
                       .foregroundColor(.blue)
                       .frame(width: qtyWidth-30, alignment: .leading)
                   
                   
                   
              
                   
                   
               //now    Image(systemName: "waterbottle.fill")
                   Color.clear
                   //    .resizable()
                       .scaledToFit()
                       .foregroundColor(.blue) // This changes the color to blue
                       .frame(width: refillwidth-10,height: 40, alignment: .center) // Changed: Increased width
                   
                   
                   
                  /* Text("EDIT")
                   //.frame(width: geometry.size.width * 0.2, alignment: .leading)
                       .font(.title3)
                       .foregroundColor(.blue)
                       .frame(width: refillwidth-5, alignment: .center)*/
                   
                   Spacer(minLength: 4) // For the EDIT button
                   
               }//hstack */
               .padding(.horizontal)
               let indexedMedicines = Array(medicines.enumerated())
               
          
              
              
              List {
                  
                  ForEach(indexedMedicines, id: \.element.id) { index, item in
                      
                     // var count = (try? databaseManager.fetchCountForMedicine(medicineName: item.medicine)) ?? -999
                      VStack(alignment: .leading, spacing: 5) {
                          
                         
                          
                          
                          
                           // if (count > 0 ) {
                          
                          
                          HStack {
                              // First Row: Medicine Name
                              Text(item.medicine)
                                  .lineLimit(nil)
                                  .multilineTextAlignment(.leading)
                                  .frame(maxWidth: .infinity, alignment: .leading)
                              // Edit Button
                              
                              Spacer() // Push the button to the right
                              Button(action: {
                                  self.selectedMedicine = item
                                  self.editingMedicine = item // Create a copy for editing
                                  self.showingEditScreen = true
                                  // print("pencil.circle.fill clicked for \(item.medicine)")
                              }) {
                                  Image(systemName: "pencil.circle.fill")
                                      .foregroundColor(.blue)
                                      .font(.system(size: 24))
                              }
                          }
                          
                          // Second Row: Details with 30 spaces at the beginning
                          HStack {
                              Text(String(repeating: " ", count:2)) +
                              Text("\(item.frequency == "D" ? "\(item.times) Pills Daily" : item.frequency == "W" ? "\(item.times) Pills Weekly" : item.frequency == "M" ? "Every \(item.times) Days" : item.frequency), QTY: \(item.quantity), Refill: \(item.refill ? "Yes" : "No")")
                          }
                          .fixedSize(horizontal: false, vertical: true)
                          
                     // }
                      
                          
                      }//vstack
                     
                      
                      
                      
                   /*  .onAppear {
                          // print("****List item at index \(index): \(item.medicine)")
                          // print("****Indexed Medicines: \(indexedMedicines)")
                          // print("*****Medicine Count: \(indexedMedicines.count)")
                      }*/
                  }//for
              }
              .listStyle(GroupedListStyle())

              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
               NavigationLink(destination: EditMedicineView(medicine: $editingMedicine.unwrap(or: fallbackMedicineRow)), isActive: $showingEditScreen) {
                   EmptyView()
               }
              
              
              


                           }// Vstack
           
           //----------------------------------------------
       
          
           
           
           .onChange(of: editingMedicine) { newValue in
               guard let newValue = newValue else { return }
               if let index = medicines.firstIndex(where: { $0.id == newValue.id }) {
                   medicines[index] = newValue
               } else {
                   // Handle the case where the item is new or not found
                   medicines.append(newValue)
               }
           }
               
                                  .navigationBarItems(trailing: Button("Back") {
                                      selectedTab = 0
                                  })
                                  .onAppear {
                                      loadMedicines()
                                  }
                              }
                          }
                      }

   struct AddView_Previews: PreviewProvider {
       @State static var selectedTab = 0 // Dummy state for preview
       
       static var previews: some View {
           AddView(selectedTab: $selectedTab) // Pass the binding here
       }
   }
   
   
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

   
extension MedicineRow {
    var frequencyDescription: String {
        switch frequency {
        case "D":
            return "Daily"
        case "W":
            return "Weekly"
        case "M":
            return "Once every"
        default:
            return frequency // Return the original value if it doesn't match
        }
    }
}





