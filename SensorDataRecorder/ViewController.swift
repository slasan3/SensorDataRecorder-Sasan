//
//  ViewController.swift
//  SensorDataRecorder
//
//  Created by FTD on 2019/09/02.
//  Copyright © 2019 FTD. All rights reserved.
//
import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    var accumulatedData: String = ""
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
        
    }
    
    
    
    @IBOutlet weak var csvFileManagementButton: CustomButton!
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    let csvManager = CSVManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Extract sensor data from the received message
        guard let gyroX = message["gyroX"] as? String,
              let gyroY = message["gyroY"] as? String,
              let gyroZ = message["gyroZ"] as? String,
              let accX = message["accX"] as? String,
              let accY = message["accY"] as? String,
              let accZ = message["accZ"] as? String else {
            print("Received incomplete sensor data")
            return
        }
        
        // Construct the CSV row
        let csvRow = "\(gyroX),\(gyroY),\(gyroZ),\(accX),\(accY),\(accZ)\n" // Add newline
        
        // Accumulate the data
        accumulatedData.append(csvRow)
    }
    
    // Function to save accumulated data to CSV file
    func saveAccumulatedDataToCsv(fileName: String) {
        // Get the document directory URL
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Add a file name to the directory URL
            let fileURL = documentsDirectory.appendingPathComponent(fileName + ".csv")
            
            do {
                // Write the accumulated data to the file
                try accumulatedData.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Data saved to CSV file: \(fileName).csv")
            } catch {
                print("Error writing data to CSV file: \(error.localizedDescription)")
            }
        }
    }
    
    class CSVManager {
        func saveSensorDataToCsv(fileName: String, data: String) {
            // Get the document directory URL
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // Add a file name to the directory URL
                let fileURL = documentsDirectory.appendingPathComponent(fileName + ".csv")
                
                do {
                    // Write the data to the file
                    try data.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("Data saved to CSV file: \(fileName).csv")
                } catch {
                    print("Error writing data to CSV file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}
