//
//  EditDataTableViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 10/31/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit
import HealthKit

protocol EditDataDelegate {
    func didFinishEditing (_ controller: EditDataTableViewController, data: RunData)
}

struct RunData {
    var mileage: Double = 0
    var minutes: Double = 0
    var seconds: Double = 0
    var day: Int = 1
    var pace: Double = 0
    var date: Date? = nil
}

let defaults = UserDefaults.standard

class EditDataTableViewController: UITableViewController, DatePickerDelegate, WorkoutsDelegate {

    var day: Int?
    
    var data = RunData()
    var brain = PaceBrain()
    var healthManager = HealthManager()
    
    let defaults = UserDefaults.standard
    
    func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = self.distance.placeholder {
            if let oldUnit = brain.stringToUnit(self.distance.placeholder!) {
                if let localUnit = defaults.string(forKey: "distanceUnitKey") {
                    self.distance.placeholder = localUnit
                    if let convertToUnit = brain.stringToUnit(localUnit) {
                        if self.distance.text != "" {
                            if let newDistance = brain.convert(brain.formatter.number(from: self.distance.text!)!.doubleValue, fromUnit: oldUnit, toUnit: convertToUnit) {
                                self.distance.text = brain.formatter.string(from: NSNumber(value: newDistance))
                                if self.pace.text != "" && self.time.text != "" {
                                    let values = brain.findMissing(self.distance.text, time: self.time.text, pace: nil)
                                    self.pace.text = values.pace
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let localUnit = defaults.string(forKey: "distanceUnitKey") {
            self.distance.placeholder = localUnit 
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditDataTableViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
        if data.date != nil {
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            self.navigationItem.title = "\(formatter.string(from: data.date!))"
            
            formatter.timeStyle = .short
            let dateString = formatter.string(from: self.data.date!)
            self.dateLabel.text = "\(dateString)"
        } else {
            self.navigationItem.title = NSLocalizedString("Day", comment: "DAY") + " \(day! + 1)"
        }
        
        self.distance.text = self.data.mileage == 0 ? "" : brain.formatter.string(from: NSDecimalNumber(value: self.data.mileage))!

        let timeString = self.data.minutes == 0 && self.data.seconds == 0 ? "" : self.data.seconds <= 9 ? "\(Int(self.data.minutes)):0\(Int(self.data.seconds))" : "\(Int(self.data.minutes)):\(Int(self.data.seconds))"
        self.time.text = timeString
        
        let paceMinutesAndSeconds = brain.timeStringToMinutesAndSeconds(timeString)
        self.data.pace = brain.minutesAndSecondsToDouble(paceMinutesAndSeconds.minutes, seconds: paceMinutesAndSeconds.seconds) / data.mileage
        self.pace.text = self.data.pace == 0 || self.data.pace.isNaN ? "" : "\(brain.timeDecimalToString(self.data.pace))"
        
    }
    
    func didFinishPickingDate(_ controller: DatePickerController, date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
        self.dateLabel.text = "\(dateString)"
        self.data.date = date
        let titleFormatter = DateFormatter()
        titleFormatter.dateStyle = DateFormatter.Style.medium
        self.navigationItem.title = "\(titleFormatter.string(from: date))"
    }
    
    func didFinishChoosingWorkout(_ controller: WorkoutsViewController, workout: HKWorkout?, selectedWorkout: Int?) {
        if workout != nil {
            self.distance.text = brain.formatter.string(from: NSDecimalNumber(value: workout!.totalDistance!.doubleValue(for: brain.unit)))!
            self.data.mileage = brain.localizedStringToDouble(self.distance.text!).double ?? 0
            self.time.text = "\(brain.timeDecimalToString(workout!.duration / 60))"
            self.selectedWorkoutNumber = selectedWorkout
            let paceMinutesAndSeconds = brain.timeStringToMinutesAndSeconds(self.time.text)
            self.data.pace = brain.minutesAndSecondsToDouble(paceMinutesAndSeconds.minutes, seconds: paceMinutesAndSeconds.seconds) / data.mileage
            self.pace.text = self.data.pace == 0 || self.data.pace.isNaN ? "" : "\(brain.timeDecimalToString(self.data.pace))"
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            formatter.timeStyle = .short
            let dateString = formatter.string(from: workout!.startDate)
            self.dateLabel.text = "\(dateString)"
            self.data.date = workout!.startDate
        }
    }
    
    @IBOutlet weak var distance: UITextField!
    
    @IBOutlet weak var time: UITextField!
    
    @IBOutlet weak var pace: UITextField!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var delegate: EditDataDelegate?
    
    var selectedWorkoutNumber: Int?
    
    override func viewWillDisappear(_ animated: Bool) {
        let unwrappedMileage = distance.text ?? "0"
        data.mileage = brain.localizedStringToDouble(unwrappedMileage).double ?? 0
        
        let minutesAndSeconds = brain.timeStringToMinutesAndSeconds(time.text)
        
        data.minutes = minutesAndSeconds.minutes
        data.seconds = minutesAndSeconds.seconds
        
        let paceMinutesAndSeconds = brain.timeStringToMinutesAndSeconds(time.text)
        
        data.pace = brain.minutesAndSecondsToDouble(paceMinutesAndSeconds.minutes, seconds: paceMinutesAndSeconds.seconds) / data.mileage
        
        data.day = day!

        if let delegate = self.delegate {
            delegate.didFinishEditing(self, data: data)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseDate" {
            let chooseDateController = segue.destination as? DatePickerController
            chooseDateController!.date = self.data.date
            if let viewController = chooseDateController {
                viewController.delegate = self
            }
        } else if segue.identifier == "chooseWorkout" {
            let workoutController = segue.destination as? WorkoutsViewController
            workoutController!.selectedWorkout = self.selectedWorkoutNumber
            
            if let viewController = workoutController {
                viewController.delegate = self
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 1 {
            print("TEST")
            healthManager.authorizeHealthKit { (authorized, error) -> Void in
                if !authorized {
                    print("Health Access denied!")
                    if error != nil {
                        print("\(error)")
                    }
                } else {
                    print("foo")
                }
            }
        }
        
        if (indexPath as NSIndexPath).row == 3 && (indexPath as NSIndexPath).section == 0 {
            self.performSegue(withIdentifier: "chooseDate", sender: indexPath)
        } else if (indexPath as NSIndexPath).row == 1 && (indexPath as NSIndexPath).section == 1 {
            let duration = TimeInterval(brain.minutesAndSecondsToDouble(self.data.minutes, seconds: self.data.seconds))
            let errorTitle = NSLocalizedString("ERROR_SAVING", comment: "Error Saving Workout")
            if let _ = self.data.date {
                if duration != 0 {
                    if self.data.mileage != 0 {
                        let endDate = self.data.date!.addingTimeInterval(duration)
                        healthManager.saveRunningWorkout(self.data.date!, endDate: endDate, distance: self.data.mileage, distanceUnit: brain.unit, kiloCalories: 0, completion: { (success, error) -> Void in
                            if error != nil {
                                self.brain.alert(errorTitle, message: NSLocalizedString("ERROR_HEALTH_AUTH", comment: "There was an error saving your workout. Please make sure that you have allowed Health access."), viewController: self)
                                print("Error saving workout.")
                            } else {
                                self.brain.alert(NSLocalizedString("SUCCESS", comment: "Success"), message: NSLocalizedString("SUCCESS_SAVING", comment: "foo"), viewController: self)
                                print("Workout successfully saved.")
                            }
                        })
                    } else {
                        self.brain.alert(errorTitle, message: NSLocalizedString("ERROR_DISTANCE", comment: "Please enter a valid distance."), viewController: self)
                    }
                } else {
                    self.brain.alert(errorTitle, message: NSLocalizedString("DURATION", comment: "Please enter a valid duration."), viewController: self)
                }
            } else {
                self.brain.alert(errorTitle, message: NSLocalizedString("ERROR_DATE", comment: "Please enter a valid date."), viewController: self)
            }
            
        } else if (indexPath as NSIndexPath).row == 2 && (indexPath as NSIndexPath).section == 1 {
            performSegue(withIdentifier: "chooseWorkout", sender: self)
        } else if (indexPath as NSIndexPath).row == 0 && (indexPath as NSIndexPath).section == 1 {
            let values = brain.findMissing(self.distance.text, time: self.time.text, pace: self.pace.text)
            if values.error != nil {
                self.brain.alert(NSLocalizedString("INVALID_INPUT", comment: "Invalid Input"), message: NSLocalizedString("ERROR_CALCULATE_MISSING", comment: "Please enter valid workout data."), viewController: self)
            } else {
                self.pace.text = values.pace
                self.distance.text = values.distance
                self.time.text = values.time
                
                let paceMinutesAndSeconds = brain.timeStringToMinutesAndSeconds(values.pace)
                self.data.pace =  brain.minutesAndSecondsToDouble(paceMinutesAndSeconds.minutes, seconds: paceMinutesAndSeconds.seconds)
                
                self.data.mileage = brain.localizedStringToDouble(values.distance!).double ?? 0
                
                let minutesAndSeconds = brain.timeStringToMinutesAndSeconds(values.time)
                self.data.minutes = minutesAndSeconds.minutes
                self.data.seconds = minutesAndSeconds.seconds
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
