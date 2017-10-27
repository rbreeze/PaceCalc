//
//  PaceBrain.swift
//  PaceCalc
//
//  Created by Remington Breeze on 11/2/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit
import HealthKit

class PaceBrain {
    
    static let sharedInstance = PaceBrain()
    
    struct weeklyData {
        var mileage: [Double] = [0.0]
        var minutes: [Double] = [0.0]
        var seconds: [Double] = [0.0]
        var dates: [Date?] = [nil]
        var paces: [Double] = [0.0]
    }
    
    struct slotData {
        var keys: [String] = [""]
        var types: [String] = [""]
    }
    
    var foods: [String : (value: Double, label: String)] = [
        "Burgers" : (563, "Burgers Burned"),
        "Slices of Pizza" : (280, "Slices of Pizza Burned"),
        "Donuts" : (320, "Donuts Burned")
    ]
    var landmarks: [String : (value: Double, label: String)] = [
        "Golden Gate Bridge" : (1.701, "Golden Gate Bridges"),
        "Great Wall of China" : (5500.3, "Great Walls of China"),
        "Empire State Building" : (0.2754, "Empire State Buildings")
    ]
    var shows: [String : (value: Double, label: String)] = [
        "FRIENDS" : (22.5, "Episodes of FRIENDS"),
        "House of Cards" : (50.39, "Episodes of House of Cards"),
        "Game of Thrones" : (55,"Episodes of Game of Thrones"),
        "Seinfeld" : (22, "Episodes of Seinfeld"),
        "HIMYM" : (22, "Episodes of HIMYM"),
        "House MD" : (44, "Episodes of House")
    ]
    
    var conversions: Dictionary<String, Dictionary<String, (value: Double, label: String)>> = [:]
    
    var categories = ["Foods", "Landmarks", "Shows"]
    
    var currentSlots = slotData()
    
    func addToClipboard(_ string: String) {
        UIPasteboard.general.string = string
    }
    
    func calculateCaloriesBurned(_ pace: Double, distance: Double) -> Double {
        return distance * (120 - pace);
    }
    
    func calculateFoodUnits(_ calories: Double, food: String) -> Double {
        return calories / Double(foods[food]!.value);
    }
    
    func calculateDistanceUnits(_ distance: Double, landmark: String) -> Double {
        return distance / landmarks[landmark]!.value;
    }
    
    func calculateEpisodes(_ time: Double, show: String) -> Double {
        return time / shows[show]!.value
    }
    
    var separator:String = NSLocalizedString("SEPARATOR", comment: ".")
    
    let formatter = NumberFormatter()
    
    var dataPile = weeklyData()
    
    var BMR: Int? = defaults.value(forKey: "BMRKey") as! Int?
    
    var unit: HKUnit
    
    init() {
        
        currentSlots.keys = ["Burgers", "House MD", "Golden Gate Bridge", "Empire State Building", "Great Wall of China"]
        currentSlots.types = ["Foods", "Shows", "Landmarks", "Landmarks", "Landmarks"]
        
        conversions["Foods"] = foods
        conversions["Shows"] = shows
        conversions["Landmarks"] = landmarks
        
        unit = HKUnit.mile()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = 2
        updateUnit()
        
    }
    
    func updateUnit() -> Void {
        if let localUnit = defaults.string(forKey: "distanceUnitKey") {
            switch localUnit {
            case "Miles":
                unit = HKUnit.mile()
                break
            case "Kilometers", "Kilomètres":
                unit = HKUnit.meterUnit(with: .kilo)
                break
            default:
                unit = HKUnit.mile()
                break
            }
        } else {
            unit = HKUnit.mile()
        }
    }
    
    func convert(_ data: Double, fromUnit: HKUnit, toUnit: HKUnit) -> Double? {
        var conversionFactor: Double
        
        switch toUnit {
        case HKUnit.meterUnit(with: .kilo):
            conversionFactor = 1.60934
            break
        case HKUnit.mile():
            conversionFactor = 0.621371
            break
        default:
            conversionFactor = 1
            break
        }
        
        if toUnit == fromUnit {
            conversionFactor = 1
            return nil
        }
        
        return data * conversionFactor
    }
    
    func stringToUnit(_ string: String) -> HKUnit? {
        var unit: HKUnit?
        switch string {
        case NSLocalizedString("KILOMETERS", comment: "Kilometers"):
            unit = HKUnit.meterUnit(with: .kilo)
            break
        case NSLocalizedString("MILES", comment: "Miles"):
            unit = HKUnit.mile()
            break
        default:
            unit = nil
            break
        }
        return unit
    }

    func updateSlots(slotNumber: Int, key: String, type: String) -> Void {
        currentSlots.keys[slotNumber] = key
        currentSlots.types[slotNumber] = type
    }
    
    func addToPile(_ data: RunData) {
        dataPile.mileage[data.day] = data.mileage
        dataPile.minutes[data.day] = data.minutes
        dataPile.seconds[data.day] = data.seconds
        dataPile.dates[data.day] = data.date as Date?
        dataPile.paces[data.day] = data.pace
    }
    
    func getSum(_ array: [Double]) -> Double {
        return array.reduce(0, +)
    }
    
    func findAveragePace(_ data: weeklyData) -> Double {
        let totalTime = getSum(data.minutes) + (getSum(data.seconds)/60)
        return totalTime / getSum(data.mileage)
    }
    
    func weeklyDataForDay(_ day: Int) -> weeklyData {
        var dailyData = PaceBrain.weeklyData()
        dailyData.mileage[0] = dataPile.mileage[day]
        dailyData.minutes[0] = dataPile.minutes[day]
        dailyData.seconds[0] = dataPile.seconds[day]
        return dailyData
    }
    
    func timeDecimalToString(_ timeDouble: Double) -> String {
        var minutes = timeDouble == 0.0 || timeDouble.isNaN || timeDouble.isInfinite ? 0 : Int(floor(timeDouble))
        var seconds = timeDouble.isInfinite || timeDouble.isNaN || timeDouble == 0 ? 0 : Int(round((timeDouble-Double(minutes)) * 60))
        
        if seconds >= 60 {
            seconds = 0
            minutes += 1
        }
        
        let result = seconds > 10 ? "\(minutes):\(seconds)" : "\(minutes):0\(seconds)"
        return result
    }
    
    func timeStringToMinutesAndSeconds(_ timeString: String?) -> (minutes: Double, seconds: Double) {
        let timeRegEx = "((\\d?\\d?\\d):)?([0-5]?\\d?)?"
        let timeTest = NSPredicate(format: "SELF MATCHES %@", timeRegEx)
        
        var minutes:Double = 0
        var seconds:Double = 0
        
        let timeText = timeString == nil || timeString == "" ? "0:00" : timeString!
        
        if timeTest.evaluate(with: timeText) == true {
            let minutesRegEx = "(\\d)?:([0-5]\\d)?"
            var minuteShift: Int
            if NSPredicate(format: "SELF MATCHES %@", minutesRegEx).evaluate(with: timeText) {
                minuteShift = 1
            } else {
                let noSecondsRegEx = "\\d?\\d?"
                if NSPredicate(format: "SELF MATCHES %@", noSecondsRegEx).evaluate(with: timeText) {
                    minuteShift = 0
                } else {
                    let tripleRegEx = "\\d\\d\\d:([0-5]\\d)?"
                    if NSPredicate(format: "SELF MATCHES %@", tripleRegEx).evaluate(with: timeText) {
                        minuteShift = 3
                    } else {
                        minuteShift = 2
                    }
                }
            }
            if let _ = timeString {
                let timeValue = timeText
                if minuteShift != 0 {
                    let minutesRange = (timeValue.startIndex ..< timeValue.characters.index(timeValue.startIndex, offsetBy: minuteShift))
                    minutes = Double(timeValue.substring(with: minutesRange))!
                    let secondsRange = (timeValue.characters.index(timeValue.startIndex, offsetBy: minuteShift+1) ..< timeValue.characters.index(timeValue.startIndex, offsetBy: minuteShift+3))
                    seconds = Double(timeValue.substring(with: secondsRange))!
                } else {
                    minutes = Double(timeValue)!
                    seconds = 0
                }
            }
        }
        
        return (minutes, seconds)

    }
    
    func localizedStringToDouble(_ string: String) -> (double: Double?, decimalSeparator: String) {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        var double:Double? = nil
        
        if let _ = formatter.number(from: string) {
            double = formatter.number(from: string)!.doubleValue
        } else {
            formatter.decimalSeparator = ","
            if let _ = formatter.number(from: string) {
                double = formatter.number(from: string)!.doubleValue
            } else {
                double = nil
            }
        }
        
        self.separator = formatter.decimalSeparator
        
        return (double, formatter.decimalSeparator)
        
    }
    
    func findMissing(_ distance: String?, time: String?, pace: String?) -> (distance: String?, time: String?, pace: String?, error: String?) {
        var resultPace: String? = pace
        var resultDistance: String? = distance
        var resultTime: String? = time
        var error: String?
                
        let minutesAndSeconds = timeStringToMinutesAndSeconds(time)
        let timeDouble = minutesAndSecondsToDouble(minutesAndSeconds.minutes, seconds: minutesAndSeconds.seconds)
        
        let distanceCopy = distance == "" ? "0" : distance
        
        let distanceDouble = localizedStringToDouble(distanceCopy!).double ?? 0
        let separator = localizedStringToDouble(distanceCopy!).decimalSeparator
        
        let paceMinutesAndSeconds = timeStringToMinutesAndSeconds(pace)
        let paceDouble = minutesAndSecondsToDouble(paceMinutesAndSeconds.minutes, seconds: paceMinutesAndSeconds.seconds)
        
        if distance != "" && time != "" {
            resultPace = timeDecimalToString(timeDouble / distanceDouble)
        } else if distance == "" && pace != "" && time != "" {
            let formatter = NumberFormatter()
            formatter.decimalSeparator = separator
            resultDistance = "\(formatter.number(from: "\(roundToHundredths(timeDouble/paceDouble))"))"
        } else if time == "" && pace != "" && distance != "" {
            resultTime = paceDouble == 0 ? "0:00" : "\(timeDecimalToString(distanceDouble * paceDouble))"
        } else {
            error = "Please enter valid data."
        }
        return (resultDistance, resultTime, resultPace, error)
    }
    
    func alert(_ title: String, message: String, viewController: UIViewController) {
        var alert = UIAlertController()
        alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("DISMISS", comment: "Dismiss"), style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func convertDataToUnit(_ fromUnit: HKUnit, toUnit: HKUnit) {
        var conversionFactor: Double
        
        switch toUnit {
        case HKUnit.meterUnit(with: .kilo):
            conversionFactor = 1.60934
            break
        case HKUnit.mile():
            conversionFactor = 0.621371
            break
        default:
            conversionFactor = 1
            break
        }
        
        if toUnit == fromUnit {
            conversionFactor = 1
            return
        }
        
        for (index, value) in self.dataPile.mileage.enumerated() {
            let newValue = roundToHundredths(value * conversionFactor)
            self.dataPile.mileage[index] = newValue
        }
    }
    
    func roundToHundredths(_ number: Double) -> Double {
        return round(number * 100) / 100
    }
    
    func dayLabelToInt(_ label: String) -> Int? {
        let dayNumber = label.replacingOccurrences(of: "Day ", with: "")
        return Int(dayNumber)
    }
    
    func minutesAndSecondsToDouble(_ minutes: Double, seconds: Double) -> Double {
        return minutes + (seconds/60)
    }
    
}
