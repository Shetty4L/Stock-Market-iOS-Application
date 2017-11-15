//
//  CurrentStockViewController.swift
//  Alamofire
//
//  Created by Suyash Shetty on 11/14/17.
//

import UIKit
import Alamofire
import SwiftMoment
import WebKit
import EasyToast
import FacebookShare
import FBSDKShareKit
import FBSDKLoginKit

class CurrentStockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print(sharer);
        print(results);
        self.view.showToast("Shared succesfully!", position: .bottom, popTime: 5, dismissOnTap: true);
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        self.view.showToast("Share failed!", position: .bottom, popTime: 5, dismissOnTap: true);
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        self.view.showToast("Share cancelled!", position: .bottom, popTime: 5, dismissOnTap: true);
    }
    
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
        if(indicators[row] == self.indicatorType) {
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
        
        if(indexPath.row == 2) {
            if let change = self.stockData["change"] as? Float {
                let attributedString = NSMutableAttributedString(string: self.currentStockTableValues[indexPath.row]);
                let attachment = NSTextAttachment();
                if change > 0 {
                    cell.stockDetailValue.textColor = UIColor.green;
                    attachment.image = UIImage(named: "Up.png");
                    attachment.bounds = CGRect(x: 0.0, y: (cell.stockDetailValue.font.capHeight - (attachment.image?.size.height)!).rounded() / 2, width: attachment.image!.size.width, height: attachment.image!.size.height);
                    attributedString.append(NSAttributedString(attachment: attachment));
                    cell.stockDetailValue.attributedText = attributedString;
                } else if change < 0 {
                    cell.stockDetailValue.textColor = UIColor.red;
                    attachment.image = UIImage(named: "Down.png");
                    attachment.bounds = CGRect(x: 0.0, y: (cell.stockDetailValue.font.capHeight - (attachment.image?.size.height)!).rounded() / 2, width: attachment.image!.size.width, height: attachment.image!.size.height);
                    attributedString.append(NSAttributedString(attachment: attachment));
                    cell.stockDetailValue.attributedText = attributedString;
                } else {
                    cell.stockDetailValue.textColor = UIColor.black;
                }
            }
        } else {
            cell.stockDetailValue.text = self.currentStockTableValues[indexPath.row];
        }
        
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
    @IBOutlet var currentStockActivityIndicator: UIActivityIndicatorView!
    var stockData: Dictionary<String, Any>!;
    var indicatorData: Dictionary<String, Any>!;
    var indicatorType: String = "";
    var currentStockTableValues = ["","","","","","","",""];
    let indicators = ["Price", "SMA", "EMA", "STOCH", "RSI", "ADX", "CCI", "BBANDS", "MACD"];
    let getIndicatorUrl = "http://isydfq.us-west-1.elasticbeanstalk.com/stock/indicator?";
    let shareFacebookUrl = "http://isydfq.us-west-1.elasticbeanstalk.com/share";
    
    // MARK: Actions
    @IBAction func shareOnFacebook(_ sender: Any) {
        print("Share on Facebook");
        let data = [
            "symbol": self.stockData["symbol"] as! String
        ];
        self.currentStockActivityIndicator.startAnimating();
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        self.indicatorWebView.evaluateJavaScript("returnDataForFacebook(\(jsonString))") { result, error in
            guard error == nil else {
                print(error!);
                return;
            }
            if let fbData = result {
                var request = URLRequest(url: URL.init(string: self.shareFacebookUrl)!);
                request.httpBody = try! JSONSerialization.data(withJSONObject: fbData, options: []);
                request.httpMethod = "POST";
                request.setValue("application/json", forHTTPHeaderField: "Content-Type");
                Alamofire.request(request).responseString { response in
                    if let json = response.result.value {
                        let exportUrl = "http://export.highcharts.com/" + json;
                        
                        let content: FBSDKShareLinkContent = FBSDKShareLinkContent();
                        content.contentURL =  URL(string: exportUrl)
                        
                        self.currentStockActivityIndicator.stopAnimating();
                        let dialog : FBSDKShareDialog = FBSDKShareDialog();
                        dialog.delegate = self;
                        dialog.fromViewController = self;
                        dialog.shareContent = content;
                        dialog.mode = FBSDKShareDialogMode.feedBrowser;
                        dialog.show();
                    }
                }
            }
        }
    }
    
    @IBAction func toggleFavorite(_ sender: Any) {
        print("Toggle Favorite");
    }
    
    @IBAction func changeIndicator(_ sender: Any) {
        self.currentStockActivityIndicator.startAnimating();
        let stockSymbol = self.stockData["symbol"] as! String;
        let selectedIndicator = indicators[indicatorPicker.selectedRow(inComponent: 0)];
        self.indicatorType = selectedIndicator;
        self.changeButton.isEnabled = false;
        self.changeButton.setTitleColor(UIColor.lightGray, for: UIControlState.disabled);
        
        if(self.indicatorType == "Price") {
            self.indicatorWebView.reload();
        } else {
            Alamofire.request(getIndicatorUrl + "indicator=" + selectedIndicator + "&stockSymbol=" + stockSymbol).responseJSON { response in
                if let json = response.result.value as? Dictionary<String, Any> {
                    self.indicatorData = json;
                    self.indicatorData["symbol"] = stockSymbol;
                    self.indicatorWebView.reload();
                }
                self.currentStockActivityIndicator.stopAnimating();
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set up acitivity indicator
        self.currentStockActivityIndicator.hidesWhenStopped = true;
        
        // Setup scroll view
        self.currentStockScrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000);
        
        // Setup table view
        self.currentStockTableView.dataSource = self;
        self.currentStockTableView.delegate = self;
        self.currentStockTableView.isScrollEnabled = false;
        self.currentStockTableView.allowsSelection = false;
        
        // Set up indicator picker
        self.indicatorPicker.dataSource = self;
        self.indicatorPicker.delegate = self;
        self.changeButton.isEnabled = false;
        self.changeButton.setTitleColor(UIColor.lightGray, for: UIControlState.disabled);
        
        // Initialize values for table view
        initStockTableValues();
        
        // Setup WKWebView
        self.indicatorType = "Price";
        self.facebookButton.isEnabled = false;
        self.currentStockActivityIndicator.startAnimating();
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
    
    private func dataLoadFailureToast() {
        self.view.showToast("Failed to load data. Please try again later", position: .bottom, popTime: 5, dismissOnTap: true);
    }
    
    private func initStockTableValues() {
        guard let stockName = self.stockData["symbol"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let last_price = self.stockData["last_price"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let change = self.stockData["change"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let change_percent = self.stockData["change_percent"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let timestamp = self.stockData["timestamp"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let open = self.stockData["open"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let close = self.stockData["close"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let range = self.stockData["range"] else {
            dataLoadFailureToast();
            return;
        }
        
        guard let volume = self.stockData["volume"] else {
            dataLoadFailureToast();
            return;
        }
        
        currentStockTableValues[0] = stockName as! String;
        currentStockTableValues[1] = String(format: "%.2f", last_price as! Float);
        currentStockTableValues[2] = String(format: "%.2f", change as! Float) + " (" + String(format: "%.2f", change_percent as! Float) + "%)";
        currentStockTableValues[3] = timestamp as! String;
        currentStockTableValues[4] = String(format: "%.2f", open as! Float);
        currentStockTableValues[5] = String(format: "%.2f", close as! Float);
        currentStockTableValues[6] = range as! String;
        
        let numberFormatter = NumberFormatter();
        numberFormatter.numberStyle = NumberFormatter.Style.decimal;
        numberFormatter.locale = Locale(identifier: "en_US");
        currentStockTableValues[7] = numberFormatter.string(from: NSNumber(value: volume as! IntegerLiteralType))!;
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
        self.facebookButton.isEnabled = true;
        self.currentStockActivityIndicator.stopAnimating();
        if(self.stockData["symbol"] == nil) {
            let error = "'Failed to load indicator data'";
            self.indicatorWebView.evaluateJavaScript("displayError(\(error))") { result, error in
                guard error == nil else {
                    print(error!);
                    return;
                }
            }
            return;
        }
        
        if self.indicatorType == "Price" {
            let jsonData = try! JSONSerialization.data(withJSONObject: self.stockData ?? "Error!", options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            self.indicatorWebView.evaluateJavaScript("plotPrice(\(jsonString))") { result, error in
                guard error == nil else {
                    print(error!);
                    return;
                }
            }
        } else {
            let jsonData = try! JSONSerialization.data(withJSONObject: self.indicatorData ?? "Error!", options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            self.indicatorWebView.evaluateJavaScript("plotIndicator(\(jsonString))") { result, error in
                guard error == nil else {
                    print(error!);
                    return;
                }
            }
        }
    }
}
