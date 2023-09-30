//
//  NavigationDrawerViewController.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import UIKit
import Combine

class NavigationDrawerViewController: UIViewController {

    static func instance(viewModel: NavigationDrawerViewModel) -> NavigationDrawerViewController {
        return UIStoryboard(name: "NavigationDrawerViewController", bundle: nil).instantiateInitialViewController { coder in
            NavigationDrawerViewController(coder: coder, viewModel: viewModel)
        }!
    }
    
    private let viewModel: NavigationDrawerViewModel
    private lazy var diffableDataSource = UITableViewDiffableDataSource<Int, NavigationItem>(tableView: tableView) { tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationDrawerTableViewCell.description(), for: indexPath) as! NavigationDrawerTableViewCell
        cell.set(navigationItem: itemIdentifier)
        return cell
    }
    private lazy var tableViewDelegate = NavigationDrawerTableViewDelegate(diffableDataSource: diffableDataSource, navigateTo: { [weak self] selectedNavigationItem in
        guard
            let this = self,
            let navigationController = this.navigationController,
            let eventDetailViewModel = this.viewModel.getEventDetailViewModelIfNavigable(navigationItem: selectedNavigationItem)
        else { return }
        let eventVC = EventDetailViewController.instance(viewModel: eventDetailViewModel)
        navigationController.setViewControllers(navigationController.viewControllers.dropLast() + [eventVC], animated: true)
    })
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: ErrorView!
    @IBOutlet weak var loadingView: LoadingView!
    
    required init?(coder: NSCoder, viewModel: NavigationDrawerViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    @available(*, unavailable, renamed: "init(coder:viewModel:)")
    required init?(coder: NSCoder) {
        fatalError("Invalid init")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(didTapOnCloseBarButtonItem))

        errorView.onRetry = viewModel.retry
        
        tableView.register(UINib(nibName: "NavigationDrawerTableViewCell", bundle: nil), forCellReuseIdentifier: NavigationDrawerTableViewCell.description())
        tableView.allowsSelection = true
        tableView.delegate = tableViewDelegate
        tableView.dataSource = diffableDataSource
        diffableDataSource.apply(NSDiffableDataSourceSnapshot<Int, NavigationItem>(), animatingDifferences: false)
        
        viewModel.publishNavigationDrawerState()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let this = self else { return }
                switch state {
                case .loading:
                    this.tableView.isHidden = true
                    
                    this.loadingView.isHidden = false
                    
                    this.errorView.isHidden = true
                case .loaded(let navigationItems):
                    this.tableView.isHidden = false
                    
                    var oldSnapshot = this.diffableDataSource.snapshot()
                    oldSnapshot.deleteAllItems()
                    oldSnapshot.appendSections([1])
                    oldSnapshot.appendItems(navigationItems, toSection: 1)
                    this.diffableDataSource.apply(oldSnapshot, animatingDifferences: true)
                    
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
    
    @IBAction func didTapOnCloseBarButtonItem() {
        navigationController?.popViewController(animated: true)
    }
}

class NavigationDrawerTableViewDelegate: NSObject, UITableViewDelegate {
    
    private let diffableDataSource: UITableViewDiffableDataSource<Int, NavigationItem>
    private let navigationItemSelected: (NavigationItem) -> Void
    
    init(diffableDataSource: UITableViewDiffableDataSource<Int, NavigationItem>,
         navigateTo: @escaping (NavigationItem) -> Void) {
        self.diffableDataSource = diffableDataSource
        self.navigationItemSelected = navigateTo
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        navigationItemSelected(item)
    }
}
