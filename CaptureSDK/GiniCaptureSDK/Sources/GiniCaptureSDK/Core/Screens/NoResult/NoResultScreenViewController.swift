//
//  NoResultScreenViewController.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final public class NoResultScreenViewController: UIViewController {
    public enum NoResultType {
        case image
        case pdf
        case custom(String)

        var description: String {
            switch self {
            case .pdf:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header.other",
                    comment: "no results header")
            case .image:
                return NSLocalizedStringPreferredFormat(
                    "ginicapture.noresult.header.no.results",
                    comment: "other no result header")
            case .custom(let text):
                return text
            }
        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var enterButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle(NSLocalizedStringPreferredFormat(
                "ginicapture.noresult.enterManually",
                comment: "Enter manually"),
                             for: .normal)
        return button
    }()

    lazy var retakeButton: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = giniConfiguration.textStyleFonts[.bodyBold]
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle(NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.retakeImages",
            comment: "Enter manually"),
                              for: .normal)
        return button
    }()

    lazy var buttonsView: UIStackView = {
        let stackView = UIStackView()
        if viewModel.isEnterManuallyHidden() == false {
            stackView.addArrangedSubview(enterButton)
        }
        if viewModel.isRetakePressedHidden() == false {
            stackView.addArrangedSubview(retakeButton)
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var header: NoResultHeader = {
        
        if let header = NoResultHeader().loadNib() as? NoResultHeader {
            header.headerLabel.adjustsFontForContentSizeCategory = true
            header.headerLabel.adjustsFontSizeToFitWidth = true
            header.translatesAutoresizingMaskIntoConstraints = false
        return header
        }
        fatalError("No result header not found")
    }()

    private (set) var dataSource: HelpDataSource
    private var giniConfiguration: GiniConfiguration
    private let tableRowHeight: CGFloat = 44
    private let sectionHeight: CGFloat = 70
    private let type: NoResultType
    private let viewModel: NoResultScreenViewModel

    public init(
        giniConfiguration: GiniConfiguration,
        type: NoResultType,
        viewModel: NoResultScreenViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.type = type
        switch type {
        case .image:
            let tipsDS = HelpTipsDataSource(configuration: giniConfiguration)
            tipsDS.showHeader = true
            self.dataSource = tipsDS
        case .pdf:
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        case .custom(_):
            self.dataSource = HelpFormatsDataSource(configuration: giniConfiguration)
        }
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonsView.bounds.size.height + GiniMargins.margin, right: 0)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonsView.bounds.size.height + GiniMargins.margin, right: 0)
    }
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonsView.bounds.size.height + GiniMargins.margin, right: 0)
    }
    
    private func setupView() {
        configureMainView()
        configureTableView()
        configureConstraints()
        configureButtons()
        edgesForExtendedLayout = []
    }

    private func configureMainView() {
        title = NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.title",
            comment: "No result screen title")
        header.iconImageView.accessibilityLabel = NSLocalizedStringPreferredFormat(
            "ginicapture.noresult.title",
            comment: "No result screen title")
        header.headerLabel.text = type.description
        header.headerLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        header.headerLabel.textColor = UIColor.GiniCapture.label
        view.backgroundColor = UIColor.GiniCapture.helpBackground
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(buttonsView)
        header.backgroundColor = UIColor.GiniCapture.errorBackground
    }

    private func configureTableView() {
        registerCells()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.estimatedRowHeight = tableRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.sectionHeaderHeight = sectionHeight
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = UIColor.clear
            UITableViewHeaderFooterView.appearance().backgroundConfiguration = bgConfig
        }
    }

    private func registerCells() {
        switch type {
        case .pdf:
            tableView.register(
                UINib(
                    nibName: "HelpFormatCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpFormatCell.reuseIdentifier)
        case .image, .custom(_):
            tableView.register(
                UINib(
                    nibName: "HelpTipCell",
                    bundle: giniCaptureBundle()),
                forCellReuseIdentifier: HelpTipCell.reuseIdentifier)
        }
        tableView.register(
            UINib(
                nibName: "HelpFormatSectionHeader",
                bundle: giniCaptureBundle()),
            forHeaderFooterViewReuseIdentifier: HelpFormatSectionHeader.reuseIdentifier)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
        view.layoutSubviews()
    }

    private func addBlurEffect(button: UIButton, cornerRadius: CGFloat) {
        button.backgroundColor = .clear
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.isUserInteractionEnabled = false
        blurView.backgroundColor = .clear
        if cornerRadius > 0 {
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
        }
        button.insertSubview(blurView, at: 0)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: blurView.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -0).isActive = true
        button.topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true
        if let imageView = button.imageView {
            imageView.backgroundColor = .clear
            button.bringSubviewToFront(imageView)
        }
    }

    
    private func configureButtons() {
        retakeButton.setTitleColor(giniConfiguration.primaryButtonTitleColor, for: .normal)
        retakeButton.backgroundColor = giniConfiguration.primaryButtonBackgroundColor
        retakeButton.layer.borderColor = giniConfiguration.primaryButtonBorderColor.cgColor
        retakeButton.layer.cornerRadius = giniConfiguration.primaryButtonCornerRadius
        retakeButton.layer.borderWidth = giniConfiguration.primaryButtonBorderWidth
        retakeButton.layer.shadowRadius = giniConfiguration.primaryButtonShadowRadius
        retakeButton.layer.shadowColor = giniConfiguration.primaryButtonShadowColor.cgColor
        
        
        enterButton.backgroundColor = giniConfiguration.outlineButtonBackground
        enterButton.layer.cornerRadius = giniConfiguration.outlineButtonCornerRadius
        enterButton.layer.borderWidth = giniConfiguration.outlineButtonBorderWidth
        enterButton.layer.borderColor = giniConfiguration.outlineButtonBorderColor.cgColor
        enterButton.layer.shadowRadius = giniConfiguration.outlineButtonShadowRadius
        enterButton.layer.shadowColor = giniConfiguration.outlineButtonShadowColor.cgColor
        enterButton.setTitleColor(giniConfiguration.outlineButtonTitleColor, for: .normal)
        addBlurEffect(button: enterButton, cornerRadius: 14)
        enterButton.addTarget(viewModel, action: #selector(viewModel.didPressEnterManually), for: .touchUpInside)
        retakeButton.addTarget(viewModel, action: #selector(viewModel.didPressRetake), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: viewModel,
            action: #selector(viewModel.didPressCancell))
    }
    
    private func configureConstraints() {
        header.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        header.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        tableView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.size.height * 0.6),
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),
            
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 13),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -GiniMargins.margin),
            
            buttonsView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -GiniMargins.margin),
            buttonsView.heightAnchor.constraint(greaterThanOrEqualToConstant: 112)
        ])
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonsView.widthAnchor.constraint(equalToConstant: 280)
            ])
            
        } else {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: GiniMargins.margin),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -GiniMargins.margin),
                buttonsView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            ])
        }
        view.layoutSubviews()
    }
}
