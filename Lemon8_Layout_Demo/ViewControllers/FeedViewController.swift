//
//  FeedViewController.swift
//  Lemon8_Layout_Demo
//
//  单个 tab 的双列瀑布流 feed 页面。
//  B 阶段重构：cell-owned VC 模式。每个 MainCollectionViewCell 持有一个 FeedVC，
//  cell 复用 = VC 复用 = VC 内部 switchTab 切数据。HomeVC 通过 FeedViewControllerDelegate
//  接收 VC 的事件（卡片点击、滚到底、加载完成、加载失败）。
//

import UIKit
import IGListKit

// MARK: - Delegate

protocol FeedViewControllerDelegate: AnyObject {
    func feedViewController(_ vc: FeedViewController, didTapCard card: CardModel)
    func feedViewControllerDidReachBottom(_ vc: FeedViewController)
    func feedViewControllerDidFinishLoading(_ vc: FeedViewController)
    func feedViewController(_ vc: FeedViewController, didFailLoading error: Error)
}

// MARK: - VC

final class FeedViewController: UIViewController {

    // MARK: - UI / IGListKit
    private let waterfall = WaterFall()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterfall)
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)

    // MARK: - Data
    private var items: [CardModel] = []
    /// 当前所属 tab 的标题。由 switchTab 设置；HomeVC 可读用于日志/区分。
    private(set) var tabName: String = ""

    // MARK: - Delegate
    weak var delegate: FeedViewControllerDelegate?

    /// 防止 didReachBottom 在底部附近持续触发——只在「重新接近底部」时发一次。
    private var didFireReachBottom = false

    // MARK: - Init
    init() {
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
        adapter.scrollViewDelegate = self // 监听内部 cv 的滚动以触发 didReachBottom

        // 注意：B 阶段重构后，**不再在 viewDidLoad 里 loadData**。
        // 数据加载由 cell.bind(...) 调 switchTab(...) 触发，确保 tabName 已经设好。
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    // MARK: - Public API

    /// 切换 tab：更新 tabName，重拉数据，刷 UI。
    /// 真正生产代码里这里会先查 Repository（Step 3），没缓存才发请求。
    func switchTab(_ tag: TagModel) {
        tabName = tag.tagTitle
        loadData()
    }

    // MARK: - Private

    private func loadData() {
        // 当前是 mock，不会失败。Step 3 接入真实数据时再处理 error 路径。
        items = MockFeedService.makeCards(tab: tabName, count: 30)
        adapter.performUpdates(animated: false) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.feedViewControllerDidFinishLoading(self)
        }
        // 切 tab 后重置「到底了」状态，让新数据可以重新触发一次 didReachBottom
        didFireReachBottom = false
    }
}

// MARK: - ListAdapterDataSource
extension FeedViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return items
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sc = FeedSectionController()
        sc.delegate = self
        return sc
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

// MARK: - FeedSectionControllerDelegate (转发卡片点击)
extension FeedViewController: FeedSectionControllerDelegate {
    func feedSectionController(_ controller: FeedSectionController, didSelectFeed feed: CardModel) {
        delegate?.feedViewController(self, didTapCard: feed)
    }
}

// MARK: - UIScrollViewDelegate (由 IGListKit 通过 adapter.scrollViewDelegate 转发)
extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.bounds.height
        let contentH = scrollView.contentSize.height
        guard contentH > 0 else { return }

        // 离底部 100pt 内算「到底了」
        let nearBottom = bottomEdge >= contentH - 100
        if nearBottom, !didFireReachBottom {
            didFireReachBottom = true
            delegate?.feedViewControllerDidReachBottom(self)
        } else if !nearBottom {
            didFireReachBottom = false
        }
    }
}
