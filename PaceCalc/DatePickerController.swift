//
//  DatePickerController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 11/18/15.
//  Copyright © 2015 Remington Breeze. All rights reserved.
//

import UIKit

protocol DatePickerDelegate {
    func didFinishPickingDate (_ controller: DatePickerController, date: Date)
}

class DatePickerController: UITableViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var date: Date?
    
    var delegate: DatePickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = date {
            self.datePicker.setDate(date!, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let date:Date = datePicker.date
        
        if let delegate = self.delegate {
            delegate.didFinishPickingDate(self, date: date)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
