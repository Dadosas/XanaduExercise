//
//  EventDetailViewController.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit
import Combine

class EventDetailViewController: UIViewController {

    static func instance(viewModel: EventDetailViewModel) -> EventDetailViewController {
        return UIStoryboard(name: "EventDetailViewController", bundle: nil).instantiateInitialViewController { coder in
            EventDetailViewController(coder: coder, viewModel: viewModel)
        }!
    }
    
    private var viewModel: EventDetailViewModel!
    private let dataSource = EventDetailDataSource()
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var errorView: ErrorView!
    
    @IBOutlet weak var loadingView: LoadingView!
    
    required init?(coder: NSCoder, viewModel: EventDetailViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(coder:viewModel:)")
    required init?(coder: NSCoder) {
        fatalError("Invalid init")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.navigationItem.name
        navigationItem.hidesBackButton = false
        
        errorView.onRetry = viewModel.retry
        
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
                    
                    this.loadingView.isHidden = false
                    
                    this.errorView.isHidden = true
                case .loaded(let rows):
                    this.tableView.isHidden = false
                    this.dataSource.reload(items: rows, tableView: this.tableView)
                    
                    this.loadingView.isHidden = true
                    
                    this.errorView.isHidden = true
                case .error:
                    this.tableView.isHidden = true
                    
                    this.loadingView.isHidden = true
                    
                    this.errorView.isHidden = false
                }
            }
            .store(in: &cancellables)
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
            cell.set(name: name, dateText: dateLabel)
            return cell
        case .market(let name):
            let cell = tableView.dequeueReusableCell(withIdentifier: MarketRowTableViewCell.description(), for: indexPath) as! MarketRowTableViewCell
            cell.set(name: name)
            return cell
        case .runner(let name, let backOddsLabel, let layOddsLabel):
            let cell = tableView.dequeueReusableCell(withIdentifier: RunnerRowTableViewCell.description(), for: indexPath) as! RunnerRowTableViewCell
            cell.set(name: name, backOddsText: backOddsLabel, layOddsText: layOddsLabel)
            return cell
        }
    }
}
