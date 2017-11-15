//
//  FavoritesTableViewCell.swift
//  
//
//  Created by Suyash Shetty on 11/13/17.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet var stockNameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var changeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
