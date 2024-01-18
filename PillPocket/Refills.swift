import SwiftUI
extension DateFormatter {
    static let displayFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Choose a style that fits your need
        formatter.timeStyle = .none
        return formatter
    }()
}

struct RefillsView: View {
    
    
    @EnvironmentObject var databaseManager: DatabaseManager
    
    
    
    
    @State private var medicinesWithRefill: [MedicineRow] = []
    @State private var selectedMedicineForDeletion: MedicineRow? = nil //changed: Added state variable for tracking selected medicine for deletion

    private let medicineWidth: CGFloat = 100
    private let timingsWidth: CGFloat = 70
    private let imgwidth:CGFloat = 20
    // test Branchn
    
    let primaryBlue = Color.blue // Adjust this to match the logo's blue
        let lightBlue = Color.blue.opacity(0.3) // Adjust this to match the logo's light blue
        let backgroundColor = Color.white // For background elements

    var body: some View {
        VStack {
            Text("Refill Summary")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
            HStack{
                Image(systemName: "waterbottle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.blue) // This changes the color to blue
                    .frame(width: timingsWidth+40,height: 40, alignment: .center) // Changed: Increased width
                Text("Medicines with less than 7 days dosage are shown below")
            }
            
            HStack{
                Image(systemName: "trash.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.red) // This changes the color to blue
                    .frame(width: timingsWidth+40,height: 30, alignment: .center) // Changed: Increased
                Text("Click Delete icon to remove the refill from list")
                    .foregroundColor(.red)
              
                
                
                
                
            }
            
            List {
                Section(header: HStack {
                   
                    
               //Kido 1J begin : Uncomment
                    
                    Text("Medicines")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(width: medicineWidth+60, alignment: .leading)
                    
                  
                    
            
                    
                   //now  Image(systemName: "waterbottle.fill")
                    Color.clear
                       // .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue) // This changes the color to blue
                        .frame(width: timingsWidth+50,height: 40, alignment: .center) // Changed: Increased width
                  
                    
                    
                    
                    
         
                    
                
                    
                    
                    
                    
                }) {
                    /*XOXO1
                    
                    ForEach(medicinesWithRefill, id: \.id) { medicine in
                        let dateBasedOnQuantity = calculateDateBasedOnQuantity(frequency: medicine.frequency, quantityLeft: medicine.quantityLeft_D, times: medicine.times)
                //now   let formattedDate = DateFormatter.displayFormat.string(from: dateBasedOnQuantity)
                        
                        let formattedDate = customDateFormatter.string(from: dateBasedOnQuantity)
                        
                        
                        if medicine.quantityLeft_D <= 7{
                               HStack {
                                   
                                   Text(medicine.medicine)
                                       .frame(width: medicineWidth+20, alignment: .leading)
                                   
                                   if medicine.quantityLeft_D > 0 {
                                       Text("Due Soon:   \(formattedDate)")
                                           .frame(width: timingsWidth+80, alignment: .center)
                                   } else if medicine.quantityLeft_D == 0 {
                                       Text("Due Today:  \(formattedDate)")
                                           .frame(width: timingsWidth+80, alignment: .center)
                                   } else {
                                       Text("Overdue:  \(formattedDate)")
                                           .frame(width: timingsWidth+80, alignment: .center)
                                   }

                                   Button(action: {
                                       self.selectedMedicineForDeletion = medicine
                                       // print("trash.fill clicked for \(medicine.medicine)")
                                   }) {
                                       Image(systemName: "trash.fill")
                                           .foregroundColor(.red)
                                           .frame(width: 20, alignment: .trailing)
                                         
                                }
                            }
                        }
                    }// For loop
XOXO1*/
                    
                    
                    
                    ForEach(medicinesWithRefill, id: \.id) { medicine in
                        let dateBasedOnQuantity = calculateDateBasedOnQuantity(frequency: medicine.frequency, quantityLeft: medicine.quantityLeft_D, times: medicine.times)
                        let formattedDate = customDateFormatter.string(from: dateBasedOnQuantity)
                        
                        //fox refill fix
                        var count = (try? databaseManager.fetchCountForMedicine(medicineName: medicine.medicine)) ?? -999

                      //  print(medicine.medicine)
                      //  print(count)
                        var countdays_DW = count/medicine.times
                        var countdays_M = count * medicine.times
                        
                        
                      //fox refill fix for days vs dose counts
                        if(medicine.frequency=="D" || medicine.frequency=="W"){
                            if (count != -999 && (  countdays_DW < 7 )) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(medicine.medicine)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        Spacer() // This will push all content to the right.
                                        // Add padding to the first element or to the HStack itself to "push" content a bit more to the right
                                        
                                        
                                        
                                        if (countdays_DW > 0  && countdays_DW < 7) {
                                            Text("Due Soon: less than 7 days left")
                                                .padding(.leading, 8) // Adjust the value to effectively create "2 spaces"; you might need to adjust this value to match your design
                                        } else if countdays_DW == 0 {
                                            Text("Over Due: No doses left")
                                                .padding(.leading, 8)
                                        }
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        Spacer() // This ensures that the button stays on the right end.
                                        Button(action: {
                                            self.selectedMedicineForDeletion = medicine
                                            // print("trash.fill clicked for \(medicine.medicine)")
                                        }) {
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                            }//if
                        }//if D,W
                        
                        if(medicine.frequency=="M"){
                            if (count != -999 && ( countdays_M < 7  )) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(medicine.medicine)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        Spacer() // This will push all content to the right.
                                        // Add padding to the first element or to the HStack itself to "push" content a bit more to the right
                                        
                                        
                                        
                                        if (countdays_M > 0  && countdays_M < 7) {
                                            Text("Due Soon: less than 7 days left")
                                                .padding(.leading, 8) // Adjust the value to effectively create "2 spaces"; you might need to adjust this value to match your design
                                        } else if countdays_M == 0 {
                                            Text("Over Due: No doses left")
                                                .padding(.leading, 8)
                                        }
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        Spacer() // This ensures that the button stays on the right end.
                                        Button(action: {
                                            self.selectedMedicineForDeletion = medicine
                                            // print("trash.fill clicked for \(medicine.medicine)")
                                        }) {
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                            }//if
                        }//if M
                        
                        
                        
                        
                        
                        
                        
                        /*
                        //fox refill fix
                        if count <= 7 && count != -999 {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(medicine.medicine)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack {
                                    Spacer() // This will push all content to the right.
                                    // Add padding to the first element or to the HStack itself to "push" content a bit more to the right
                                   
                                    
                                    
                                    if (count > 0  && count < 7) {
                                        Text("Due Soon: less than 7 doses left")
                                            .padding(.leading, 8) // Adjust the value to effectively create "2 spaces"; you might need to adjust this value to match your design
                                    } else if count == 0 {
                                        Text("Over Due: No doses left")
                                            .padding(.leading, 8)
                                    }
                                    
                                    
                                    Spacer() // This ensures that the button stays on the right end.
                                    Button(action: {
                                        self.selectedMedicineForDeletion = medicine
                                        // print("trash.fill clicked for \(medicine.medicine)")
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                        }//if
                        */
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        /*
                        
                        if medicine.quantityLeft_D <= 7 {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(medicine.medicine)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack {
                                    Spacer() // This will push all content to the right.
                                    // Add padding to the first element or to the HStack itself to "push" content a bit more to the right
                                    if medicine.quantityLeft_D > 0 {
                                        Text("Due Soon: \(formattedDate)")
                                            .padding(.leading, 8) // Adjust the value to effectively create "2 spaces"; you might need to adjust this value to match your design
                                    } else if medicine.quantityLeft_D == 0 {
                                        Text("Due Today: \(formattedDate)")
                                            .padding(.leading, 8)
                                    } else {
                                        Text("Overdue: \(formattedDate)")
                                            .padding(.leading, 8)
                                    }
                                    
                                    Spacer() // This ensures that the button stays on the right end.
                                    Button(action: {
                                        self.selectedMedicineForDeletion = medicine
                                        // print("trash.fill clicked for \(medicine.medicine)")
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                        }*/
                        
                        
                        
                        
                        
                        
                    }

                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
            }
        } .listStyle(GroupedListStyle())
            .padding(.horizontal)
        .onAppear(perform: loadMedicinesWithRefills)
                .alert(item: $selectedMedicineForDeletion) { medicine in //changed: Alert for confirmation of deletion
                    Alert(
                        title: Text("Confirm Refill not needed"),
                        message: Text("Are you sure you do not want Refill\(medicine.medicine)?"),
                        primaryButton: .destructive(Text("Yes")) {
                            changeRefillStatusToFalse(medicine: medicine) //changed: Handle confirmation action
                        },
                        secondaryButton: .cancel()
                    )
                }
            }

    private func loadMedicinesWithRefills() {
        do {
            medicinesWithRefill = try DatabaseManager.shared.fetchMedicinesWithRefills()
        } catch {
            // print("Error loading medicines with refills: \(error)")
        }
    }
    
    
    
    
    // Helper function to calculate date based on quantity left, considering past dates for negative values
        private func calculateDateBasedOnQuantity(frequency: String, quantityLeft: Int, times: Int) -> Date {
            let currentDate = Date()
            var dateComponent = DateComponents()
            
            switch frequency {
            case "D":
                dateComponent.day = quantityLeft
            case "W":
                dateComponent.weekOfYear = quantityLeft
            case "M":
                // Assuming you want to move in the past by 'quantityLeft * times' days for monthly frequency
                dateComponent.day = quantityLeft * times
            default:
                break
            }

            return Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? currentDate
        }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func changeRefillStatusToFalse(medicine: MedicineRow) { //changed: Function to update refill status
            do {
                var updatedMedicine = medicine
                updatedMedicine.refill = false
                try DatabaseManager.shared.updateMedicineRow(updatedMedicine)
                loadMedicinesWithRefills() //changed: Reload the medicines after update
            } catch {
                // print("Error updating medicine refill status: \(error)")
            }
        }
    
    private let customDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy" // Custom format
        return formatter
    }()

    }
    
    
    
    
    

struct RefillsView_Previews: PreviewProvider {
    static var previews: some View {
        RefillsView()
    }
}


