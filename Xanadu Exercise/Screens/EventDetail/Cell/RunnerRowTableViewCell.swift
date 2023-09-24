//
//  RunnerRowTableViewCell.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit

class RunnerRowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backOddsLabel: UILabel!
    @IBOutlet weak var layOddsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separatorInset = .zero
        
        backOddsLabel.backgroundColor = UIColor.systemBlue
        backOddsLabel.textColor = UIColor.white
        backOddsLabel.textAlignment = .center
        
        layOddsLabel.backgroundColor = UIColor.systemRed
        layOddsLabel.textColor = UIColor.white
        layOddsLabel.textAlignment = .center
    }
    
    func set(name: String,
             backOddsLabel: String,
             layOddsLabel: String) {
        nameLabel.text = name
        self.backOddsLabel.text = backOddsLabel
        self.layOddsLabel.text = layOddsLabel
    }
}
