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
    
    private let viewModel: EventDetailViewModel
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: ErrorView!
    @IBOutlet weak var loadingView: LoadingView!
    
    private lazy var snapshotDataSource = UITableViewDiffableDataSource<Int, EventDetailRow>(tableView: tableView) { tableView, indexPath, itemIdentifier in
        switch itemIdentifier {
        case .event(let event):
            let cell = tableView.dequeueReusableCell(withIdentifier: EventRowTableViewCell.description(), for: indexPath) as! EventRowTableViewCell
            cell.set(event: event)
            return cell
        case .market(let market):
            let cell = tableView.dequeueReusableCell(withIdentifier: MarketRowTableViewCell.description(), for: indexPath) as! MarketRowTableViewCell
            cell.set(market: market)
            return cell
        case .runner(let runner):
            let cell = tableView.dequeueReusableCell(withIdentifier: RunnerRowTableViewCell.description(), for: indexPath) as! RunnerRowTableViewCell
            cell.set(runner: runner)
            return cell
        }
    }
    
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
        
        tableView.dataSource = snapshotDataSource
        snapshotDataSource.apply(NSDiffableDataSourceSnapshot<Int, EventDetailRow>(), animatingDifferences: false)
        
        viewModel.publishEventDetailState()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eventDetailState in
                guard let this = self else { return }
                switch eventDetailState {
                case .loading:
                    this.tableView.isHidden = true
                    
                    this.loadingView.isHidden = false
                    
                    this.errorView.isHidden = true
                case .loaded(let rows):
                    this.tableView.isHidden = false
                    
                    var oldSnaphot = this.snapshotDataSource.snapshot()
                    oldSnaphot.deleteAllItems()
                    oldSnaphot.appendSections([1])
                    oldSnaphot.appendItems(rows, toSection: 1)
                    this.snapshotDataSource.defaultRowAnimation = .fade
                    this.snapshotDataSource.apply(oldSnaphot, animatingDifferences: true)
                    
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
