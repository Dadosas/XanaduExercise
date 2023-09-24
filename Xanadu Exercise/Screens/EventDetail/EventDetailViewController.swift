//
//  EventDetailViewController.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit
import Combine

class EventDetailViewController: UIViewController {

    static func instance(navigationItem: NavigationItem) -> EventDetailViewController {
        let vc = UIStoryboard(name: "EventDetailViewController", bundle: nil)
            .instantiateInitialViewController() as! EventDetailViewController
        vc.viewModel = EventDetailViewModelImpl(navigationItem: navigationItem, appDependencies: AppDelegate.getAppDependencies())
        return vc
    }
    
    private var viewModel: EventDetailViewModel!
    private let dataSource = EventDetailDataSource()
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var errorContainer: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.navigationItem.name
        navigationItem.hidesBackButton = false
        
        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
 
        errorLabel.text = "An error has occurred, please retry..."
        retryButton.setTitle("Retry", for: UIControl.State())
        retryButton.addTarget(self, action: #selector(didTapOnRetryButton), for: .touchUpInside)
        
        tableView.register(UINib(nibName: "EventRowTableViewCell", bundle: nil), forCellReuseIdentifier: EventRowTableViewCell.description())
        tableView.register(UINib(nibName: "MarketRowTableViewCell", bundle: nil), forCellReuseIdentifier: MarketRowTableViewCell.description())
        tableView.register(UINib(nibName: "RunnerRowTableViewCell", bundle: nil), forCellReuseIdentifier: RunnerRowTableViewCell.description())
        tableView.allowsSelection = false
        tableView.dataSource = dataSource
        
        viewModel.publishEventDetailState()
            .sink { [weak self] eventDetailState in
                guard let this = self else { return }
                switch eventDetailState {
                case .loading:
                    this.tableView.isHidden = true
                    
                    this.loadingContainer.isHidden = false
                    this.activityIndicator.startAnimating()
                    
                    this.errorContainer.isHidden = true
                case .loaded(let rows):
                    this.tableView.isHidden = false
                    this.dataSource.reload(items: rows, tableView: this.tableView)
                    
                    this.loadingContainer.isHidden = true
                    this.activityIndicator.stopAnimating()
                    
                    this.errorContainer.isHidden = true
                case .error:
                    this.tableView.isHidden = true
                    
                    this.loadingContainer.isHidden = true
                    this.activityIndicator.stopAnimating()
                    
                    this.errorContainer.isHidden = false
                }
            }
            .store(in: &cancellables)
    }
    
    @IBAction func didTapOnRetryButton() {
        viewModel.retry()
    }
}

class EventDetailDataSource: NSObject, UITableViewDataSource {
    
    private var items: [EventDetailRow] = []
    
    func reload(items: [EventDetailRow], tableView: UITableView) {
        self.items = items
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item {
        case .event(let name, let dateLabel):
            let cell = tableView.dequeueReusableCell(withIdentifier: EventRowTableViewCell.description(), for: indexPath) as! EventRowTableViewCell
            cell.set(name: name, dateLabel: dateLabel)
            return cell
        case .market(let name):
            let cell = tableView.dequeueReusableCell(withIdentifier: MarketRowTableViewCell.description(), for: indexPath) as! MarketRowTableViewCell
            cell.set(name: name)
            return cell
        case .runner(let name, let backOddsLabel, let layOddsLabel):
            let cell = tableView.dequeueReusableCell(withIdentifier: RunnerRowTableViewCell.description(), for: indexPath) as! RunnerRowTableViewCell
            cell.set(name: name, backOddsLabel: backOddsLabel, layOddsLabel: layOddsLabel)
            return cell
        }
    }
}
