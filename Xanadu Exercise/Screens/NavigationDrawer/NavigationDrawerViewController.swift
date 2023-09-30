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
    private lazy var dataSource = NavigationDrawerDataSource { [weak self] selectedNavigationItem in
        guard
            let this = self,
            let navigationController = this.navigationController,
            let eventDetailViewModel = this.viewModel.getEventDetailViewModelIfNavigable(navigationItem: selectedNavigationItem)
        else { return }
        let eventVC = EventDetailViewController.instance(viewModel: eventDetailViewModel)
        navigationController.setViewControllers(navigationController.viewControllers.dropLast() + [eventVC], animated: true)
    }
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
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        
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
                    this.dataSource.reload(items: navigationItems, tableView: this.tableView)
                    
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

class NavigationDrawerDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var items: [NavigationItem] = []
    private let navigationItemSelected: (NavigationItem) -> Void
    
    init(navigateTo: @escaping (NavigationItem) -> Void) {
        self.navigationItemSelected = navigateTo
    }
    
    func reload(items: [NavigationItem], tableView: UITableView) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationDrawerTableViewCell.description(), for: indexPath) as! NavigationDrawerTableViewCell
        cell.set(navigationItem: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        navigationItemSelected(item)
    }
}
