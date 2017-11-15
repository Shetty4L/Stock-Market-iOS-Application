//
//  CurrentStockViewController.swift
//  Alamofire
//
//  Created by Suyash Shetty on 11/14/17.
//

import UIKit
import SwiftMoment
import WebKit

class CurrentStockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return indicators.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica", size: 16)
            pickerLabel?.textAlignment = NSTextAlignment.center;
        }
        
        pickerLabel?.text = indicators[row];
        
        return pickerLabel!;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(row == 0) {
            self.changeButton.isEnabled = false;
            self.changeButton.setTitleColor(UIColor.lightGray, for: UIControlState.disabled);
        } else {
            self.changeButton.isEnabled = true;
            self.changeButton.setTitleColor(UIColor.darkText, for: UIControlState.normal);
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "currentStockDetail", for: indexPath) as? CurrentStockTableViewCell else {
            fatalError("The dequeued cell is not an instance of CurrentStockTableViewCell");
        }
        var titles = ["Stock Symbol", "Last Price", "Change", "Timestamp", "Open", "Close", "Day's Range", "Volume"];
        cell.stockDetailTitle.text = titles[indexPath.row];
        cell.stockDetailValue.text = self.currentStockTableValues[indexPath.row];
        
        return cell;
    }
    
    // MARK: Properties
    @IBOutlet var currentStockScrollView: UIScrollView!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var currentStockTableView: UITableView!
    @IBOutlet var indicatorWebView: WKWebView!
    @IBOutlet var indicatorPicker: UIPickerView!
    var stockData: Dictionary<String, Any>!;
    var currentStockTableValues = [String]();
    let indicators = ["Price", "SMA", "EMA", "STOCH", "RSI", "ADX", "CCI", "BBANDS", "MACD"];
    
    // MARK: Actions
    @IBAction func shareOnFacebook(_ sender: Any) {
        print("Share on Facebook");
    }
    
    @IBAction func toggleFavorite(_ sender: Any) {
        print("Toggle Favorite");
    }
    
    @IBAction func changeIndicator(_ sender: Any) {
        print("Change Indicator");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup scroll view
        self.currentStockScrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000);
        
        // Setup table view
        self.currentStockTableView.dataSource = self;
        self.currentStockTableView.delegate = self;
        self.currentStockTableView.isScrollEnabled = false;
        
        // Set up indicator picker
        self.indicatorPicker.dataSource = self;
        self.indicatorPicker.delegate = self;
        self.changeButton.isEnabled = false;
        self.changeButton.setTitleColor(UIColor.lightGray, for: UIControlState.disabled);
        
        // Initialize values for table view
        currentStockTableValues.append((self.stockData["symbol"] as? String)!);
        currentStockTableValues.append(String(format: "%.2f", (self.stockData["last_price"] as? Float)!));
        currentStockTableValues.append(String(format: "%.2f", (self.stockData["change"] as? Float)!) +
            " (" +
            String(format: "%.2f", (self.stockData["change_percent"] as? Float)!) +
            "%)"
        );
        currentStockTableValues.append((self.stockData["timestamp"] as? String)!);
        currentStockTableValues.append(String(format: "%.2f", (self.stockData["open"] as? Float)!));
        currentStockTableValues.append(String(format: "%.2f", (self.stockData["close"] as? Float)!));
        currentStockTableValues.append((self.stockData["range"] as? String)!);
        
        let volume = self.stockData["volume"] as? IntegerLiteralType;
        let numberFormatter = NumberFormatter();
        numberFormatter.numberStyle = NumberFormatter.Style.decimal;
        numberFormatter.locale = Locale(identifier: "en_US");
        currentStockTableValues.append(numberFormatter.string(from: NSNumber(value: volume!))!);
        
        // Setup WKWebView
        self.indicatorWebView.navigationDelegate = self;
        self.indicatorWebView.isMultipleTouchEnabled = false;        
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "current-stock-indicator", ofType: "html")!);
        self.indicatorWebView.loadFileURL(fileURL, allowingReadAccessTo: fileURL);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Current Stock View Controller Will Appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Current Stock View Controller Will Disappear")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CurrentStockViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Executing WK");
        let jsonData = try! JSONSerialization.data(withJSONObject: self.stockData ?? "Error!", options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        self.indicatorWebView.evaluateJavaScript("plotPrice(\(jsonString))") { result, error in
            guard error == nil else {
                print(error!);
                return;
            }
        }
    }
}
