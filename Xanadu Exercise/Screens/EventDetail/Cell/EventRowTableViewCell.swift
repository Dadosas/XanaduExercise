//
//  EventRowTableViewCell.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit

class EventRowTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = .zero
    }
    
    func set(name: String, dateText: String) {
        nameLabel.text = name
        self.dateLabel.text = dateText
    }
    
    func set(event: EventDetailRow.Event) {
        self.set(name: event.name, dateText: event.dateText)
    }
}
