//
//  SlotsViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 9/11/16.
//  Copyright © 2016 Remington Breeze. All rights reserved.
//

import Foundation
import UIKit

class SlotsViewController:UITableViewController {
    var brain = PaceBrain.sharedInstance
    
        
    @IBAction func doneChoosingSlots(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "slotCell", for: indexPath)
        
        cell.textLabel?.text = "Slot \(indexPath.row + 1)"
        cell.detailTextLabel?.text = brain.currentSlots.keys[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showConversions", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "SLOTS"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showConversions" {
            let destination = segue.destination as? ConversionsViewController
            destination?.currentSlot = (tableView.indexPathForSelectedRow?.row)!
        }
    }

}
