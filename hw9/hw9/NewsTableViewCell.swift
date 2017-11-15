//
//  NewsTableViewCell.swift
//  Pods
//
//  Created by Suyash Shetty on 11/14/17.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet var newsTitleLabel: UILabel!
    @IBOutlet var newsAuthorLabel: UILabel!
    @IBOutlet var newsDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
