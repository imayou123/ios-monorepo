//
//  OnboardingViewController.swift
//  GiniCaptureSDK
//
//  Created by Nadya Karaban on 07.06.22.
//

import UIKit
import Combine

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pagesCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: MultilineTitleButton!
    private (set) var dataSource: OnboardingDataSource
    private let configuration = GiniConfiguration.shared
    private var navigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

    lazy var skipButton = UIBarButtonItem(title: NSLocalizedStringPreferredFormat("ginicapture.onboarding.skip",
                                                                                  comment: "Skip button"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(skipTapped))

    private let pageTracker = PageTracker()
    private var cancellables = Set<AnyCancellable>()

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
        pagesCollection.isPagingEnabled = true
        pagesCollection.showsHorizontalScrollIndicator = false
        pagesCollection.dataSource = dataSource
        pagesCollection.delegate = self
    }

    private func configurePageControl() {
        pageControl.pageIndicatorTintColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                       dark: UIColor.GiniCapture.light1
                                                      ).uiColor().withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = GiniColor(light: UIColor.GiniCapture.dark1,
                                                              dark: UIColor.GiniCapture.light1
                                                             ).uiColor()
        pageControl.addTarget(self, action: #selector(self.pageControlSelectionAction(_:)), for: .valueChanged)
        pageControl.numberOfPages = dataSource.pageModels.count
        pageControl.isAccessibilityElement = true
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

        // Subscribe to contentOffset changes
        /* Use the debounce(for:scheduler:options:) operator to control the number of values and time between delivery of values from the upstream publisher.
         This operator is useful to process bursty or high-volume event streams where you need to reduce the number of values delivered
         to the downstream to a rate you specify.
         */
        pagesCollection?
//            .publisher(for: \.contentOffset, options: .new)
            .publisher(for: \.contentOffset)
            .eraseToAnyPublisher()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main) // Debounce contentOffset changes
            .sink { [weak self] contentOffset in
                guard let self = self else { return }
                let page = Int(round(contentOffset.x / self.pagesCollection.bounds.width))

                self.didScroll(page: page)
            }
            .store(in: &cancellables)
    }

    func trackEventForPage(_ pageIndex: Int) {
        guard let nextPageScreenName = dataSource.pageModels[pageIndex].page.analyticsScreenName else { return }
        AnalyticsManager.trackScreenShown(screenName: nextPageScreenName)
        print("DEBUG - trackEventForPage =", nextPageScreenName)
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 46),
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: navigationBar.frame.height),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureBasicNavigation() {
        nextButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        nextButton.accessibilityValue = NSLocalizedStringPreferredFormat("ginicapture.onboarding.next",
                                                                         comment: "Next button")
        nextButton.configure(with: GiniConfiguration.shared.primaryButtonConfiguration)
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
            navigationBarBottomAdapter?.showButtons(navigationButtons: [.skip, .next], navigationBar: navigationBar)

            nextButton.setTitle(NSLocalizedStringPreferredFormat( "ginicapture.onboarding.next",
                                                                  comment: "Next button"),
                                for: .normal)

            nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
            navigationItem.rightBarButtonItem = skipButton
        }
    }

    private func removeButtons() {
        nextButton.removeFromSuperview()
    }

    @objc private func skipTapped() {
        if let currentPageScreenName = dataSource.pageModels[dataSource.currentPageIndex].page.analyticsScreenName {
            AnalyticsManager.track(event: "skip_tapped", screenName: currentPageScreenName)
        }
        close()
    }

    private func close() {
        dismiss(animated: true)
    }

    @objc private func pageControlSelectionAction(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }

    @objc private func nextPage() {
        if dataSource.currentPageIndex < dataSource.pageModels.count - 1 {
            // Next  button tapped
            if let currentPageScreenName = dataSource.pageModels[dataSource.currentPageIndex].page.analyticsScreenName {
                AnalyticsManager.track(event: "next_step_tapped", screenName: currentPageScreenName)

            }
            let index = IndexPath(item: dataSource.currentPageIndex + 1, section: 0)
            pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        } else {
            // Get started button tapped
            if let currentPageScreenName = dataSource.pageModels[dataSource.currentPageIndex].page.analyticsScreenName {
                AnalyticsManager.track(event: "get_started_tapped", screenName: currentPageScreenName)
            }
            close()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        pagesCollection.collectionViewLayout.invalidateLayout()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pagesCollection.collectionViewLayout.invalidateLayout()
    }

    deinit {
        navigationBarBottomAdapter?.onDeinit()
    }
}

extension OnboardingViewController {
    func didScroll(page: Int) {
        dataSource.currentPageIndex = page
        if pagesCollection.indexPathsForVisibleItems.count == 1 && pageTracker.trackPage(page) {
            trackEventForPage(page)
        }
        switch page {
        case dataSource.pageModels.count - 1:
            if configuration.bottomNavigationBarEnabled,
               let bottomNavigationBar = bottomNavigationBar {
                navigationBarBottomAdapter?.showButtons(navigationButtons: [.getStarted],
                                                        navigationBar: bottomNavigationBar)
            } else {
                navigationItem.rightBarButtonItem = nil
                if nextButton != nil {
                    let nextButtonLocalizedString = "ginicapture.onboarding.getstarted"
                    nextButton.setTitle(NSLocalizedStringPreferredFormat(nextButtonLocalizedString,
                                                                         comment: "Get Started button"), 
                                        for: .normal)
                    nextButton.accessibilityValue = NSLocalizedStringPreferredFormat(nextButtonLocalizedString,
                                                                                     comment: "Get Started button")
                }
            }
        default:
            if configuration.bottomNavigationBarEnabled,
               let bottomNavigationBar = bottomNavigationBar {
                navigationBarBottomAdapter?.showButtons(navigationButtons: [.skip, .next],
                                                        navigationBar: bottomNavigationBar)
            } else {
                navigationItem.rightBarButtonItem = skipButton
                if nextButton != nil {
                    nextButton.setTitle(NSLocalizedStringPreferredFormat("ginicapture.onboarding.next",
                                                                         comment: "Next button"),
                                        for: .normal)
                }
            }
        }
        pageControl.currentPage = page
    }
}

class CollectionFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class PageTracker {
    private var seenPages = Set<Int>()

    func trackPage(_ pageIndex: Int) -> Bool {
        if seenPages.contains(pageIndex) {
            // Page already seen
            print("DEBUG ---- Page already seen")
            return false
        } else {
            // Track the page
            print("DEBUG ---- Track the page")
            seenPages.insert(pageIndex)
            return true
        }
    }

    func resetPage(_ pageIndex: Int) {
        seenPages.remove(pageIndex)
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let visiblePageIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        // adauga logica daca contentOffset a fost
        pageTracker.resetPage(visiblePageIndex)
    }
}
