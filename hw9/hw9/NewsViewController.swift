//
//  NewsViewController.swift
//  Pods
//
//  Created by Suyash Shetty on 11/14/17.
//

import UIKit
import EasyToast

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsTableViewCell", for: indexPath) as? NewsTableViewCell else {
            fatalError("The dequeued cell is not an instance of NewsTableViewCell");
        }
        cell.newsTitleLabel.text = self.newsData[indexPath.row]["title"];
        cell.newsAuthorLabel.text = "Author: " + self.newsData[indexPath.row]["authorName"]!;
        cell.newsDateLabel.text = "Date: " + self.newsData[indexPath.row]["pubDate"]!;
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: self.newsData[indexPath.row]["link"]!);
        UIApplication.shared.open(url!, options: [:], completionHandler: nil);
    }
    
    var newsData = [Dictionary<String, String>]();
    @IBOutlet var newsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set up Table view
        self.newsTableView.dataSource = self;
        self.newsTableView.delegate = self;
        
        // Handle error if news data is not fetch
        initNewsTable();
    }
    
    private func initNewsTable() {
        
        if self.newsData.isEmpty {
            self.view.showToast("Failed to load news. Please try again later", position: .bottom, popTime: 5, dismissOnTap: true);
            self.newsTableView.isHidden = true;
            return;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("News View Controller Will Appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("News View Controller Will Disappear")
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
