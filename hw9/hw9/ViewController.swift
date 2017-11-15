//
//  ViewController.swift
//  hw9
//
//  Created by Suyash Shetty on 11/13/17.
//

import UIKit
import Alamofire
import EasyToast
import SearchTextField
import SwiftSpinner

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteTableViewCell", for: indexPath) as? FavoritesTableViewCell else {
            fatalError("The dequeued cell is not an instance of FavoritesTableViewCell");
        }
        
        // TODO: Have to replace with local storage
        var stocks = ["AAPL","GOOG"];
        var prices = [47.04,988.20];
        var change = ["0.24 (0.59%)", "3.75 (0.38%)"];
        
        cell.stockNameLabel.text = stocks[indexPath.row];
        cell.priceLabel.text = String(format:"%f", prices[indexPath.row]);
        cell.changeLabel.text = change[indexPath.row];
        
        return cell;
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sortByPickerView {
            return sortByOptions.count;
        } else if pickerView == orderPickerView {
            return orderOptions.count;
        }
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica", size: 16)
            pickerLabel?.textAlignment = NSTextAlignment.center;
        }
        
        if pickerView == sortByPickerView {
            pickerLabel?.text = sortByOptions[row];
        } else if pickerView == orderPickerView {
            pickerLabel?.text = orderOptions[row];
        }
        
        return pickerLabel!;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        getQuote((Any).self);
        return true;
    }
    
    // MARK: Properties
    @IBOutlet var stockTextField: SearchTextField!
    @IBOutlet var getQuoteButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var autoRefreshSwitch: UISwitch!
    @IBOutlet var manualRefreshButton: UIButton!
    @IBOutlet var sortByPickerView: UIPickerView!
    @IBOutlet var orderPickerView: UIPickerView!
    @IBOutlet var favoritesTableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let sortByOptions = ["Default", "Symbol", "Price", "Change", "Change %"];
    let orderOptions = ["Ascending", "Descending"];
    let autocompleteUrl = "http://isydfq.us-west-1.elasticbeanstalk.com/autocomplete?queryText=";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Connect sortByPickerView
        self.sortByPickerView.delegate = self;
        self.sortByPickerView.dataSource = self;
        
        // Connect orderPickerView
        self.orderPickerView.delegate = self;
        self.orderPickerView.dataSource = self;
        
        // Connect favoritesTableView
        self.favoritesTableView.delegate = self;
        self.favoritesTableView.dataSource = self;
        
        // Connect text field
        self.stockTextField.delegate = self;
        
        // Hide activity indicator when app loads
        self.activityIndicator.stopAnimating();
        
        // Customize the stockTextField
        self.stockTextField.theme.cellHeight = 50;
        self.stockTextField.maxNumberOfResults = 5;
        self.stockTextField.minCharactersNumberToStartFiltering = 1;
        self.stockTextField.theme.bgColor = UIColor (red: 1, green: 1, blue: 1, alpha: 1);
        self.stockTextField.userStoppedTypingHandler = {
            if let criteria = self.stockTextField.text {
                if criteria.count > 1 {
                    Alamofire.request(self.autocompleteUrl + self.stockTextField.text!).responseJSON { response in
                        var autocompleteList = [String]();
                        if let json = response.result.value {
                            for stock in json as! [Dictionary<String, AnyObject>] {
                                let name = stock["Name"] as? String;
                                let symbol = stock["Symbol"] as? String;
                                let exchange = stock["Exchange"] as? String;
                                let listText = symbol! + " - " + name! + " (" + exchange! + ")";
                                autocompleteList.append(listText);
                            }
                        }
                        self.stockTextField.filterStrings(autocompleteList);
                    }
                }
            }
        }
        
        // Adding tap gesture recognizer to dismiss keyboard
        self.hideKeyboardWhenTappedAround();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true);
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.setNavigationBarHidden(false, animated: true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "getStockQuote") {
            if let data = sender as? String {
                if let controller = segue.destination as? StockDetailsViewController {
                    controller.stockSymbol = data;
                }
            }
        }
    }
    
    // MARK: Actions
    @IBAction func getQuote(_ sender: Any) {
        let stockString = stockTextField.text;
        if ((stockString?.isEmpty)! || (stockString?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            self.view.showToast("Please enter a stock name or symbol", position: .bottom, popTime: 5, dismissOnTap: true);
        } else {
            let hyphen: Character = "-";
            if let idx = stockString?.index(of: hyphen) {
                let stockSymbol = String(stockString![..<idx]).trimmingCharacters(in: CharacterSet.whitespaces);
                self.performSegue(withIdentifier: "getStockQuote", sender: stockSymbol);
            }
        }
    }
    
    @IBAction func clearTextField(_ sender: Any) {
        stockTextField.text = "";
    }
    
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
