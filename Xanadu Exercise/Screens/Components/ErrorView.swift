//
//  ErrorView.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 25/09/23.
//

import UIKit
import Combine

class ErrorView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    var onRetry: () -> Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = self.frame
        self.addSubview(contentView)

        let constraints = [
            self.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        self.addConstraints(constraints)
        constraints.forEach { $0.isActive = true }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        errorLabel.text = "An error has occurred, please retry..."
        retryButton.setTitle("Retry", for: UIControl.State())
        retryButton.addTarget(self, action: #selector(didTapOnRetryButton), for: .touchUpInside)
    }
    
    @IBAction func didTapOnRetryButton() {
        onRetry()
    }
}
