//
//  HelpMenuViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `HelpMenuViewControllerDelegate` protocol defines methods that allow you to handle table item selection actions.
 
 - note: Component API only.
 - TODO:  - REMOVE Componen API
 */

public protocol HelpMenuViewControllerDelegate: AnyObject {
    func help(_ menuViewController: HelpMenuViewController, didSelect item: HelpMenuItem)
}

/**
 The `HelpMenuViewController` provides explanations on how to take better pictures, how to
 use the _Open with_ feature and which formats are supported by the Gini Capture SDK. 
 */

public final class HelpMenuViewController: UIViewController, HelpBottomBarEnabledViewController {

    public weak var delegate: HelpMenuViewControllerDelegate?
    private (set) var dataSource: HelpMenuDataSource
    private let giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    public var navigationBarBottomAdapter: HelpBottomNavigationBarAdapter?
    public var bottomNavigationBar: UIView?
    private var bottomConstraint: NSLayoutConstraint?

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.dataSource = HelpMenuDataSource(configuration: giniConfiguration)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource.delegate = self
        setupView()
    }

    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        edgesForExtendedLayout = []
    }

    private func configureTableView() {
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        tableView.backgroundColor = UIColor.clear
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.register(
            UINib(
                nibName: "HelpMenuCell",
                bundle: giniCaptureBundle()),
            forCellReuseIdentifier: HelpMenuCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = tableRowHeight
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    private func configureMainView() {
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        view.addSubview(tableView)
        title = NSLocalizedStringPreferredFormat("ginicapture.help.menu.title", comment: "Help Import screen title")
        view.layoutSubviews()
        configureBottomNavigationBar(
            configuration: giniConfiguration,
            under: tableView)
    }

    private func configureConstraints() {
        if giniConfiguration.bottomNavigationBarEnabled == false {
            NSLayoutConstraint.activate([tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: GiniMargins.margin)
        ])
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: GiniMargins.iPadAspectScale),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin)
            ])
        }
        view.layoutSubviews()
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - HelpMenuDataSourceDelegate

extension HelpMenuViewController: HelpMenuDataSourceDelegate {
    func didSelectHelpItem(didSelect item: HelpMenuItem) {
        delegate?.help(self, didSelect: item)
    }
}
