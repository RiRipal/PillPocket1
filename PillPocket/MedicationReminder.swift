
import SwiftUI
import UserNotifications
import SwiftUI
import Combine

// MedicineReminderViewModel.swift
class MedicineReminderViewModel: ObservableObject {
    @Published var medicines: [MedicineRow] = []
    @Published var isButtonClicked: Bool = false
    @Published var selectedFrequency: String = "D" // Default to "Daily"
   
  
    
    
    func updateScheduleForMedication(medication: String, selectedWeekdays: [String: Bool]) {
        let dayColumns = ["Sun": "wday1", "Mon": "wday2", "Tue": "wday3", "Wed": "wday4", "Thu": "wday5", "Fri": "wday6", "Sat": "wday7"]
        let dayNumbers = ["Sun": "0", "Mon": "1", "Tue": "2", "Wed": "3", "Thu": "4", "Fri": "5", "Sat": "6"]

        do {
            for (day, isSelected) in selectedWeekdays {
                if let dayColumn = dayColumns[day] {
                    let dayValue = isSelected ? dayNumbers[day] : ""  // Use "0" to represent a non-selected day
                    // print("Updating: \(day) - Column: \(dayColumn), Value: \(dayValue ?? "")")
                    try DatabaseManager.shared.updateDayForMedication(medication: medication, dayColumn: dayColumn, dayValue: dayValue ?? "")
                }
            }
        } catch {
             print("Error updating schedule: \(error)")
        }
    }

    
    
    
    
    
    
    
    // Function to load medicines
    func loadMedicines() {
        do {
            let schedules = try DatabaseManager.shared.fetchSchedule()
            self.medicines = schedules.map { MedicineRow(from: $0) }
        } catch {
             print("Error loading medicines: \(error)")
        }
    }
    
    
    
}



// MedicationReminderView.swift
struct MedicationReminderView: View {
    @StateObject var viewModel = MedicineReminderViewModel()

    @State private var scheduleData: [Schedule] = []
    private let medicineWidth: CGFloat = 100
    private let timesWidth:CGFloat=50
    private let timingsWidth: CGFloat = 70
    private let takenWidth: CGFloat = 70
    private let imgWidth: CGFloat = 20
   


    private func loadScheduleData() {
        do {
            let fetchedData = try DatabaseManager.shared.fetchSchedule().filter { !$0.deleted }
            DispatchQueue.main.async {
                self.scheduleData = fetchedData
                // print("Fetched Schedule Data: \(fetchedData)")
            }
        } catch {
             print("Error fetching schedule: \(error)")
        }
    }

    var body: some View {
            NavigationView {
                VStack {
                    FrequencySelectionView(viewModel: viewModel) // Pass the ViewModel correctly
                        .padding(.top)
                        .padding(.horizontal)
                        .padding()
                    HStack{
                        
                        Image(systemName: "bell").foregroundColor(.red)
                        Text("Set up Reminders for your Medicines")
                        // .font(.title3)
                            .uniformFontSize(18)
                        
                            .padding(.top)
                    }

                    List {
                        
                      
                        Section(header: HStack {
                            
                        
    
                         
                        })
                        
                        
                        {
                            
                            
                            
                    
                            
                            
                        
                            
                            ForEach(scheduleData.filter { schedule in
                                viewModel.selectedFrequency == "All" || schedule.frequency == viewModel.selectedFrequency
                            }) { schedule in
                                
                            let displayTimes2 = schedule.frequency == "M" ? "Every \(schedule.times) Days" : "\(schedule.times) times"

                                NavigationLink(destination: ReminderSetupView(viewModel: viewModel, medication: schedule.medication, scheduleData: scheduleData, selectedFrequency: $viewModel.selectedFrequency, times: schedule.times)) {
                                    // Modified MedicationRowView call to include "times" after schedule.times
                           //     MedicationRowView(schedule: schedule, medicineWidth: medicineWidth+30, timingsWidth: timingsWidth, takenWidth: takenWidth+20, displayTimes: "\(schedule.times) times")
                                    MedicationRowView(schedule: schedule, medicineWidth: medicineWidth+30, timingsWidth: timingsWidth, takenWidth: takenWidth+20, displayTimes: displayTimes2)
                                    
                                }
                            }

                            
                     

           
                            
                            
                            }
                        
                        
                        
                        
                        
                        }
                    }
                    .onAppear(perform: loadScheduleData)
                    .navigationBarTitle("Medicine Reminders")
                
                }
            }
        }





// FrequencySelectionView.swift
struct FrequencySelectionView: View {
    @ObservedObject var viewModel: MedicineReminderViewModel

    var body: some View {
        HStack {
            FrequencyButton(viewModel: viewModel, text: "Daily", frequency: "D")
            FrequencyButton(viewModel: viewModel, text: "Weekly", frequency: "W")
            FrequencyButton(viewModel: viewModel, text: "More..", frequency: "M")
        }
    }
}



struct FrequencyButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(isSelected ? .white : .blue)
            .padding()
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
    }
}


// CheckboxView.swift
struct CheckboxView: View {
    @Binding var isChecked: Bool
    var onChanged: (Bool) -> Void

    var body: some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .onTapGesture {
                isChecked.toggle()
                onChanged(isChecked) // Call the onChanged closure with the new isChecked value
            }
    }
}



// FrequencyButton.swift
struct FrequencyButton: View {
    @ObservedObject var viewModel: MedicineReminderViewModel
    var text: String
    var frequency: String

    var isSelected: Bool {
        viewModel.selectedFrequency == frequency
    }

    var body: some View {
        Button(text) {
            viewModel.selectedFrequency = frequency
            viewModel.isButtonClicked = true
        }
        .buttonStyle(FrequencyButtonStyle(isSelected: isSelected))
    }
}


struct MedicationRowView: View {
    var schedule: Schedule // Changed to non-binding type
    var medicineWidth: CGFloat
    var timingsWidth: CGFloat
    var takenWidth: CGFloat
    var displayTimes: String
 
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
           
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(schedule.medication)
                //.frame(width: medicineWidth-30, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                
                HStack {
                    
                    Spacer().frame(width: 16) // Adjust width for "2 spaces"
                    
                    Text(displayTimes)
                        .frame(width: timingsWidth+10, alignment: .leading)
                        .lineLimit(nil)
                        .uniformFontSize(18)
                    
                    
                    
                    
                    
                    
                    
                    
                    // Conditionally display rem1, rem2, rem3, and rem4 if frequency is "D"
                    if schedule.frequency == "D" {
                        VStack(alignment: .leading) {
                            if !schedule.rem1.isEmpty {
                                Text(schedule.rem1).lineLimit(nil)
                                    .uniformFontSize(18)
                            }
                            if !schedule.rem2.isEmpty {
                                Text(schedule.rem2).lineLimit(nil)
                                    .uniformFontSize(18)
                            }
                            if !schedule.rem3.isEmpty {
                                Text(schedule.rem2).lineLimit(nil)
                                    .uniformFontSize(18)
                            }
                            if !schedule.rem4.isEmpty {
                                Text(schedule.rem2).lineLimit(nil)
                                .uniformFontSize(18) }
                        }
                        .frame(width: timingsWidth+30, alignment: .leading)
                    }
                    
                    
                    Image(systemName: "bell").foregroundColor(.red)
                        .frame(width: timingsWidth-10, alignment: .leading)
                    
                    
                    
                    
                }// Hstack xoxo
                
            }//Vstack
        }
            
            
        }
    
    
    
    
    
}



        

struct ReminderSetupView: View {
    
    
    @ObservedObject var viewModel: MedicineReminderViewModel
    @Binding var selectedFrequency: String
    
    
    
       @State private var selectedWeekdays: [String: Bool] = [
           "Sun": false, "Mon": false, "Tue": false, "Wed": false, "Thu": false, "Fri": false, "Sat": false
      ]
    @State private var selectedWeekdays1: [String: String] = [
         "Sun": "0", "Mon": "1", "Tue": "2", "Wed": "3", "Thu": "4", "Fri": "5", "Sat": "6"
     ]
    
    
    
    
    var medication: String
    var scheduleData: [Schedule]
    @State private var reminderSetSuccess = false
    @State private var reminderTime: Date = Date()
    @State private var reminderSuccessMessage = ""
    var times: Int
    @State private var date1 = Date()
     @State private var date2 = Date()
     @State private var date3 = Date()
     @State private var date4 = Date()
    @State private var monthTimings: String = ""
    @State private var medicineDetails: MedicineRow?
    
    // Update the initializer to accept viewModel
    init(viewModel: MedicineReminderViewModel, medication: String, scheduleData: [Schedule], selectedFrequency: Binding<String>, times: Int) {
           self.viewModel = viewModel
           self.medication = medication
           self.scheduleData = scheduleData
           self._selectedFrequency = selectedFrequency
           self.times = times
       }
    
    
    
    
    
    
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    // Function to handle checkbox changes
      func handleCheckboxChange(day: String, isChecked: Bool) {
          let dayColumn = getDayColumn(day: day)
          let dayValue = isChecked ? day : ""
          
          
          do {
              try DatabaseManager.shared.updateDayForMedication(medication: medication, dayColumn: dayColumn, dayValue: dayValue)
              
              
              
              
              
          } catch {
               print("Error updating day: \(error)")
          }
      }
    
    
    // Helper function to map day to column name
        func getDayColumn(day: String) -> String {
            switch day {
            case "Sun": return "wday1"
            case "Mon": return "wday2"
            case "Tue": return "wday3"
            case "Wed": return "wday4"
            case "Thu": return "wday5"
            case "Fri": return "wday6"
            case "Sat": return "wday7"
            default: return ""
            }
        }
    
    
    
    
    
    
    
    
    
    
    // Usage in ReminderSetupView body
    
    
    
    var body: some View {
        VStack {
            // First Line: Text
            HStack {
                
                
                Text("Set Reminder Day for \(medication)")
                    .font(.headline)
                
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            }
            .padding()
            
            
            if viewModel.selectedFrequency == "M" {
                VStack {
                   /* HStack {
                        Text("Remind every: ")
                            .padding()
                        TextField("Number of Days", text: $monthTimings)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        Text("days")
                    }
*/
                    HStack {
                        Text("Time")
                            .font(.headline)
                        DatePicker("", selection: $date1, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "en_US"))
                    }
                }
            }
            
            
            
            
            
            
            
            
           
            
           // Weekly button setup
            if selectedFrequency == "W" {
                
                
                
                VStack {
                    Text(medication + " needs to be taken on the following days")

                            .font(.headline)
                            .padding()

                        ForEach(scheduleData, id: \.medication) { schedule in
                            if medication == schedule.medication {
                                HStack {
                                    Text(weekdayName(for: schedule.wday1))
                                    Text(weekdayName(for: schedule.wday2))
                                    Text(weekdayName(for: schedule.wday3))
                                    Text(weekdayName(for: schedule.wday4))
                                    Text(weekdayName(for: schedule.wday5))
                                    Text(weekdayName(for: schedule.wday6))
                                    Text(weekdayName(for: schedule.wday7))
                                }
                            }
                        }
                    }
                

                
                
                
                
                
                
                
                
                
                
                
                
                
                HStack {
                    Text("Time")
                        .font(.headline) // Adjust font as needed
                    DatePicker("", selection: $date1, displayedComponents: .hourAndMinute)
                        .labelsHidden() // Hide the default label
                        .environment(\.locale, Locale(identifier: "en_US")) // Locale for 12-hour format
                }
                
                
            }

            // Daily button set up
            if selectedFrequency == "D" {
                
                // Second Line: DatePicker
                ScrollView {
                    VStack {
                        
                        switch times {
                        case 1:
                            DatePicker("Reminder 1", selection: $date1, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                        case 2:
                            DatePicker("Reminder 1", selection: $date1, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                            DatePicker("Reminder 2", selection: $date2, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                        case 3:
                            DatePicker("Reminder 1", selection: $date1, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                            DatePicker("Reminder 2", selection: $date2, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                            DatePicker("Reminder 3", selection: $date3, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                        case 4:
                            DatePicker("Reminder 1", selection: $date1, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                            DatePicker("Reminder 2", selection: $date2, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                            DatePicker("Reminder 3", selection: $date3, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                            DatePicker("Reminder 4", selection: $date4, displayedComponents: .hourAndMinute)
                                .environment(\.locale, Locale(identifier: "en_US")) // Set to a locale that uses 12-hour format
                        default:
                            Text("No reminders set")
                        }
                    }
                }
            }
          
        
            
            
            
            
            
            
            
            
            
            // Third Line: Button
            HStack {
                Spacer()
                Button("Set Reminder") {
                    // Logic to save the reminder to the database
                    if viewModel.selectedFrequency == "D"{
                saveReminder()
            }
                    
                    if viewModel.selectedFrequency == "W" {
                        
                        
                        
                    
                        
                        
                            // Convert the DatePicker time to the required date format
                            let formattedTime = formatDate(date1) // This is a String

                            // Convert the formatted string back to a Date
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "hh:mm a"
                            if let reminderTime = dateFormatter.date(from: formattedTime) {
                                // Update the reminder for the selected medication
                                do {
                                    try DatabaseManager.shared.updateReminderTimeForMedication_week(
                                        medicationName: medication,
                                       // newMonthDays: monthTimings,
                                        newReminderTime: reminderTime) // Pass Date object
                                    reminderSetSuccess = true
                                    reminderSuccessMessage = "Weekly reminder set successfully for \(medication)."
                                } catch {
                                     print("Error setting Weekly reminder: \(error)")
                                    reminderSetSuccess = false
                                }
                            } else {
                                print("Error: Invalid date format")
                            }
                        
                        
                        
                       }
                    
                    
                    
                    
                    
                    
                    
                    
                    if (viewModel.selectedFrequency == "M" ){
                        // Convert the DatePicker time to the required date format
                        let formattedTime = formatDate(date1) // This is a String

                        // Convert the formatted string back to a Date
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm a"
                        if let reminderTime = dateFormatter.date(from: formattedTime) {
                            // Update the reminder for the selected medication
                            do {
                                try DatabaseManager.shared.updateReminderTimeForMedication_month(
                                    medicationName: medication,
                                   // newMonthDays: monthTimings,
                                    newReminderTime: reminderTime) // Pass Date object
                                reminderSetSuccess = true
                                reminderSuccessMessage = "More Options reminder set successfully for \(medication)."
                            } catch {
                                 print("Error setting more options reminder: \(error)")
                                reminderSetSuccess = false
                            }
                        } else {
                             print("Error: Invalid date format")
                        }
                    }

                    
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
                
                
            }
            if reminderSetSuccess {
                Text(reminderSuccessMessage)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .padding()
    }
    
    
    
    
    
    //

    
    
    
    
    
   
    
    
    
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // 12-hour format with AM/PM
        return formatter.string(from: date)
    }
    
    
    
    
    
    
    private func saveReminder() {
        let reminder = MedicationReminder(medication: medication, reminderTime: reminderTime)
        let formattedMonthTimings = "\(monthTimings)" // Convert monthTimings to String if needed
            let formattedDate1 = formatDate(date1) // Use your existing formatDate function

        
      
        
        
        
        
        
        do {
            try DatabaseManager.shared.clearReminderTimes(medicationName: medication)

            try DatabaseManager.shared.insertMedicationReminder(reminder)
            
            if let currentSchedule = scheduleData.first(where: { $0.medication == medication }) {
                var calendar = Calendar.current
                calendar.timeZone = TimeZone.current
                
                // Update the reminders based on the current schedule times
                switch currentSchedule.times {
                case 1:
                    // Update rem1
                 
                    try updateReminders(reminders: ["rem1": date1])
                case 2:
                    // Update rem1 and rem2
                   // let rem2Time = calendar.date(byAdding: .hour, value: 12, to: reminderTime) ?? reminderTime
                    try updateReminders(reminders: ["rem1": date1, "rem2": date2])
                case 3:
                    // Update rem1, rem2, and rem3
                    //let rem2Time = calendar.date(byAdding: .hour, value: 8, to: reminderTime) ?? reminderTime
                   // let rem3Time = calendar.date(byAdding: .hour, value: 16, to: reminderTime) ?? reminderTime
                    try updateReminders(reminders: ["rem1": date1, "rem2": date2, "rem3": date3])
                case 4:
                    // Update rem1, rem2, rem3, and rem4
                    //let rem2Time = calendar.date(byAdding: .hour, value: 6, to: reminderTime) ?? reminderTime
                    //let rem3Time = calendar.date(byAdding: .hour, value: 12, to: reminderTime) ?? reminderTime
                   // let rem4Time = calendar.date(byAdding: .hour, value: 18, to: reminderTime) ?? reminderTime
                    try updateReminders(reminders: ["rem1": date1, "rem2": date2, "rem3": date3, "rem4": date4])
                default:
                    break
                }
                
                // Fetch and print updated reminder times from the database
                let updatedReminders = try DatabaseManager.shared.fetchReminderTimesForMedication(medicationName: medication)
                reminderSetSuccess = true
                reminderSuccessMessage = "Reminder for \(medication) set successfully at: " +
                updatedReminders.map { "\($0.key.uppercased()): \($0.value)" }.joined(separator: ", ")
                RemindersManager.shared.updateRemindersAndNotifications()
            } else {
                // print("Medication schedule not found")
            }
        } catch {
             print("Error setting reminder: \(error)")
            reminderSetSuccess = false
        }
    }
    
    // Helper function to update multiple reminders
   private func updateReminders(reminders: [String: Date]) throws {
        for (key, time) in reminders {
            try DatabaseManager.shared.updateReminderTimeForMedication(medicationName: medication, newTime: time, forReminder: key)
        }
    }
   
    
    //private func updateReminders_month(medication: String, monthDays: String, reminderTime: Date) throws {
        private func updateReminders_month(medication: String, reminderTime: Date) throws {
        let formattedReminderTime = formatDate2(reminderTime)
        // Update the month_days and rem1 columns for the specified medication
        try DatabaseManager.shared.updateReminderTimeForMedication_month(
            medicationName: medication,
           // newMonthDays: monthTimings,
            newReminderTime: reminderTime)

    }



    // Helper function to format the date
    private func formatDate2(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // 12-hour format with AM/PM
        return formatter.string(from: date)
    }

    
    
    private func weekdayName(for dayNumber: String?) -> String {
             guard let dayNumber = dayNumber, let number = Int(dayNumber) else {
                 return ""
             }
             let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
             return weekdays[number]
         }
     }
    
    
    
    
    


       

// CheckboxGroup View
struct CheckboxGroup: View {
    var days: [String]
    @Binding var selectedWeekdays: [String: Bool]
    var onCheckboxChange: (String, Bool) -> Void

    var body: some View {
        HStack {
            ForEach(days, id: \.self) { day in
                HStack {
                    Text(day)
                    CheckboxView(isChecked: Binding(
                        get: { self.selectedWeekdays[day] ?? false },
                        set: {
                            self.selectedWeekdays[day] = $0
                            self.onCheckboxChange(day, $0)
                        }
                    ), onChanged: { newValue in
                        self.onCheckboxChange(day, newValue)
                    })
                }
            }
        }
    }
}

extension MedicineRow {
    init(from schedule: Schedule) {
        let isoFormatter = ISO8601DateFormatter()
        
        self.id = schedule.id // Adjust based on your actual structure
        self.medicine = schedule.medication
        // Initialize other properties similarly...
        self.frequency = schedule.frequency
        self.quantity = schedule.quantity
        self.refill = schedule.refill
 
        self.times = schedule.times
        self.deleted = schedule.deleted
        self.created = isoFormatter.date(from: schedule.created) ?? Date()
        self.lastUpdated = isoFormatter.date(from: schedule.lastUpdated) ?? Date()
        self.rem1 = schedule.rem1
        self.rem2 = schedule.rem2
        self.rem3 = schedule.rem3
        self.rem4 = schedule.rem4
        self.wday1 = schedule.wday1
        self.wday2 = schedule.wday2
        self.wday3 = schedule.wday3
        self.wday4 = schedule.wday4
        self.wday5 = schedule.wday5
        self.wday6 = schedule.wday6
        self.wday7 = schedule.wday7
        
        
    }
    
}
struct UniformFontSizeModifier: ViewModifier {
    var size: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.system(size: size))
    }
}
extension View {
    func uniformFontSize(_ size: CGFloat) -> some View {
        self.modifier(UniformFontSizeModifier(size: size))
    }
}
