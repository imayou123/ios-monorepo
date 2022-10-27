//
//  OnboardingViewController.swift
//  GiniCaptureSDK
//
//  Created by Nadya Karaban on 07.06.22.
//

import Foundation
import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pagesCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var viewContainer: UIStackView!
    private (set) var dataSource: OnboardingDataSource
    private let configuration = GiniConfiguration.shared
    private var navigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

    lazy var skipButton = UIBarButtonItem(title: "Skip",
                                          style: .plain,
                              target: self,
                              action: #selector(close))
    init() {
        dataSource = OnboardingDataSource(configuration: configuration)
        super.init(nibName: "OnboardingViewController", bundle: giniCaptureBundle())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCollectionView() {
        pagesCollection.register(
            UINib(nibName: "OnboardingPageCell", bundle: giniCaptureBundle()),
            forCellWithReuseIdentifier: OnboardingPageCell.reuseIdentifier)
        pagesCollection.setNeedsLayout()
        pagesCollection.layoutIfNeeded()
        pagesCollection.reloadData()
        pagesCollection.isPagingEnabled = true
        pagesCollection.showsHorizontalScrollIndicator = false
        pagesCollection.dataSource = dataSource
        pagesCollection.delegate = dataSource
        dataSource.delegate = self
    }

    private func configurePageControl() {
        pageControl.pageIndicatorTintColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor().withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        pageControl.addTarget(
            self,
            action: #selector(self.pageControlSelectionAction(_:)),
            for: .valueChanged)
        pageControl.numberOfPages = dataSource.itemSections.count
    }

    private func setupView() {
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        configureCollectionView()
        if configuration.bottomNavigationBarEnabled {
            configureBottomNavigation()
        } else {
            configureBasicNavigation()
        }
        configurePageControl()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 46),
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: navigationBar.frame.height),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureBasicNavigation() {
        nextButton.layer.cornerRadius = 14
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.accent1,
            dark: UIColor.GiniCapture.accent1
        ).uiColor()
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        navigationItem.rightBarButtonItem = skipButton
    }

    private func hideTopNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func configureBottomNavigation() {
        hideTopNavigation()
        removeButtons()
        if let customBottomNavigationBar = configuration.onboardingNavigationBarBottomAdapter {
            navigationBarBottomAdapter = customBottomNavigationBar
        } else {
            navigationBarBottomAdapter = DefaultOnboardingNavigationBarBottomAdapter()
        }
        navigationBarBottomAdapter?.setNextButtonClickedActionCallback { [weak self] in
            self?.nextPage()
        }
        navigationBarBottomAdapter?.setSkipButtonClickedActionCallback { [weak self] in
            self?.close()
        }
        navigationBarBottomAdapter?.setGetStartedButtonClickedActionCallback { [weak self] in
            self?.close()
        }
        if let navigationBar = navigationBarBottomAdapter?.injectedView() {
            bottomNavigationBar = navigationBar
            view.addSubview(navigationBar)
            layoutBottomNavigationBar(navigationBar)
            navigationBarBottomAdapter?.showButtons(
                navigationButtons: [.skip, .next],
                navigationBar: navigationBar)
        }
    }

    private func removeButtons() {
        nextButton.removeFromSuperview()
        containerView.removeArrangedSubview(nextButton)
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func pageControlSelectionAction(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }

    @objc private func nextPage() {
        if dataSource.currentPage < dataSource.itemSections.count - 1 {
            let index = IndexPath(item: dataSource.currentPage + 1, section: 0)
            pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        } else {
            close()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if #available(iOS 13, *) {
            view.layoutSubviews()
        } else {
            let offsetX = CGFloat(max(dataSource.currentPage, 0)) * (size.width)
            coordinator.animate(
                    alongsideTransition: { _ in self.pagesCollection.collectionViewLayout.invalidateLayout()
                    },
                    completion: { _ in
                    self.pagesCollection.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                        self.pagesCollection.reloadData()
                }
            )
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pagesCollection.collectionViewLayout.invalidateLayout()
    }

    deinit {
        navigationBarBottomAdapter?.onDeinit()
    }
}

extension OnboardingViewController: OnboardingScreen {
    func didScroll(page: Int) {
        switch page {
        case dataSource.itemSections.count - 1:
            if configuration.bottomNavigationBarEnabled,
                let bottomNavigationBar = bottomNavigationBar {
                navigationBarBottomAdapter?.showButtons(
                    navigationButtons: [.getStarted],
                    navigationBar: bottomNavigationBar)
            } else {
                navigationItem.rightBarButtonItem = nil
                if nextButton != nil {
                    nextButton.setTitle("Get Started", for: .normal)
                }
            }
        default:
            if configuration.bottomNavigationBarEnabled,
                let bottomNavigationBar = bottomNavigationBar {
                navigationBarBottomAdapter?.showButtons(
                    navigationButtons: [.skip, .next],
                    navigationBar: bottomNavigationBar)
            } else {
                navigationItem.rightBarButtonItem = skipButton
                if nextButton != nil {
                    nextButton.setTitle("Next", for: .normal)
                }
            }
        }

        pageControl.currentPage = page
    }
}

class CollectionFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return true
    }
}
