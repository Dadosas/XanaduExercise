//
//  MarketRowTableViewCell.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit

class MarketRowTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = .zero
    }
    
    func set(name: String) {
        nameLabel.text = name
    }
}
