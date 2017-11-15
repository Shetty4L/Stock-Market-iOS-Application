//
//  HistoricalStockViewController.swift
//  Pods
//
//  Created by Suyash Shetty on 11/14/17.
//

import UIKit
import WebKit

class HistoricalStockViewController: UIViewController {

    @IBOutlet var historicalStockWebView: WKWebView!
    var stockData: Dictionary<String, Any>!;
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set up web view
        self.historicalStockWebView.navigationDelegate = self;
        self.historicalStockWebView.isMultipleTouchEnabled = false;
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "current-stock-indicator", ofType: "html")!);
        self.historicalStockWebView.loadFileURL(fileURL, allowingReadAccessTo: fileURL);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Historical Stock View Controller Will Appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Historical Stock View Controller Will Disappear")
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

extension HistoricalStockViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(self.stockData["symbol"] == nil) {
            let error = "'Failed to load indicator data'";
            self.historicalStockWebView.evaluateJavaScript("displayError(\(error))") { result, error in
                guard error == nil else {
                    print(error!);
                    return;
                }
            }
            return;
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: self.stockData ?? "Error!", options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        self.historicalStockWebView.evaluateJavaScript("plotHistoricData(\(jsonString))") { result, error in
            guard error == nil else {
                print(error!);
                return;
            }
        }
    }
}
