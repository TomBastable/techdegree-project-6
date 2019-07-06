//
//  StarshipController.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import UIKit

class StarshipController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    //properties
    let client = SWAPIClient()
    var starships: [Starships] = []
    var isMetric: Bool = true
    var isUsd: Bool = false
    var conversionRate = 0
    
    //outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var crewLabel: UILabel!
    @IBOutlet weak var usdButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var smallestLabel: UILabel!
    @IBOutlet weak var largestLabel: UILabel!
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
        
        client.getStarships { (starships, error) in
            
            if error != nil {
                // If there is an error retrieving or parsing the data, pop to root and display the error.
                self.navigationController?.popToRootViewController(animated: true)
                self.displayAlertWith(error: error!)
                
            }else{
            //assign starships, reload picker, setup view and do relevant loading setup
            self.starships = starships
            self.pickerView.reloadAllComponents()
            self.setupView(with: starships[0])
            self.usdButton.isHidden = false
            self.creditsButton.isHidden = false
            self.englishButton.isHidden = false
            self.metricButton.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            }
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return starships.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return starships[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setupView(with: starships[row])
    }
    

    
    func setupView(with starship: Starships){
        
        //setup starship relevant labels
        nameLabel.text = starship.name
        makeLabel.text = starship.make
        costLabel.text = starship.cost
        
        //assign the height based on conversion option || Remember this method is called everytime the picker updates
        if isMetric{
            
            self.lengthLabel.text = starship.length
            
        }else if !isMetric{
            
            guard let heightInt:Double = Double(starship.length) else{
                displayAlertWith(error: SWAPIError.lengthConversionError)
                return
            }
            
            let inches = Double(heightInt) * 3.281
            
            self.lengthLabel.text = String(inches.rounded(toPlaces: 2))
        }
        
        //setup vehicle relevant labels
        classLabel.text = starship.starshipsClass
        crewLabel.text = starship.crew
        
    }
    
    func setupSmallestAndLargest(){
    
        var smallest: Starships = self.starships[0]
        var largest: Starships = self.starships[0]
        
        //Loop through all starships comparing each one to the current tallest / smallest and replacing with self if necessary
        for starsh in self.starships{
            
            if starsh.length == "unknown"{
                continue
            }
            
            guard let charInt: Double = Double(starsh.length.digits), let smallestInt: Double = Double(smallest.length.digits), let largestInt: Double = Double(largest.length.digits) else{
                return
            }
            
            if charInt < smallestInt{
                smallest = starsh
            }
            
            if charInt > largestInt{
                largest = starsh
            }
        }
        
        //assign largest and smallest names to the relevant labels
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
                print("english")
                isMetric = false
                englishButton.setTitleColor(.white, for: .normal)
                metricButton.setTitleColor(.lightGray, for: .normal)
                
                let inches = Double(heightInt) * 3.281
                
                self.lengthLabel.text = String(inches.rounded(toPlaces: 2))
            }
        }else if sender == metricButton{
            //If conversion is set to English, do nothing
            if !isMetric{
                
                
                guard let heightText = lengthLabel.text else{
                    displayAlertWith(error: SWAPIError.lengthConversionError)
                    return
                }
                
                guard let heightInt:Double = Double(heightText) else{
                    displayAlertWith(error: SWAPIError.lengthConversionError)
                    return
                }
                
                // set the metric bool, format buttons and convert
                print("metric")
                isMetric = true
                englishButton.setTitleColor(.lightGray, for: .normal)
                metricButton.setTitleColor(.white, for: .normal)
                
                let inches = Double(heightInt) / 3.281
                
                self.lengthLabel.text = String(inches.rounded(toPlaces: 1))
            }
        }
        
    }
    
    @IBAction func conversionRate(_ sender: UIButton) {
        
            //Determine if a conversion rate has been set yet, if not prompt the user to enter one
            if conversionRate == 0{
                
                //setup an alert with a text field
                let alert = UIAlertController(title: "Set Conversion Rate", message: "Please enter below how many dollars make up a credit.", preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.placeholder = "Exchange Rate"
                    textField.keyboardType = .numberPad
                }
                alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
                    
                    let textField = alert?.textFields![0]
                    
                    //safely check for letters or zero value
                    guard let conversionString: String = textField?.text else{
                        self.displayAlertWith(error: SWAPIError.invalidConversionRate)
                        return
                    }
                    
                    guard let conversionInt: Int = Int(conversionString) else{
                        self.displayAlertWith(error: SWAPIError.invalidConversionRate)
                        return
                    }
                    
                    if conversionInt == 0{
                        self.displayAlertWith(error: SWAPIError.invalidConversionRate)
                        return
                    }
                    //set conversion rate, convert
                    self.conversionRate = conversionInt
                    self.conversionRate(self.usdButton)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            //if a conversion rate is set, the below statement will execute
            if conversionRate != 0 && sender == usdButton{
                //If usd is already set, do nothing
                if !isUsd{
                    guard let costString = costLabel.text else{
                        self.displayAlertWith(error: SWAPIError.cannotConvertUnknownValue)
                        return
                    }
                    guard let costInt = Int(costString) else{
                        self.displayAlertWith(error: SWAPIError.cannotConvertUnknownValue)
                        return
                    }
                    //convert the cost
                    let convertedToUsd = costInt * conversionRate
                    //assign cost to label
                    costLabel.text = String(convertedToUsd)
                    //set bool and format buttons
                    isUsd = true
                    creditsButton.setTitleColor(.lightGray, for: .normal)
                    usdButton.setTitleColor(.white, for: .normal)
                }
            } else if conversionRate != 0 && sender == creditsButton{
                //If usd is not already set, do nothing
                if isUsd{
                    guard let costString = costLabel.text else{
                        self.displayAlertWith(error: SWAPIError.cannotConvertUnknownValue)
                        return
                    }
                    guard let costInt = Int(costString) else{
                        self.displayAlertWith(error: SWAPIError.cannotConvertUnknownValue)
                        return
                    }
                    //convert the cost
                    let convertedToUsd = costInt / conversionRate
                    //assign cost to label
                    costLabel.text = String(convertedToUsd)
                    //set bool and format buttons
                    isUsd = false
                    creditsButton.setTitleColor(.white, for: .normal)
                    usdButton.setTitleColor(.lightGray, for: .normal)
                }
                
            }
        
    }
    
    func setupNavBar(){
        
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        self.title = "Starships"
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
        case SWAPIError.lengthConversionError:
            title = "Length Conversion Error"
            subTitle = "Most likely issue is that the height is unknown."
            buttonTitle = "OK"
        case SWAPIError.invalidConversionRate:
            title = "Invalid Conversion Rate"
            subTitle = "A conversion rate may only be made of numbers and cannot be 0 (Zero). Conversion rate not set. Please try again."
            buttonTitle = "Ok"
        case SWAPIError.cannotConvertUnknownValue:
            title = "Cannot convert unknown value"
            subTitle = "You can only convert a vehicle that has a known value. Unknown values aren't convertable from Imperial Credits to USD"
            buttonTitle = "Ok"
        default:
            title = "Error"
            subTitle = "\(error)"
            buttonTitle = "OK"
        }
        
        let alert = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        
        self.present(alert, animated: true)
        
    }

}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
