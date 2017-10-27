//
//  WorkoutsViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 11/18/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit
import HealthKit

protocol WorkoutsDelegate {
    func didFinishChoosingWorkout(_ controller: WorkoutsViewController, workout: HKWorkout?, selectedWorkout: Int?)
}

class WorkoutsViewController: UITableViewController {
    var brain = PaceBrain()
    var workouts = [HKWorkout]()
    var healthManager = HealthManager()
    
    var selectedWorkout:Int? = nil
    
    var delegate: WorkoutsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthManager.readRunningWorkouts({ (results, error) -> Void in
            if error != nil {
                print("Error reading workouts: \(error?.localizedDescription)")
                return
            } else {
                print("Workouts read successfully.")
            }
            self.workouts = results as! [HKWorkout]
            if self.workouts.count == 0 {
                let alert = UIAlertController(title: "No Data", message: "The Health App does not currently have any workout data.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("DISMISS", comment: "Dismiss"), style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.tableView.reloadData()
        })
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
        let workout = workouts[(indexPath as NSIndexPath).row]
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: workout.startDate)
        cell.textLabel!.text = "\(dateString)"
        var detailText = workout.totalDistance != nil ? brain.formatter.string(from: NSNumber(value: workout.totalDistance!.doubleValue(for: brain.unit)))! + " \(brain.unit) in " : "0.0 \(brain.unit) in "
        detailText += "\(brain.timeDecimalToString(workout.duration / 60))"
        cell.detailTextLabel?.text = detailText
        if (indexPath as NSIndexPath).row == selectedWorkout {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<numberOfRows {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
            cell?.accessoryType = row == (indexPath as NSIndexPath).row ? .checkmark : .none
        }
        selectedWorkout = (indexPath as NSIndexPath).row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let delegate = self.delegate {
            let localWorkout: HKWorkout? = selectedWorkout == nil ? nil : workouts[selectedWorkout!]
            delegate.didFinishChoosingWorkout(self, workout: localWorkout, selectedWorkout: selectedWorkout)
        }
    }
}
