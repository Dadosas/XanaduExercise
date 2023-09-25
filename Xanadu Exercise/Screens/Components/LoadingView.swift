//
//  LoadingView.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 25/09/23.
//

import UIKit
import Combine

class LoadingView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    private var cancellables: [AnyCancellable] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)
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
        
        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
        
        publisher(for: \.isHidden)
            .sink(receiveValue: { [weak activityIndicator] isHidden in
                if isHidden {
                    activityIndicator?.stopAnimating()
                } else {
                    activityIndicator?.startAnimating()
                }
            })
            .store(in: &cancellables)
    }
}
