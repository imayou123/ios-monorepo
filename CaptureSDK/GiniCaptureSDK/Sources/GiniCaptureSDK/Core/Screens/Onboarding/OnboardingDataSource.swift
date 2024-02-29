//
//  OnboardingPagesDataSource.swift
//  
//
//  Created by Nadya Karaban on 14.09.22.
//

import UIKit

protocol BaseCollectionViewDataSource: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    init(
        configuration: GiniConfiguration
    )
}

class OnboardingDataSource: NSObject, BaseCollectionViewDataSource {

    typealias OnboardingPageModel = (page: OnboardingPage, illustrationAdapter: OnboardingIllustrationAdapter?)
    private let giniConfiguration: GiniConfiguration
    var currentPageIndex = 0

    lazy var pageModels: [OnboardingPageModel] = {
        if let customPages = giniConfiguration.customOnboardingPages {
            return customPages.map { page in
                return (page: page, illustrationAdapter: nil)
            }
        } else {
            return defaultOnboardingPagesDataSource()
        }
    }()

    required init(configuration: GiniConfiguration) {
        giniConfiguration = configuration
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageModels.count
    }

    private func configureCell(cell: OnboardingPageCell, indexPath: IndexPath) {
        let pageModel = pageModels[indexPath.row]

        if giniConfiguration.customOnboardingPages == nil {
            if let adapter = pageModel.illustrationAdapter {
                cell.iconView.illustrationAdapter = adapter
                cell.iconView.setupView()
            } else {
                cell.iconView.icon = UIImageNamedPreferred(named: pageModel.page.imageName)
            }
        } else {
            cell.iconView.icon = UIImageNamedPreferred(named: pageModel.page.imageName)
        }
        cell.iconView.accessibilityValue = pageModel.page.title

        cell.descriptionLabel.text = pageModel.page.description
        cell.descriptionLabel.accessibilityValue = pageModel.page.description
        cell.titleLabel.text = pageModel.page.title
        cell.titleLabel.accessibilityValue = pageModel.page.title
    }

    private func defaultOnboardingPagesDataSource() -> [OnboardingPageModel] {
        var pageModels = [OnboardingPageModel]()
        var flatPaperPage = OnboardingPage(imageName: DefaultOnboardingPage.flatPaper.imageName,
                                           title: DefaultOnboardingPage.flatPaper.title,
                                           description: DefaultOnboardingPage.flatPaper.description)
        flatPaperPage.analyticsScreenName = DefaultOnboardingPage.flatPaper.screenName
        let flatPaperPageModel = (page: flatPaperPage,
                                  illustrationAdapter: giniConfiguration.onboardingAlignCornersIllustrationAdapter)

        var goodLightingPage = OnboardingPage(imageName: DefaultOnboardingPage.lighting.imageName,
                                              title: DefaultOnboardingPage.lighting.title,
                                              description: DefaultOnboardingPage.lighting.description)
        goodLightingPage.analyticsScreenName = DefaultOnboardingPage.lighting.screenName

        let goodLightingPageModel = (page: goodLightingPage,
                                     illustrationAdapter: giniConfiguration.onboardingLightingIllustrationAdapter)

        pageModels = [flatPaperPageModel, goodLightingPageModel]

        if giniConfiguration.multipageEnabled {
            var multiPage = OnboardingPage(imageName: DefaultOnboardingPage.multipage.imageName,
                                           title: DefaultOnboardingPage.multipage.title,
                                           description: DefaultOnboardingPage.multipage.description)
            multiPage.analyticsScreenName = DefaultOnboardingPage.multipage.screenName

            let multiPageModel = (page: multiPage,
                                  illustrationAdapter: giniConfiguration.onboardingMultiPageIllustrationAdapter)
            pageModels.append(multiPageModel)
        }

        if giniConfiguration.qrCodeScanningEnabled {
            var qrCodePage = OnboardingPage(imageName: DefaultOnboardingPage.qrcode.imageName,
                                            title: DefaultOnboardingPage.qrcode.title,
                                            description: DefaultOnboardingPage.qrcode.description)
            qrCodePage.analyticsScreenName = DefaultOnboardingPage.qrcode.screenName
            let qrCodePageModel = (page: qrCodePage,
                                   illustrationAdapter: giniConfiguration.onboardingQRCodeIllustrationAdapter)
            pageModels.append(qrCodePageModel)
        }

        return pageModels
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingPageCell.reuseIdentifier,
            for: indexPath) as? OnboardingPageCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError("OnboardingPageCell wasn't initialized")
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let pageModel = pageModels[indexPath.row]
        if let adapter = pageModel.illustrationAdapter {
            adapter.pageDidAppear()
        }
    }

    func collectionView( _ collectionView: UICollectionView,
                         didEndDisplaying cell: UICollectionViewCell,
                         forItemAt indexPath: IndexPath) {
        let pageModel = pageModels[indexPath.row]
        if let adapter = pageModel.illustrationAdapter {
            adapter.pageDidDisappear()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let index = IndexPath(row: currentPageIndex, section: 0)
        let attr = collectionView.layoutAttributesForItem(at: index)
        return attr?.frame.origin ?? CGPoint.zero
    }
}
