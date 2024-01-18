//
//  PillPocketTests.swift
//  PillPocketTests
//
//  Created by ramya nomula on 1/18/24.
//

import XCTest
import SwiftUI
//@testable import Pill Pocket








final class PillPocketTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

   
    
    
    
    
    func testFetchMedicationReminders() throws {
           // Arrange
           let databaseManager = DatabaseManager.shared
           let newReminder = MedicationReminder(medication: "TestMed", reminderTime: Date()) // Ensure this matches your MedicationReminder initialization
           
           // Act
           try databaseManager.insertMedicationReminder(newReminder) // Ensure this method exists and works as expected
           let reminders = try databaseManager.fetchMedicationReminders()
           
           // Assert
           XCTAssertNotNil(reminders, "The fetch operation should return an array of reminders.")
           XCTAssertTrue(reminders.count > 0, "Expected to fetch at least one reminder from the database.")
       }
    
    
    
    
    
    
}
