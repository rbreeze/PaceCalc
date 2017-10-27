//
//  DistanceUnitPickerController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 11/21/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit

class DistanceUnitPickerController: UITableViewController {
    
    let defaults = UserDefaults.standard
    var brain = PaceBrain.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let string = defaults.string(forKey: "distanceUnitKey") {
            let section = 0
            let numberOfRows = tableView.numberOfRows(inSection: section)
            for row in 0..<numberOfRows {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                    cell.accessoryType = cell.textLabel!.text == string ? .checkmark : .none
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<numberOfRows {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
            cell?.accessoryType = row == (indexPath as NSIndexPath).row ? .checkmark : .none
        }
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            let oldUnit = brain.unit
            defaults.setValue(selectedCell.textLabel!.text, forKey: "distanceUnitKey")
            defaults.synchronize()
            brain.updateUnit()
            brain.convertDataToUnit(oldUnit, toUnit: brain.unit)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
