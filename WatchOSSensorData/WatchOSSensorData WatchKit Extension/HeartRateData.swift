//
//  HeartRateData.swift
//  WatchOSSensorData WatchKit Extension
//
//  Created by Lukas Bröning in 2021.
//

import WatchKit
import Foundation
import HealthKit

class HeartRateData {
    
    let healthStore = HKHealthStore()
    var dataCounter = 0.0
    var stopToggle  = false
    var heartRateArray : [BPMCodable] = []
    

    func startHeartRateTracking (timeInSeconds: Double) {
        //check if HealthData is available and start
        if (HKHealthStore.isHealthDataAvailable())
        {
            //set needed type
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
                    
            //HealthData authorization
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if (!success) {
                    print("authorization failed!")
                }
            }
            fetchHeartRate()
        }
    }


    /*
     * fetch most recent heart rate data updates
     * HKObserverQuery to get updates
     */
    func fetchHeartRate() {
        
        stopToggle = false
        
        //create sample type for heart rate
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("SampleType ERROR")
            return
        }
        
        //create observer which notifies whenever new samples
        //of the specified type are saved to the store by HealthKit
        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { (query, completionHandler, errorOrNil) in
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
                    self.heartRateArray.append(BPMCodable(
                                                timeStamp: currentDate,
                                                heartRate: heartRate,
                                                dataNum: self.dataCounter))
                        
                    self.encodeAndPost(arr: self.heartRateArray)
                    self.heartRateArray = []
                }
            }
        }
        //execute HKObserverQuery
        healthStore.execute(observerQuery)
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
        
        //get most recent sample – new sample every ca. 5 secs
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        //sort to get the latest sample
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //create sample query to retrieve the updated sample
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
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
        healthStore.execute(sampleQuery)
    }

    func encodeAndPost(arr: [BPMCodable]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(self.heartRateArray)
        print(String(data: data, encoding: .utf8)!)
    }
    
    func stopHeartRateUpdates () {
        //aktuell noch abhängig von DeviceMotion
        stopToggle = true
        print("Stoppe Heart Rate")
    }
    
}
