//
//  ViewController.swift
//  hw9
//
//  Created by Suyash Shetty on 11/13/17.
//

import UIKit
import CoreData
import Alamofire
import EasyToast
import SearchTextField
import SwiftSpinner

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteTableViewCell", for: indexPath) as? FavoritesTableViewCell else {
            fatalError("The dequeued cell is not an instance of FavoritesTableViewCell");
        }
        
        var favorite = self.favorites[indexPath.row];
        cell.stockNameLabel.text = favorite["symbol"] as? String;
        cell.priceLabel.text = String(format:"$%.2f", favorite["price"] as! Float);
        
        let change = favorite["change"] as! Float;
        let attributedString = NSMutableAttributedString(string: String(format:"%.2f (%.2f%%)", favorite["change"] as! Float, favorite["change_percent"] as! Float));
        let attachment = NSTextAttachment();
        if change > 0 {
            cell.changeLabel.textColor = UIColor.green;
            attachment.image = UIImage(named: "Up.png");
            cell.changeLabel.attributedText = attributedString;
        } else if change < 0 {
            cell.changeLabel.textColor = UIColor.red;
            attachment.image = UIImage(named: "Down.png");
            cell.changeLabel.attributedText = attributedString;
        } else {
            cell.changeLabel.textColor = UIColor.black;
            cell.changeLabel.attributedText = attributedString;
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stockSymbol = self.favorites[indexPath.row]["symbol"] as? String;
        self.performSegue(withIdentifier: "getStockQuote", sender: stockSymbol);
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates();
        if editingStyle == .delete {
            var favorites = UserDefaults.standard.object(forKey: "favorites") as? Dictionary<String, Any>;
            favorites?.removeValue(forKey: self.favorites[indexPath.row]["symbol"] as! String);
            UserDefaults.standard.setValue(favorites, forKeyPath: "favorites");
            self.favorites.remove(at: indexPath.row);
            tableView.deleteRows(at: [indexPath], with: .automatic);
        }
        tableView.endUpdates();
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        orderPickerView.isUserInteractionEnabled = true;
        if(sortByPickerView.selectedRow(inComponent: 0) == 0) {
            orderPickerView.selectRow(0, inComponent: 0, animated: true);
            orderPickerView.isUserInteractionEnabled = false;
            self.favorites.sort { ($0["id"] as! Float) < ($1["id"] as! Float)};
        } else if(sortByPickerView.selectedRow(inComponent: 0) == 1) {
            if(orderPickerView.selectedRow(inComponent: 0) == 0) {
                self.favorites.sort { ($0["symbol"] as! String) < ($1["symbol"] as! String)};
            } else {
                self.favorites.sort { ($0["symbol"] as! String) > ($1["symbol"] as! String)};
            }
        } else if(sortByPickerView.selectedRow(inComponent: 0) == 2) {
            if(orderPickerView.selectedRow(inComponent: 0) == 0) {
                self.favorites.sort { ($0["price"] as! Float) < ($1["price"] as! Float)};
            } else {
                self.favorites.sort { ($0["price"] as! Float) > ($1["price"] as! Float)};
            }
        } else if(sortByPickerView.selectedRow(inComponent: 0) == 3) {
            if(orderPickerView.selectedRow(inComponent: 0) == 0) {
                self.favorites.sort { ($0["change"] as! Float) < ($1["change"] as! Float)};
            } else {
                self.favorites.sort { ($0["change"] as! Float) > ($1["change"] as! Float)};
            }
        } else if(sortByPickerView.selectedRow(inComponent: 0) == 4) {
            if(orderPickerView.selectedRow(inComponent: 0) == 0) {
                self.favorites.sort { ($0["change_percent"] as! Float) < ($1["change_percent"] as! Float)};
            } else {
                self.favorites.sort { ($0["change_percent"] as! Float) > ($1["change_percent"] as! Float)};
            }
        }
        self.favoritesTableView.reloadData();
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
    var favorites = [Dictionary<String, Any>]();
    let autocompleteUrl = "http://isydfq.us-west-1.elasticbeanstalk.com/autocomplete?queryText=";
    let getStockQuoteUrl = "http://isydfq.us-west-1.elasticbeanstalk.com/stock?";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Connect sortByPickerView
        self.sortByPickerView.delegate = self;
        self.sortByPickerView.dataSource = self;
        
        // Connect orderPickerView
        self.orderPickerView.selectRow(0, inComponent: 0, animated: true);
        self.orderPickerView.isUserInteractionEnabled = false;
        self.orderPickerView.delegate = self;
        self.orderPickerView.dataSource = self;
        
        // Connect favoritesTableView
        self.favoritesTableView.delegate = self;
        self.favoritesTableView.dataSource = self;
        
        // Connect text field
        self.stockTextField.delegate = self;
        
        // Hide activity indicator when app loads
        self.activityIndicator.stopAnimating();
        self.activityIndicator.center = self.favoritesTableView.center;
        
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
        
        // Reset the order by picker view
        self.orderPickerView.selectRow(0, inComponent: 0, animated: true);
        self.orderPickerView.isUserInteractionEnabled = false;
        // Set up favorites table
        self.reloadFavoritesTable();
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
    
    @IBAction func autoRefresh(_ sender: UISwitch) {
        if sender.isOn {
            let _: Timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (Timer) in
                self.favorites.removeAll(keepingCapacity: true);
                self.reloadFavoritesTable();
            }
        }
    }
    
    @IBAction func manualRefresh(_ sender: Any) {
        reloadFavoritesTable();
    }
    
    private func reloadFavoritesTable() {
        self.activityIndicator.startAnimating();
        self.manualRefreshButton.isEnabled = false;
        self.autoRefreshSwitch.isEnabled = false;
        self.sortByPickerView.isUserInteractionEnabled = false;
        self.orderPickerView.isUserInteractionEnabled = false;
        
        self.favorites.removeAll(keepingCapacity: true);
        self.favoritesTableView.reloadData();
        let group = DispatchGroup()
        let favorites = UserDefaults.standard.object(forKey: "favorites") as? Dictionary<String, Dictionary<String, Any>>;
        if favorites != nil {
            for (key,value) in favorites! {
                group.enter()
                var dict = Dictionary<String, Any>();
                Alamofire.request(getStockQuoteUrl + "outputsize=compact&stockSymbol=" + key).responseJSON { response in
                    if let json = response.result.value as? Dictionary<String, Any>{
                        dict["id"] = value["id"] as! Float;
                        dict["symbol"] = key;
                        if json["error"] == nil || json["symbol"] != nil {
                            dict["price"] = json["last_price"] as! Float;
                            dict["change"] = json["change"] as! Float;
                            dict["change_percent"] = json["change_percent"] as! Float;
                            self.favorites.append(dict);
                        } else {
                            self.view.showToast("Failed to fetch data for " + key, position: .bottom, popTime: 1, dismissOnTap: true);
                        }
                    }
                    group.leave()
                }
            }
            group.notify(queue: DispatchQueue.main) {
                self.activityIndicator.stopAnimating();
                self.manualRefreshButton.isEnabled = true;
                self.autoRefreshSwitch.isEnabled = true;
                self.sortByPickerView.isUserInteractionEnabled = true;
                print(self.sortByPickerView.selectedRow(inComponent: 0));
                if self.sortByPickerView.selectedRow(inComponent: 0) == 0 {
                    self.orderPickerView.isUserInteractionEnabled = false;
                } else {
                    self.orderPickerView.isUserInteractionEnabled = true;
                }
                self.sortByPickerView.selectRow(0, inComponent: 0, animated: true);
                self.orderPickerView.selectRow(0, inComponent: 0, animated: true);
                self.favorites.sort { ($0["id"] as! Float) < ($1["id"] as! Float)};
                self.favoritesTableView.reloadData();
            }
        }
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
