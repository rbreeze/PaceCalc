//
//  ResultsTableViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 11/5/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    var brain = PaceBrain.sharedInstance

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return brain.dataPile.mileage.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "dayResultCell")! as UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "dayResultCell")
        var mainLabel: String, detailLabel: String
        if (indexPath as NSIndexPath).section == 0 {
            if brain.dataPile.dates[(indexPath as NSIndexPath).row] != nil {
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.medium
                mainLabel = "\(formatter.string(from: brain.dataPile.dates[(indexPath as NSIndexPath).row]! as Date))"
            } else {
                mainLabel = "Day \((indexPath as NSIndexPath).row + 1)"
            }
            let dailyData = brain.weeklyDataForDay((indexPath as NSIndexPath).row)
            let avgPace = brain.findAveragePace(dailyData)
            detailLabel = avgPace.isNaN ? "0:00 / \(brain.unit)" : "\(brain.timeDecimalToString(avgPace)) / \(brain.unit)"
        } else {
            let avgPace = brain.findAveragePace(brain.dataPile)
            mainLabel = avgPace.isNaN ? NSLocalizedString("AVERAGE_PACE", comment: "Average Pace") + ": 0:00 / \(brain.unit)" : NSLocalizedString("AVERAGE_PACE", comment: "Average Pace") + ": \(brain.timeDecimalToString(avgPace)) / \(brain.unit)"
            detailLabel = ""
        }
        cell.textLabel?.text = mainLabel
        cell.detailTextLabel?.text = detailLabel
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var avgPaceNumber: Double
        if (indexPath as NSIndexPath).row == 0 && (indexPath as NSIndexPath).section == 1 {
            avgPaceNumber = brain.findAveragePace(brain.dataPile)
        } else {
            let dailyData = brain.weeklyDataForDay((indexPath as NSIndexPath).row)
            avgPaceNumber =  brain.findAveragePace(dailyData)
        }
        let avgPace = avgPaceNumber.isNaN ? "0:00" : brain.timeDecimalToString(avgPaceNumber)
        let alert = UIAlertController(title: NSLocalizedString("AVERAGE_PACE", comment: "Average Pace"), message: "\(avgPace) / \(brain.unit)", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: NSLocalizedString("DISMISS", comment: "Dismiss"), style: .default, handler: nil)
        let copy = UIAlertAction(title: NSLocalizedString("COPY", comment: "Copy"), style: .default, handler: {_ in self.brain.addToClipboard(avgPace)})
        alert.addAction(dismiss)
        alert.addAction(copy)
        self.present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Daily Average Paces" : nil
    }
    
}
