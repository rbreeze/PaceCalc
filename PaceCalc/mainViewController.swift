//
//  mainViewController.swift
//  PaceCalc
//
//  Created by Remington Breeze on 9/7/16.
//  Copyright © 2016 Remington Breeze. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class mainViewController: UIViewController, ModalDelegate {
    
    var brain = PaceBrain.sharedInstance
    var data = RunData()
    
    var firstRun = true
    
    @IBOutlet weak var mainView: UIView!
    
    func hideKeyboard() {
        time.endEditing(true)
        distance.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mainViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        mainView.addGestureRecognizer(tapGesture)
    }
    
    func didFinishModalView(_ controller: PaceCalcViewController) {
        self.updateData()
    }
    
    func updateData() {
        
        firstRun = false
        
        var unwrappedMileage: String
        
        if brain.dataPile.mileage[0] != 0 {
            
            var dt: Double;
            
            if (brain.unit != HKUnit.mile()) {
                dt = brain.dataPile.mileage[0] * 1.60934
            } else {
                dt = brain.dataPile.mileage[0]
            }
            
            if (brain.dataPile.seconds[0] < 10) {
                time.text = "\(Int(brain.dataPile.minutes[0])):\(Int(brain.dataPile.seconds[0]))0"
            } else {
                time.text = "\(Int(brain.dataPile.minutes[0])):\(Int(brain.dataPile.seconds[0]))"
            }
            
            
            distance.text = "\(dt)"
            
            unwrappedMileage = distance.text ?? "0"
            
            data.mileage = dt
            data.minutes = brain.dataPile.minutes[0]
            data.seconds = brain.dataPile.seconds[0]
            data.date = nil
            
        } else {
            
            unwrappedMileage = distance.text ?? "0"
            data.mileage = brain.localizedStringToDouble(unwrappedMileage).double ?? 0
            let minutesAndSeconds = brain.timeStringToMinutesAndSeconds(time.text ?? "0:00")
            data.minutes = minutesAndSeconds.minutes
            data.seconds = minutesAndSeconds.seconds
            data.date = nil
            
        }
        
        let pace = brain.findMissing(unwrappedMileage, time: time.text, pace: nil).pace ?? "0:00"
        let paceMS = brain.timeStringToMinutesAndSeconds(pace)
        let paceDecimal: Double = brain.minutesAndSecondsToDouble(paceMS.minutes, seconds: paceMS.seconds)
        data.pace = paceDecimal
        data.day = 0
        
        var decimalTime: Double
        
        if data.seconds != 0 {
            decimalTime = data.minutes + (data.seconds / 60)
        } else {
            decimalTime = data.minutes
        }
        
        
        var slotLabels: [String] = ["", "", "", "", ""]
        var slotData: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0]
        
        for (index, slot) in brain.currentSlots.keys.enumerated() {
            slotLabels[index] = (brain.conversions[brain.currentSlots.types[index]]?[brain.currentSlots.keys[index]]!.label.uppercased())!
            switch brain.currentSlots.types[index] {
            case "Foods":
                slotData[index] = round(brain.calculateFoodUnits(brain.calculateCaloriesBurned(paceDecimal, distance: data.mileage), food: slot) * 100) / 100
                break
            case "Landmarks":
                slotData[index] = round(brain.calculateDistanceUnits(data.mileage, landmark: slot)*1000)/1000
                break
            case "Shows":
                slotData[index] = round(brain.calculateEpisodes(decimalTime, show: slot)*100)/100
                break
            default:
                slotData[index] = 0.0
                break
            }
        }
        
        slot1Label.text = slotLabels[0]
        slot2Label.text = slotLabels[1]
        slot3Label.text = slotLabels[2]
        slot4Label.text = slotLabels[3]
        slot5Label.text = slotLabels[4]
        
        slot1.text = "\(slotData[0])"
        slot2.text = "\(slotData[1])"
        slot3.text = "\(slotData[2])"
        slot4.text = "\(slotData[3])"
        slot5.text = "\(slotData[4])"
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModal" {
            let navigationController = segue.destination as? UINavigationController
            let paceCalcController = navigationController?.viewControllers[0] as? PaceCalcViewController
            if let viewController = paceCalcController {
                viewController.delegate = self
            }
        }
    }
    
    @IBOutlet weak var distance: UITextField!

    @IBOutlet weak var time: UITextField!
    
    @IBAction func distanceDidFinishEditing(_ sender: AnyObject) {
        updateData()
    }
    
    @IBAction func timeDidFinishEditing(_ sender: AnyObject) {
        updateData()
    }
    
    @IBOutlet weak var slot1: UILabel!
    @IBOutlet weak var slot2: UILabel!
    @IBOutlet weak var slot3: UILabel!
    @IBOutlet weak var slot4: UILabel!
    @IBOutlet weak var slot5: UILabel!
    
    @IBOutlet weak var slot1Label: UILabel!
    @IBOutlet weak var slot2Label: UILabel!
    @IBOutlet weak var slot3Label: UILabel!
    @IBOutlet weak var slot4Label: UILabel!
    @IBOutlet weak var slot5Label: UILabel!
    
//    override var prefersStatusBarHidden : Bool {
//        return true
//    }
}
