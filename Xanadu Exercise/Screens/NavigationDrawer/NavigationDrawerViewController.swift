//
//  NavigationDrawerViewController.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import UIKit
import Combine

class NavigationDrawerViewController: UIViewController {

    static func instance() -> NavigationDrawerViewController {
        let vc = UIStoryboard(name: "NavigationDrawerViewController", bundle: nil)
            .instantiateInitialViewController() as! NavigationDrawerViewController
        vc.viewModel = NavigationDrawerViewModelImpl(appDependencies: AppDelegate.getAppDependencies())
        return vc
    }
    
    private var viewModel: NavigationDrawerViewModel!
    private var dataSource: NavigationDrawerDataSource!
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var errorContainer: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        dataSource = NavigationDrawerDataSource { [weak self] selectedNavigationItem in
            guard let this = self else { return }
            if this.viewModel.canNavigate(to: selectedNavigationItem) {
                guard let navigationController = this.navigationController else { return }
                let eventVC = EventDetailViewController.instance(navigationItem: selectedNavigationItem)
                navigationController.setViewControllers(navigationController.viewControllers.dropLast() + [eventVC], animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(didTapOnCloseBarButtonItem))

        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
 
        errorLabel.text = "An error has occurred, please retry..."
        retryButton.setTitle("Retry", for: UIControl.State())
        retryButton.addTarget(self, action: #selector(didTapOnRetryButton), for: .touchUpInside)
        
        tableView.register(UINib(nibName: "NavigationDrawerTableViewCell", bundle: nil), forCellReuseIdentifier: NavigationDrawerTableViewCell.description())
        tableView.allowsSelection = true
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        
        viewModel.publishNavigationDrawerState()
            .sink { [weak self] state in
                guard let this = self else { return }
                switch state {
                case .loading:
                    this.tableView.isHidden = true
                    
                    this.loadingContainer.isHidden = false
                    this.activityIndicator.startAnimating()
                    
                    this.errorContainer.isHidden = true
                case .loaded(let navigationItems):
                    this.tableView.isHidden = false
                    this.dataSource.reload(items: navigationItems, tableView: this.tableView)
                    
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
    
    @IBAction func didTapOnCloseBarButtonItem() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnRetryButton() {
        viewModel.retry()
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
