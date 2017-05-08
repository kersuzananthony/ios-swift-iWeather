//
//  ConfigurationTableViewController.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 07/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {

    var temperaturePickerHidden: Bool = true
    var temperatureDataSource: [Temperature] = Temperature.getAll
    var pressurePickerHidden: Bool = true
    var pressureDataSource: [AtmosphericPressure] = AtmosphericPressure.getAll
    var windSpeedPickerHidden: Bool = true
    var windSpeedDataSource: [WindSpeed] = WindSpeed.getAll
    var userConfiguration = Configuration.instance.getUserConfiguration()
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperaturePickerView: UIPickerView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windSpeedPickerView: UIPickerView!
    @IBOutlet weak var pressurePickerView: UIPickerView!
    @IBOutlet weak var pressureLabel: UILabel!
    
    // MARK: - Quit configuration controller and go back to HomeViewController
    @IBAction func okPressed(_ sender: AnyObject) {
        userConfiguration.temperatureUnity = Temperature(rawValue: self.temperatureLabel.text!)
        userConfiguration.windSpeedUnity = WindSpeed(rawValue: self.windSpeedLabel.text!)
        userConfiguration.atmosphericPressureUnity = AtmosphericPressure(rawValue: self.pressureLabel.text!)
        userConfiguration.saveUserConfiguration()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Everytime ConfigurationViewController view appears, we set all UIPickerView default values
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.temperaturePickerView.selectRow(temperatureDataSource.index(of: userConfiguration.temperatureUnity) ?? 0, inComponent: 0, animated: false)
        self.windSpeedPickerView.selectRow(windSpeedDataSource.index(of: userConfiguration.windSpeedUnity) ?? 0, inComponent: 0, animated: false)
        self.pressurePickerView.selectRow(pressureDataSource.index(of: userConfiguration.atmosphericPressureUnity) ?? 0, inComponent: 0, animated: false)
        
        self.temperatureLabel.text = self.userConfiguration.temperatureUnity.rawValue
        self.windSpeedLabel.text = self.userConfiguration.windSpeedUnity.rawValue
        self.pressureLabel.text = self.userConfiguration.atmosphericPressureUnity.rawValue

    }
    
    // MARK: - Set delegates and datasource of UIPickerView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.temperaturePickerView.delegate = self
        self.temperaturePickerView.dataSource = self
        self.windSpeedPickerView.delegate = self
        self.windSpeedPickerView.dataSource = self
        self.pressurePickerView.delegate = self
        self.pressurePickerView.dataSource = self
    }

    // MARK: - Perfom action when row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            closeAllPickerView()
            displayTemperaturePickerView()
        } else if indexPath.section == 0 && indexPath.row == 2 {
            closeAllPickerView()
            displayWindSpeedPickerView()
        } else if indexPath.section == 0 && indexPath.row == 4 {
            closeAllPickerView()
            displayPressurePickerView()
        } else if indexPath.section == 1 && indexPath.row == 4 {
            displayRateUsMessage()
        }
    }
    
    func closeAllPickerView() {
        self.temperaturePickerHidden = true
        self.temperaturePickerView.isHidden = true
        self.pressurePickerHidden = true
        self.pressurePickerView.isHidden = true
        self.windSpeedPickerHidden = true
        self.windSpeedPickerView.isHidden = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func displayTemperaturePickerView() {
        self.temperaturePickerHidden = false
        self.temperaturePickerView.isHidden = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func displayPressurePickerView() {
        self.pressurePickerHidden = false
        self.pressurePickerView.isHidden = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func displayWindSpeedPickerView() {
        self.windSpeedPickerHidden = false
        self.windSpeedPickerView.isHidden = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if temperaturePickerHidden && indexPath.section == 0 && indexPath.row == 1 {
            return 0
        } else if !temperaturePickerHidden && indexPath.section == 0 && indexPath.row == 1 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else  if windSpeedPickerHidden && indexPath.section == 0 && indexPath.row == 3 {
            return 0
        } else if !windSpeedPickerHidden && indexPath.section == 0 && indexPath.row == 3 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else if pressurePickerHidden && indexPath.section == 0 && indexPath.row == 5 {
            return 0
        } else if !pressurePickerHidden && indexPath.section == 0 && indexPath.row == 5 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

}

extension ConfigurationTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == self.temperaturePickerView || pickerView == self.windSpeedPickerView || pickerView == self.pressurePickerView {
            return 1
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.temperaturePickerView {
            return self.temperatureDataSource.count
        } else if pickerView == self.windSpeedPickerView {
            return self.windSpeedDataSource.count
        } else  if pickerView == self.pressurePickerView {
            return self.pressureDataSource.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.temperaturePickerView {
            return self.temperatureDataSource[row].rawValue
        } else if pickerView == self.windSpeedPickerView {
            return self.windSpeedDataSource[row].rawValue
        } else if pickerView == self.pressurePickerView {
            return self.pressureDataSource[row].rawValue
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.temperaturePickerView {
            self.temperatureLabel.text = self.temperatureDataSource[row].rawValue
            closeAllPickerView()
        } else if pickerView == self.windSpeedPickerView {
            self.windSpeedLabel.text = self.windSpeedDataSource[row].rawValue
            closeAllPickerView()
        } else if pickerView == self.pressurePickerView {
            self.pressureLabel.text = self.pressureDataSource[row].rawValue
            closeAllPickerView()
        }
    }
    
    func displayRateUsMessage() {
        let alertViewController = UIAlertController(title: NSLocalizedString("Rate us", comment: "Rate us"), message: NSLocalizedString("Do you want to rate our weather app?", comment: "Rate us message"), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Later", comment: "Later"), style: .cancel) { (action: UIAlertAction) -> Void in
            
            alertViewController.dismiss(animated: true, completion: nil)
        }
        
        let rateItAction = UIAlertAction(title: NSLocalizedString("Go Now!", comment: "Go now!"), style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id\(APP_ID)")!)
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(rateItAction)
        
        self.present(alertViewController, animated: true, completion: nil)

    }
    
}
