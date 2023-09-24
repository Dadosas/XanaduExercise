//
//  NavigationDrawerTableViewCell.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import UIKit

class NavigationDrawerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameLabelLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = .zero
    }
    
    func set(navigationItem: NavigationItem) {
        nameLabel.text = navigationItem.name
        nameLabelLeadingConstraint.constant = CGFloat(12 * navigationItem.getDepth())
    }
}
