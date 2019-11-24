//
//  CharacterController.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import UIKit

class CharacterController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Properties
    let client = SWAPIClient()
    var characters: [Character] = []
    var isMetric: Bool = true
    
    
    //Outlets
    @IBOutlet weak var birthDate: UILabel!
    @IBOutlet weak var homeWorld: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var eyesLabel: UILabel!
    @IBOutlet weak var hairLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var associatedVehicleTextView: UITextView!
    @IBOutlet weak var smallestLabel: UILabel!
    @IBOutlet weak var largestLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Start the activity indicator off, and hide the two buttons to minimise early interaction errors
        self.activityIndicator.startAnimating()
        self.englishButton.isHidden = true
        self.metricButton.isHidden = true
        
        //setup the navigation bar for this view
        setupNavBar()
        
        //retrieve character data
        client.getCharacters { (characters, error) in
            
            if error != nil {
                // If there is an error retrieving or parsing the data, pop to root and display the error.
                self.navigationController?.popToRootViewController(animated: true)
                self.displayAlertWith(error: error!)
                
            }else{
            
            //assign characters, reload picker, setup view and do relevant loading setup
            self.characters = characters
            self.pickerView.reloadAllComponents()
            self.setupView(with: characters[0])
            self.englishButton.isHidden = false
            self.metricButton.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.setupSmallestAndLargest()
            
            }
        }
    }
    
    //Pickerview Datasource functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return characters.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
     
        return characters[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setupView(with: characters[row])
    }
    
    
    func setupView(with person: Character){
        
        //setup character relevant labels
        self.nameLabel.text = person.name
        self.birthDate.text = person.birthDate
        self.homeWorld.text = person.home.localizedCapitalized
        
        //assign their height based on conversion option || Remember this method is called everytime the picker updates
        if isMetric{
            
           self.heightLabel.text = person.height
            
        }else if !isMetric{
            
            guard let heightInt:Double = Double(person.height) else{
                displayAlertWith(error: SWAPIError.heightConversionError)
                return
            }
            
            let inches = Double(heightInt) / 2.54
            
            self.heightLabel.text = String(inches.rounded(toPlaces: 2))
            
        }
        
        //setup character relevant labels
        self.eyesLabel.text = person.eyes.localizedCapitalized
        self.hairLabel.text = person.hair.localizedCapitalized
        
        //Add associated vehicles and starships to one carriage returned string to display in the text view
        var associatedVehicles: String = ""
        
        for vehicle in person.associatedVehicles{
            associatedVehicles = associatedVehicles + vehicle + "\r\n"
        }
        for starship in person.associatedStarships{
            associatedVehicles = associatedVehicles + starship + "\r\n"
        }
        
        self.associatedVehicleTextView.text = associatedVehicles
        
    }
    
    func setupSmallestAndLargest(){
        
        var smallest: Character = characters[0]
        var largest: Character = characters[0]
        
        //Loop through all characters comparing each one to the current tallest / smallest and replacing with self if necessary
        for char in characters{
            
            if char.height == "unknown"{
                continue
            }
            
            guard let charInt: Int = Int(char.height), let smallestInt: Int = Int(smallest.height), let largestInt: Int = Int(largest.height) else{
                return
            }
            
            if charInt < smallestInt{
                smallest = char
            }
            
            if charInt > largestInt{
                largest = char
            }
        }
        
        //assign largest and smallest character names to the relevant labels
        largestLabel.text = largest.name
        smallestLabel.text = smallest.name
    }

    
    @IBAction func heightConversion(_ sender: UIButton) {
        
        if sender == englishButton{
            //If conversion is already set to Metric, do nothing
            if isMetric{
            
            guard let heightText = heightLabel.text else{
                displayAlertWith(error: SWAPIError.heightConversionError)
                return
            }
            
            guard let heightInt:Double = Double(heightText) else{
                displayAlertWith(error: SWAPIError.heightConversionError)
                return
            }
                
            // set the metric bool, format buttons and convert
            isMetric = false
            englishButton.setTitleColor(.white, for: .normal)
            metricButton.setTitleColor(.lightGray, for: .normal)
            print("english")
                
            let inches = Double(heightInt) / 2.54
            
            self.heightLabel.text = String(inches.rounded(toPlaces: 2))
                
            }
            
        }else if sender == metricButton{
            //If conversion is set to English, do nothing
            if !isMetric{
            
            guard let heightText = heightLabel.text else{
                displayAlertWith(error: SWAPIError.heightConversionError)
                return
            }
            
            guard let heightInt:Double = Double(heightText) else{
                displayAlertWith(error: SWAPIError.heightConversionError)
                return
            }
            
            // set the metric bool, format buttons and convert
            isMetric = true
            englishButton.setTitleColor(.lightGray, for: .normal)
            metricButton.setTitleColor(.white, for: .normal)
            print("metric")
                
            let inches = Double(heightInt) * 2.54
            
            self.heightLabel.text = String(inches.rounded(toPlaces: 0))
                
            }
        }
    }
    
    //Fairly self explanatory function that displays an alert with relevant error info
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
    
    //setup the nav bar specifically for this view
    func setupNavBar(){
        
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        self.title = "Characters"
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

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

