//
//  ViewController.swift
//  Currency Converter
//
//  Created by Nimil Peethambaran on 10/13/16.
//  Copyright © 2016 Nimil Peethambaran. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    let fmt = NumberFormatter()
    
    
    var todaysRate = Double.init(60.00)
    var rateDate = ""
    
    @IBOutlet var curLabel: UILabel!
    @IBOutlet var rupeeTxt: UITextField!
    
    @IBOutlet var dollarTxt: UITextField!
    
    
    @IBOutlet var loader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fmt.numberStyle = .decimal
        getCurrencyRate(loader: loader, label:curLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    @IBAction func convertToRupees(_ dollarText: UITextField) {

        if(dollarText.text != nil){
            let amount = dollarText.text!
            rupeeTxt.text = convertMoney(amount: amount,sign: "$")
            
        }
        
    }
    func convertMoney(amount: String, sign: String)->String{
        
        guard amount != "" else{
            print("amount is empty")
            return ""
        }
        
        var value = Double.init( amount)
        if(sign=="INR"){
            value?.divide(by: todaysRate)

        }else{
            value?.multiply(by: todaysRate)
        }
        return fmt.string(from: NSNumber.init(value:value!))!
    }
    
    @IBAction func convertToDollar(_ sender: UITextField) {
        let value = sender.text
        
        if(value != nil){
            dollarTxt.text = convertMoney(amount: value!,sign:"INR")
        }
    }
    func getCurrencyRate(loader: UIActivityIndicatorView, label: UILabel) {
        
        self.loader.startAnimating();
        guard let url = URL(string:"https://api.fixer.io/latest?base=USD&symbols=INR")else{
            print("failed to connect")
            return
        }
        let request:URLRequest = URLRequest(url:url as URL!);
        let config = URLSessionConfiguration.default;
        let connection = URLSession(configuration: config);
        let task = connection.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error while getting the exchange code")
                print(error)
                return
            }
            
            guard let responseData = data else{
                print("no response")
                return
            }
            do{
                guard let rate = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String:AnyObject] else{
                    print("error")
                    return
                }
                print(rate)
                guard let day = rate["date"] as? String else {
                    print("no date tag present")
                    return
                }
                self.rateDate = day
                guard let rates = rate["rates"] as? [String:AnyObject] else{
                    print("no rates tag present")
                    return
                }
                
                guard let curRate = rates["INR"] as? Double else{
                    print("INR is not present");
                    return
                }
                self.todaysRate = curRate
                print("current rate set to \(curRate)")
            }catch{
                print("error while converting json")
                return
            }
            
            DispatchQueue.main.async {
                label.text = "As of \(self.rateDate), the rate is \(self.todaysRate)"
                print("calling stopAnimation");
                self.loader.stopAnimating()
                self.loader.isHidden = true
                print("called stopAnimation");
            }
            
            
        }
        task.resume()

    }
    
}
