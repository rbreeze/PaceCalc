//
//  SettingsViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 11/21/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var brain = PaceBrain.sharedInstance
    
    let defaults = UserDefaults.standard
    
    @IBAction func doneChangingSettings(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let distanceUnit = defaults.string(forKey: "distanceUnitKey") {
            switch distanceUnit {
            case "Miles" :
                self.distanceUnitLabel.text = distanceUnit
                break
            case "Kilometers", "Kilomètres":
                self.distanceUnitLabel.text = NSLocalizedString("KILOMETERS", comment: "Kilometers")
                break
            default:
                self.distanceUnitLabel.text = distanceUnit
                break
            }
        }
    }
    
    @IBOutlet weak var distanceUnitLabel: UILabel!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 && (indexPath as NSIndexPath).section == 0 {
            self.performSegue(withIdentifier: "chooseDistanceUnit", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
