//
//  PaceCalcViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 10/27/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit
import HealthKit

protocol ModalDelegate {
    func didFinishModalView(_ controller: PaceCalcViewController)
}

class PaceCalcViewController: UITableViewController, EditDataDelegate {
    
    var brain = PaceBrain.sharedInstance
    var healthManager = HealthManager()
    
    var delegate: ModalDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
    }
    
    let defaults = UserDefaults.standard
    
    @IBAction func doneEditing(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        brain.dataPile.mileage.append(0.0)
        brain.dataPile.minutes.append(0.0)
        brain.dataPile.seconds.append(0.0)
        brain.dataPile.paces.append(0.0)
        brain.dataPile.dates.append(nil)
        self.performSegue(withIdentifier: "editData", sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let delegate = self.delegate {
            delegate.didFinishModalView(self)
        }
    }
    
    func updateDetails() {
        let rows = tableView.numberOfRows(inSection: 0)
        for row in (0 ..< rows) {
            let mileage = brain.dataPile.mileage[row]
            let minutes = Int(brain.dataPile.minutes[row])
            let seconds = Int(brain.dataPile.seconds[row])
            let string = brain.dataPile.mileage[row] == 0 ? NSLocalizedString("ENTER", comment: "Enter") : seconds >= 10 ? brain.formatter.string(from: NSNumber(value: mileage))! + " \(brain.unit) " + NSLocalizedString("IN", comment: "in") + " \(minutes):\(seconds)" : brain.formatter.string(from: NSNumber(value: mileage))! + " \(brain.unit) " + NSLocalizedString("IN", comment: "in") + " \(minutes):0\(seconds)"
            tableView.cellForRow(at: IndexPath(row: row, section: 0))!.detailTextLabel?.text = string
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.updateDetails()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func didFinishEditing(_ controller: EditDataTableViewController, data: RunData) {
        brain.addToPile(data)
        self.tableView.reloadData()
        updateDetails()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        } else if section == 0 {
            return brain.dataPile.mileage.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete && (indexPath as NSIndexPath).row != 0 && (indexPath as NSIndexPath).section != 1 {
            brain.dataPile.mileage.remove(at: (indexPath as NSIndexPath).row)
            brain.dataPile.minutes.remove(at: (indexPath as NSIndexPath).row)
            brain.dataPile.seconds.remove(at: (indexPath as NSIndexPath).row)
            brain.dataPile.dates.remove(at: (indexPath as NSIndexPath).row)
            brain.dataPile.paces.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
            updateDetails()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).section == 1 {
            return false
        } else if (indexPath as NSIndexPath).row == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Run Data" : nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        cell = self.tableView.dequeueReusableCell(withIdentifier: "dayCell")! as UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "dayCell")
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        var mainLabel: String, detailLabel: String
        if (indexPath as NSIndexPath).section == 0 {
            if brain.dataPile.dates[(indexPath as NSIndexPath).row] != nil {
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.medium
                mainLabel = "\(formatter.string(from: brain.dataPile.dates[(indexPath as NSIndexPath).row]! as Date))"
            } else {
                mainLabel = NSLocalizedString("DAY", comment: "Day") + " \((indexPath as NSIndexPath).row + 1)"
            }
            detailLabel = NSLocalizedString("ENTER", comment: "Enter")
        } else {
            let avgPace = brain.findAveragePace(brain.dataPile)
            mainLabel = avgPace.isNaN ? NSLocalizedString("AVERAGE_PACE", comment: "Average Pace") + ": 0:00 / \(brain.unit)" : NSLocalizedString("AVERAGE_PACE", comment: "Average Pace") + ": \(brain.timeDecimalToString(avgPace)) / \(brain.unit)"
            detailLabel = "Details"
        }
        cell.textLabel?.text = mainLabel
        cell.detailTextLabel?.text = detailLabel
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = (indexPath as NSIndexPath).row
        let section = (indexPath as NSIndexPath).section
        if row == 0 && section == 1 {
            self.performSegue(withIdentifier: "showResults", sender: self)
        } else {
            self.performSegue(withIdentifier: "editData", sender: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = NSLocalizedString("BACK", comment: "Back")
        navigationItem.backBarButtonItem = backButton
        if segue.identifier == "editData" {
            if let editDataController = segue.destination as? EditDataTableViewController {
                var dayInt: Int
                
                if let _ = sender as? IndexPath {
                    editDataController.day = (sender! as AnyObject).row
                    dayInt = (sender! as AnyObject).row
                } else {
                    editDataController.day = brain.dataPile.mileage.count-1
                    dayInt = brain.dataPile.mileage.count - 1
                }
                
                editDataController.data.mileage = brain.dataPile.mileage[dayInt]
                editDataController.data.minutes = brain.dataPile.minutes[dayInt]
                editDataController.data.seconds = brain.dataPile.seconds[dayInt]
                editDataController.data.date = brain.dataPile.dates[dayInt]
                editDataController.data.pace = brain.dataPile.paces[dayInt]
                editDataController.delegate = self
            }
        }
    }
    
}
