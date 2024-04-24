//
//  ContentView.swift
//  AWatch Watch App
//
//  Created by Shane Asano on 24/4/2024.
//  Copyright © 2024 平澤直之. All rights reserved.
//


import SwiftUI
import CoreMotion
import WatchConnectivity

class GyroscopeViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var gyroscopeData = GyroscopeData()
    @Published var accelerometerData = AccelerometerData()
    
    let motion = CMMotionManager()
    var session: WCSession? = WCSession.default
    
    var offsetTime: Double = 0.0
    var offsetTimeFlag = true
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session?.delegate = self
            session?.activate()
        }
        startUpdates()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func startUpdates() {
        if motion.isDeviceMotionAvailable {
            if !motion.isDeviceMotionActive {
                motion.deviceMotionUpdateInterval = 1 / 100.0
                motion.showsDeviceMovementDisplay = true
            }
            
            motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.main) { data, error in
                if let motionData = data {
                    let rotationData = motionData.rotationRate
                    let accelerationData = motionData.userAcceleration
                    let timeStamp = motionData.timestamp
                    if self.offsetTimeFlag {
                        self.offsetTime = 0.0 - timeStamp
                        self.offsetTimeFlag = false
                    }
                    self.gyroscopeData.gyroxValue = "\(rotationData.x)"
                    self.gyroscopeData.gyroyValue = "\(rotationData.y)"
                    self.gyroscopeData.gyrozValue = "\(rotationData.z)"
                    self.accelerometerData.accxValue = "\(accelerationData.x)"
                    self.accelerometerData.accyValue = "\(accelerationData.y)"
                    self.accelerometerData.acczValue = "\(accelerationData.z)"
                    
                    // Send sensor data to iOS app
                    self.sendSensorDataToiOS()
                } else {
                    print("Device motion error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("Device motion is not available")
        }
    }
    
    func sendSensorDataToiOS() {
        guard let session = session, session.isReachable else {
            print("iOS app is not reachable")
            return
        }
        
        let sensorData: [String: Any] = [
            "gyroX": gyroscopeData.gyroxValue,
            "gyroY": gyroscopeData.gyroyValue,
            "gyroZ": gyroscopeData.gyrozValue,
            "accX": accelerometerData.accxValue,
            "accY": accelerometerData.accyValue,
            "accZ": accelerometerData.acczValue
        ]
        
        session.sendMessage(sensorData, replyHandler: nil, errorHandler: { error in
            print("Failed to send sensor data to iOS app: \(error.localizedDescription)")
        })
    }
}

struct ContentView: View {
    @ObservedObject var gyroscopeViewModel = GyroscopeViewModel()
    @State private var isTransmitting = false // Add state variable
    
    var body: some View {
        VStack {
            Text("Gyroscope:")
            Text("X: \(gyroscopeViewModel.gyroscopeData.gyroxValue)")
            Text("Y: \(gyroscopeViewModel.gyroscopeData.gyroyValue)")
            Text("Z: \(gyroscopeViewModel.gyroscopeData.gyrozValue)")
            
            Text("Accelerometer:")
            Text("X: \(gyroscopeViewModel.accelerometerData.accxValue)")
            Text("Y: \(gyroscopeViewModel.accelerometerData.accyValue)")
            Text("Z: \(gyroscopeViewModel.accelerometerData.acczValue)")
            
            if !isTransmitting { // Show start button only if not transmitting
                Button(action: {
                    // Action to start transmission
                    self.isTransmitting = true
                }) {
                    Text("Start")
                        .foregroundColor(.green) // Set start button color to green
                }
            }
            
            if isTransmitting { // Show stop button only if transmitting
                Button(action: {
                    // Action to stop transmission
                    self.isTransmitting = false
                }) {
                    Text("Stop")
                        .foregroundColor(.red) // Set stop button color to red
                }
            }
        }
        .padding()
    }
}


struct AccelerometerData {
    var accxValue: String = ""
    var accyValue: String = ""
    var acczValue: String = ""
}

struct GyroscopeData {
    var gyroxValue: String = ""
    var gyroyValue: String = ""
    var gyrozValue: String = ""
}

