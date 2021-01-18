//
//  HealthManager.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Abiram Pakeerathan and Lukas Bröning in 2021.
//

import WatchKit
import Foundation
import HealthKit


//TODO: JSON Format
struct HeartRateData: Codable {
    var timestamp   : String?
    var heartRate   : Double?
    var objNum      : Double?
}

struct OxygenSaturationData: Codable {
    var timestamp   : String?
    var value       : Double?
    var objNum      : Double?
}

struct EcgData: Codable {
    var timestamp   : String?
    var value       : Double?
    var objNum      : Double?
}


class HealthManager {
    
    let healthStore = HKHealthStore()
    var dataCounter = 0.0
    var heartRateArray : [HeartRateData] = []
    var heartRateObserverQuery: HKQuery?
    var heartRateSampleQuery: HKQuery?
    var initialTime = 0.0
    
    
    /*
     * fetch most recent heart rate data updates
     * HKObserverQuery to get updates
     */
    func startHeartRateTracking(timeInSeconds: Double = 60) {
        
        //check authorization and start
        if (authorizingHK() == true) {
                        
            //create sample type for heart rate
            guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
                print("SampleType ERROR")
                return
            }
            
            //set initialTime
            initialTime = Date().timeIntervalSince1970
            
            /* set predicate start and end of tracking
            let startDate = Date()
            let approxObserverTimeError = 3
            let endDate = Calendar.current.date(byAdding: .second, value: Int(timeInSeconds)-approxObserverTimeError, to: startDate)
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
            */
            
            //create observer which notifies whenever new samples
            //of the specified type are saved to the store by HealthKit
            //new sample every ca. 5 secs
            heartRateObserverQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { (query, completionHandler, errorOrNil) in
                if (errorOrNil != nil) {
                    print("Observer ERROR")
                    return
                }
                
                //fetch latest HeartRateSample
                self.fetchHeartRateSample { (sample) in
                    guard let sample = sample else {
                        print("Sample ERROR")
                        return
                    }
                    
                    //create count per time unit
                    let beatsPerMinute = HKUnit(from: "count/min")
                    
                    DispatchQueue.main.async {
                        
                        //stop tracking if time is up
                        if (Date().timeIntervalSince1970 >= self.initialTime + timeInSeconds) {
                            //stop tracking and print time is up
                            print("Time (", String(timeInSeconds), "sec ) is up!")
                            self.stopHeartRateUpdates()
                        } else {
                            //count collected data
                            self.dataCounter+=1
                                
                            //convert HKQuantitySample to a beats-per-minute value
                            let heartRate = sample.quantity.doubleValue(for: beatsPerMinute)
                                
                            //set timestamp of collected data
                            let d = Date()
                            let df = DateFormatter()
                            df.dateFormat = "y-MM-dd H:mm:ss-SS"
                            let currentDate = df.string(from: d)
                                
                            //append current heart rate data to array
                            self.heartRateArray.append(HeartRateData(
                                                        timestamp: currentDate,
                                                        heartRate: heartRate,
                                                        objNum: self.dataCounter))
                                
                            self.encodeAndPost(arr: self.heartRateArray)
                            
                            //set label text in UI
                            if let accessUI = WKExtension.shared().rootInterfaceController as? InterfaceController {
                                accessUI.upperLabel.setText("Data fetched: ")
                                accessUI.lowerLabel.setText(String(self.dataCounter))
                            }
                            
                            self.heartRateArray = []
                        }
                    }
                }
            }
            //execute HKObserverQuery
            healthStore.execute(heartRateObserverQuery!)
        }
    }

    
    /*
     * fetch most recent heart rate data updates
     * completionHandler to return the fetched value
     * HKSampleQuery to read heart rate
     * observer query notifies that an update is available,
     * then perform sample query to retrieve the updated sample
     */
    func fetchHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        
        //create sample type for heart rate
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }
        
        //get latest sample, sort to get the latest sample
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //create sample query to retrieve the updated sample
        heartRateSampleQuery = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]){ (_, results, error) in
            if (error != nil) {
                print("SampleQuery ERROR")
                return
            }
            
            //'If you have subscribed for background updates you must call the completion handler here.'
            completionHandler(results?[0] as? HKQuantitySample)
        }
        
        //execute HKSampleQuery
        healthStore.execute(heartRateSampleQuery!)
    }
    
    
    //TODO: JSON Format
    func encodeAndPost(arr: [HeartRateData]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(self.heartRateArray)
        print(String(data: data, encoding: .utf8)!)
    }
    
    
    func stopHeartRateUpdates () {
        healthStore.stop(self.heartRateObserverQuery!)
        healthStore.stop(self.heartRateSampleQuery!)
        
        //set isTrackingActive in InterfaceController to false and adjust UI
        if let accessUI = WKExtension.shared().rootInterfaceController as? InterfaceController {
            accessUI.isTrackingActive = false
            accessUI.upperLabel.setText("Start again?")
            accessUI.startButton.setBackgroundColor(UIColor.green)
            accessUI.stopButton.setBackgroundColor(UIColor.lightGray)
        }
        
        //reset counter
        dataCounter = 0
        
        //TODO: stop extended runtime session if button isnt pressed!
    }
    
    
    func authorizingHK() -> Bool {
        
        //TODO async boolean
        var auth: Bool = true
        
        if (HKHealthStore.isHealthDataAvailable()) {
            let myTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
                                //,HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
            
            let myTypesRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
                                //,HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                                //HKObjectType.electrocardiogramType()
            
            healthStore.requestAuthorization(toShare: myTypes, read: myTypesRead) { (success, error) in
                if (!success) {
                    // Handle the error here.
                    auth = false
                    print("Authorization failed!")
                } else {
                    auth = true
                    print("Authorization successful!")
                }
            }
        }
        return auth
    }
    
    
    func fetchOxygenSaturationData() {
        
        if (authorizingHK()) {
            guard let oxyType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
                return
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: healthStore.earliestPermittedSampleDate(), end: Date(), options: .strictEndDate)
            
            // to get in descending order
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            // all samples that are currently saved in healthkit store from requested type
            let sampleQuery = HKSampleQuery(sampleType: oxyType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, results, error) in
                guard let samples = results as? [HKQuantitySample] else {
                        // Handle any errors here.
                        return
                    }
                let df = DateFormatter()
                df.dateFormat = "y-MM-dd H:mm:ss"
                
                for sample in samples {
                    // Process each sample here.
                    print("--")
                    print(sample.quantity.doubleValue(for: .percent()))
                    print(df.string(from: sample.startDate))
                    }
            }
            healthStore.execute(sampleQuery)
        }
    }
    
    func fetchEcgData() {
        
        if (authorizingHK()) {
            // Create the electrocardiogram sample type.
            let ecgType = HKObjectType.electrocardiogramType()

            // Query for electrocardiogram samples
            let ecgQuery = HKSampleQuery(sampleType: ecgType,
                                         predicate: nil,
                                         limit: HKObjectQueryNoLimit,
                                         sortDescriptors: nil) { (query, samples, error) in
                if let error = error {
                    // Handle the error here.
                    fatalError("*** An error occurred \(error.localizedDescription) ***")
                }
                
                guard let ecgSamples = samples as? [HKElectrocardiogram] else {
                    fatalError("*** Unable to convert \(String(describing: samples)) to [HKElectrocardiogram] ***")
                }
                
                for sample in ecgSamples {
                    // Handle the samples here.
                    //print(sample.numberOfVoltageMeasurements)
                    //print(sample.samplingFrequency)
                    // Create a query for the voltage measurements
                    let voltageQuery = HKElectrocardiogramQuery(sample) { (query, result) in
                        switch(result) {
                        
                        case .measurement(let measurement):
                            if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                                // Do something with the voltage quantity here.
                                print(voltageQuantity)
                            }
                        
                        case .done:
                            // No more voltage measurements. Finish processing the existing measurements.
                            print("done")

                        case .error(let error):
                            // Handle the error here.
                            print("error: ", error)

                        @unknown default:
                            print("unknown case in new version")
                        }
                    }
                    // Execute the query.
                    self.healthStore.execute(voltageQuery)
                }
            }
            // Execute the query.
            healthStore.execute(ecgQuery)
        }
    }
}
