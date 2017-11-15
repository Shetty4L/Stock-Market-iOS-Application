//
//  CurrentStockTableViewCell.swift
//  Alamofire
//
//  Created by Suyash Shetty on 11/14/17.
//

import UIKit

class CurrentStockTableViewCell: UITableViewCell {

    @IBOutlet var stockDetailTitle: UILabel!
    @IBOutlet var stockDetailValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
