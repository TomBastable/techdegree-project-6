//
//  VehicleController.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import UIKit

class VehicleController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //properties
    let client = SWAPIClient()
    var vehicles: [Vehicles] = []
    var isMetric: Bool = true
    var isUsd: Bool = false
    var conversionRate = 0
    
    //outlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var smallestLabel: UILabel!
    @IBOutlet weak var largestLabel: UILabel!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var usdButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Start the activity indicator off, and hide the two buttons to minimise early interaction errors
        self.activityIndicator.startAnimating()
        self.usdButton.isHidden = true
        self.creditsButton.isHidden = true
        self.englishButton.isHidden = true
        self.metricButton.isHidden = true
        //setup the navigation bar for this view
        setupNavBar()
        
        //retrieve vehicle data
        client.getVehicles { (vehicles, error) in
            
            if error != nil {
                // If there is an error retrieving or parsing the data, pop to root and display the error.
                self.navigationController?.popToRootViewController(animated: true)
                self.displayAlertWith(error: error!)
                
            }else{
                
            self.vehicles = vehicles
            self.pickerView.reloadAllComponents()
            self.setupView(with: vehicles[0])
            self.usdButton.isHidden = false
            self.creditsButton.isHidden = false
            self.englishButton.isHidden = false
            self.metricButton.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
                
            }
        }
        
    }
    
    //Pickerview Datasource functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return vehicles.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return vehicles[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setupView(with: vehicles[row])
    }
    
    func setupView(with vehicle: Vehicles){
        
        //setup vehicle relevant labels
        nameLabel.text = vehicle.name
        makeLabel.text = vehicle.make
        costLabel.text = vehicle.cost
        
        //assign the height based on conversion option || Remember this method is called everytime the picker updates
        if isMetric{
            
            self.lengthLabel.text = vehicle.length
            
        }else if !isMetric{
            
            guard let heightInt:Double = Double(vehicle.length) else{
                displayAlertWith(error: SWAPIError.heightConversionError)
                return
            }
            
            let inches = Double(heightInt) * 3.281
            
            self.lengthLabel.text = String(inches.rounded(toPlaces: 2))
        }
        
        //setup vehicle relevant labels
        classLabel.text = vehicle.vehicleClass
        crewLabel.text = vehicle.crew
        
    }
    
    func setupSmallestAndLargest(){
        
        var smallest: Vehicles = vehicles[0]
        var largest: Vehicles = vehicles[0]
        
        //Loop through all vehicles comparing each one to the current tallest / smallest and replacing with self if necessary
        for vehic in vehicles{
            
            if vehic.length == "unknown"{
                continue
            }
            
            guard let charInt: Double = Double(vehic.length), let smallestInt: Double = Double(smallest.length), let largestInt: Double = Double(largest.length) else{
                return
            }
            
            if charInt < smallestInt{
                smallest = vehic
            }
            
            if charInt > largestInt{
                largest = vehic
            }
        }
        
        //assign largest and smallest character names to the relevant labels
        largestLabel.text = largest.name
        smallestLabel.text = smallest.name
        
    }
    
    @IBAction func metricFunctions(_ sender: UIButton) {
        
        if sender == englishButton{
            //If conversion is already set to Metric, do nothing
            if isMetric{
                
                guard let heightText = lengthLabel.text else{
                    displayAlertWith(error: SWAPIError.lengthConversionError)
                    return
                }
                
                guard let heightInt:Double = Double(heightText) else{
                    displayAlertWith(error: SWAPIError.lengthConversionError)
                    return
                }
                // set the metric bool, format buttons and convert
                isMetric = false
                englishButton.setTitleColor(.white, for: .normal)
                metricButton.setTitleColor(.lightGray, for: .normal)
                print("english")
                
                let inches = Double(heightInt) * 3.281
                
                self.lengthLabel.text = String(inches.rounded(toPlaces: 2))
            }
        }else if sender == metricButton{
            if !isMetric{
                print("metric")
                isMetric = true
                englishButton.setTitleColor(.lightGray, for: .normal)
                metricButton.setTitleColor(.white, for: .normal)
                
                guard let heightText = lengthLabel.text else{
                    return
                }
                
                guard let heightInt:Double = Double(heightText) else{
                    return
                }
                
                let inches = Double(heightInt) / 3.281
                
                self.lengthLabel.text = String(inches.rounded(toPlaces: 1))
            }
        }
        
    }
    
    @IBAction func conversionRate(_ sender: UIButton) {
        
        if costLabel.text == "unknown" {
            print("cannot convert an unknown amount")
        }
        else{
        if conversionRate == 0{
            let alert = UIAlertController(title: "Set Conversion Rate", message: "Please enter below how many dollars make up a credit.", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Exchange Rate"
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
                
                let textField = alert?.textFields![0]
                
                guard let conversionString: String = textField?.text else{
                    return
                }
                
                guard let conversionInt: Int = Int(conversionString) else{
                    return
                }
                
                self.conversionRate = conversionInt
                self.conversionRate(self.usdButton)
                  }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if conversionRate != 0 && sender == usdButton{
            
            if !isUsd{
            guard let costString = costLabel.text else{
                return
            }
            guard let costInt = Int(costString) else{
                return
            }
            
            let convertedToUsd = costInt * conversionRate
            
            costLabel.text = String(convertedToUsd)
                
            isUsd = true
                creditsButton.setTitleColor(.lightGray, for: .normal)
                usdButton.setTitleColor(.white, for: .normal)
            }
        } else if conversionRate != 0 && sender == creditsButton{
            
            if isUsd{
                guard let costString = costLabel.text else{
                    return
                }
                guard let costInt = Int(costString) else{
                    
                    return
                }
                
                let convertedToUsd = costInt / conversionRate
                
                costLabel.text = String(convertedToUsd)
                
                isUsd = false
                creditsButton.setTitleColor(.white, for: .normal)
                usdButton.setTitleColor(.lightGray, for: .normal)
            }
            
        }
        }
    }
    
    func displayAlertWith(error: Error){
        
        let title: String
        let subTitle: String
        let buttonTitle: String
        
        switch error {
            
        case SWAPIError.invalidData:
            title = "Error Retrieving Data"
            subTitle = "Please try again"
            buttonTitle = "OK"
        case SWAPIError.resultsRetrievalError:
            title = "Error retrieving results - possible network issue"
            subTitle = "Please check your network and try again"
            buttonTitle = "OK"
        case SWAPIError.heightConversionError:
            title = "Height Conversion Error"
            subTitle = "Most likely issue is that the height is unknown."
            buttonTitle = "OK"
        default:
            title = "Error"
            subTitle = "\(error)"
            buttonTitle = "OK"
        }
        
        let alert = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    func setupNavBar(){
        
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        self.title = "Vehicles"
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.alpha = 0.0
        bar.tintColor = .lightGray
        bar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        bar.topItem?.title = ""
        
    }

}
