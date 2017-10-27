//
//  HealthManager.swift
//  PaceCalc
//
//  Created by Remington Breeze on 11/13/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import HealthKit

class HealthManager {
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(_ completion: ((_ success: Bool, _ error: NSError?) -> Void)!) -> Bool {
        let healthKitTypesToRead = Set(arrayLiteral:
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
            HKObjectType.workoutType()
        )
        
        let healthKitTypesToWrite = Set(arrayLiteral:
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.workoutType()
        )
        
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.remingtonbreeze.pacecalc", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available for this Device"])
            if completion != nil {
                completion?(false, error)
            }
            return false
        }
        
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
            
            if completion != nil && error == nil {
                completion?(true,error as NSError?)
            } else {
                completion?(false,error as NSError?)
            }
        }
        return true
    }
    
    func calculateBMR(_ weight: Double, height: Double, age: Int) -> Int {
        let partA = weight * 10
        let partB = height * 6.25
        let partC = age * 5
        
        let sectionA = partA + partB
        let sectionB = partC + 5
        
        return Int(sectionA) - sectionB
    }
    
    func readProfile() -> (age: Int?, biologicalSex: HKBiologicalSexObject?) {
        var age:Int?
        
        let sex:HKBiologicalSexObject? = try? healthKitStore.biologicalSex()
        
        let birthDay = try? healthKitStore.dateOfBirth()
        if birthDay != nil {
            let today = Date()
            let difference = (Calendar.current as NSCalendar).components(.year, from: birthDay!, to: today, options: NSCalendar.Options(rawValue:0))
            age = difference.year
        } else {
            print("Error getting age")
            age = nil
        }
        
        return (age, sex)
        
    }
    
    func readMostRecentSample(_ sampleType:HKSampleType, completion: ((HKSample?, NSError?) -> Void)!) {
        let past = Date.distantPast
        let now = Date()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end: now, options: HKQueryOptions())
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error) -> Void in
            
            if let _ = error {
                completion?(nil, error as NSError?)
                return
            }
            
            let mostRecentSample = results!.first as? HKQuantitySample
            
            if completion != nil {
                completion(mostRecentSample, nil)
            }
        }
        self.healthKitStore.execute(sampleQuery)
    }
    
    func readRunningWorkouts(_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        let predicate = HKQuery.predicateForWorkouts(with: HKWorkoutActivityType.running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error) -> Void in
            if let _ = error {
                print("Error reading workouts: \(error?.localizedDescription)")
            }
            completion?(results, error as NSError?)
        }
        healthKitStore.execute(sampleQuery)
    }
    
    func saveRunningWorkout(_ startDate: Date, endDate: Date, distance: Double, distanceUnit: HKUnit, kiloCalories: Double, completion: ( (Bool, NSError?) -> Void)! ) {
        
        let distanceQuantity = HKQuantity(unit: distanceUnit, doubleValue: distance)
        let caloriesQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: kiloCalories)
        
        let workout = HKWorkout(activityType: HKWorkoutActivityType.running, start: startDate, end: endDate, duration: abs(endDate.timeIntervalSince(startDate)) * 60, totalEnergyBurned: caloriesQuantity, totalDistance: distanceQuantity, metadata: nil)
        
            healthKitStore.save(workout, withCompletion: { (success, error) -> Void in
                if error != nil {
                    completion?(success, error as NSError?)
                } else {
                    completion(success, nil)
                }
            })
        
    }
}
