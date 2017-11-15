//
//  StockDetailsViewController.swift
//  Alamofire
//
//  Created by Suyash Shetty on 11/13/17.
//

import UIKit
import Alamofire
import SwiftSpinner

class StockDetailsViewController: UIViewController {
    
    // MARK: Properties
    var stockSymbol: String = "";
    var stockData: Dictionary<String, Any>!;
    var newsData = [Dictionary<String, String>]();
    let getStockQuoteUrl = "http://isydfq.us-west-1.elasticbeanstalk.com/stock?";
    let getNewsUrl = "http://isydfq.us-west-1.elasticbeanstalk.com/news/";
    @IBOutlet var stockDetailsSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.            
        
        // Fetch Stock Data
        SwiftSpinner.show("Loading data");
        Alamofire.request(getStockQuoteUrl + "outputsize=full&stockSymbol=" + stockSymbol).responseJSON { response in
            if let json = response.result.value as? Dictionary<String, Any> {
                self.stockData = json;
                if let stockSymbol = self.stockData["symbol"] {
                    self.navigationItem.title = stockSymbol as? String;
                } else {
                    self.navigationItem.title = "ERROR";
                }
            }
            SwiftSpinner.hide();
            // Setup Segmented Control
            self.setupSegmentedControl();
            self.updateView();
        }
        
        // Fetch News Data
        Alamofire.request(getNewsUrl + stockSymbol).responseJSON { response in
            if let json = response.result.value as? [Dictionary<String, String>] {
                self.newsData = json;
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupSegmentedControl() {
//        self.stockDetailsSegmentedControl.removeAllSegments();
//        self.stockDetailsSegmentedControl.insertSegment(withTitle: "Current", at: 0, animated: false);
//        self.stockDetailsSegmentedControl.insertSegment(withTitle: "Historical", at: 1, animated: false);
//        self.stockDetailsSegmentedControl.insertSegment(withTitle: "News", at: 2, animated: false);
        self.stockDetailsSegmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged);
        
        self.stockDetailsSegmentedControl.selectedSegmentIndex = 0;
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView();
    }
    
    private lazy var currentStockViewController: CurrentStockViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "CurrentStockViewController") as! CurrentStockViewController;
        viewController.stockData = self.stockData;
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController);
        
        return viewController;
    }()
    
    private lazy var historicalStockViewController: HistoricalStockViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "HistoricalStockViewController") as! HistoricalStockViewController;
        viewController.stockData = self.stockData;
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController);
        
        return viewController;
    }()
    
    private lazy var newsViewController: NewsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController;
        viewController.newsData = self.newsData;
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController);
        
        return viewController;
    }()
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController);
        
        // Add Child View as Subview
        view.addSubview(viewController.view);
        
        // Configure Child View
        let y = self.stockDetailsSegmentedControl.frame.minY + self.stockDetailsSegmentedControl.frame.height;
        viewController.view.frame = CGRect(x:0, y: y, width:view.frame.size.width, height:view.frame.size.height-y);
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil);
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview();
        
        // Notify Child View Controller
        viewController.removeFromParentViewController();
    }
    
    private func updateView() {
        switch stockDetailsSegmentedControl.selectedSegmentIndex {
        case 0:
            remove(asChildViewController: historicalStockViewController);
            remove(asChildViewController: newsViewController);
            add(asChildViewController: currentStockViewController)
            break;
        case 1:
            remove(asChildViewController: currentStockViewController);
            remove(asChildViewController: newsViewController);
            add(asChildViewController: historicalStockViewController)
            break;
        case 2:
            remove(asChildViewController: historicalStockViewController);
            remove(asChildViewController: currentStockViewController);
            add(asChildViewController: newsViewController)
            break;
        default: print("Default case executed in updateView()");
        }
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
