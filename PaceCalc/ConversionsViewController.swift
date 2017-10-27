//
//  ConversionsViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 9/11/16.
//  Copyright © 2016 Remington Breeze. All rights reserved.
//

import Foundation
import UIKit

class ConversionsViewController:UITableViewController {
    var brain = PaceBrain.sharedInstance
    
    var currentSlot = Int()

    override func numberOfSections(in tableView: UITableView) -> Int {
        return brain.categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return brain.foods.count
        }
        else if (section == 1) {
            return brain.landmarks.count
        }
        else if (section == 2) {
            return brain.shows.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversionCell", for: indexPath)

        var unit: String
        
        switch indexPath.section {
        case 0:
            unit = " kcal"
            break
        case 1:
            unit = " miles"
            break
        case 2:
            unit = " min"
            break
        default:
            unit = ""
        }
        
        let currentConversionsCategory = brain.conversions[brain.categories[indexPath.section]]!
        
        cell.textLabel?.text = Array(currentConversionsCategory.keys)[indexPath.row]
        cell.detailTextLabel?.text = "\(Array(currentConversionsCategory.values)[indexPath.row].value)\(unit)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        brain.updateSlots(slotNumber: currentSlot, key: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!, type: brain.categories[indexPath.section])
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return brain.categories[section]
    }
    
}
