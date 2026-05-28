//
//  FeedViewController.swift
//  Lemon8_Layout_Demo
//
//  单个 tab 的双列瀑布流 feed 页面。
//  第一步：用 IGListKit + WaterFall + Mock 数据跑通单 tab。
//

import UIKit
import IGListKit

final class FeedViewController: UIViewController {

    // MARK: - UI / IGListKit
    private let waterfall = WaterFall()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterfall)
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)

    // MARK: - Data
    private var items: [CardModel] = []
    private let tabName: String

    // MARK: - Init
    init(tabName: String = "推荐") {
        self.tabName = tabName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        waterfall.delegate = self
        waterfall.column = 2

        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)

        adapter.collectionView = collectionView
        adapter.dataSource = self

        loadMockData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    private func loadMockData() {
        items = MockFeedService.makeCards(tab: tabName, count: 30)
        adapter.performUpdates(animated: false)
    }
}

// MARK: - ListAdapterDataSource
extension FeedViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return items
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return FeedSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

// MARK: - WaterFallDelegate
extension FeedViewController: WaterFallDelegate {
    func waterfallLayout(_ layout: WaterFall, heightForItemAt indexPath: IndexPath) -> CGFloat {
        // IGListKit 一个对象一个 section，所以卡片下标 = section
        guard indexPath.section < items.count else { return 200 }
        let card = items[indexPath.section]

        let columnWidth = (collectionView.bounds.width - 24) / 2 // 8 + 8 + 8
        let imageHeight = columnWidth * card.imageAspectRatio
        return imageHeight + 56 // 标题约 36 + 底部约 20
    }
}
