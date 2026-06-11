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
    private let refreshControl = UIRefreshControl()

    /// 全屏 loading 容器（白底覆盖整个 view），里面装一个居中菊花。
    /// 在 first-load（switchTab 入口）期间盖在 cv 之上，数据回来后 hide。
    private let loadingContainer = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    /// 模拟网络往返延迟。refresh 和 switchTab 共用，体感一致。
    private static let simulatedNetworkLatency: TimeInterval = 0.5

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

        // 下拉刷新
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        // 全屏 loading overlay
        loadingContainer.backgroundColor = .white
        loadingContainer.isHidden = true
        view.addSubview(loadingContainer) // 注意 z-order 自然在 cv 之上

        loadingIndicator.color = .gray
        loadingIndicator.hidesWhenStopped = true
        loadingContainer.addSubview(loadingIndicator)

        // 注意：B 阶段重构后，**不再在 viewDidLoad 里 loadData**。
        // 数据加载由 cell.bind(...) 调 switchTab(...) 触发，确保 tabName 已经设好。
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        loadingContainer.frame = view.bounds
        loadingIndicator.center = CGPoint(x: loadingContainer.bounds.midX,
                                          y: loadingContainer.bounds.midY)
    }

    // MARK: - Public API

    /// 切换 tab：更新 tabName，重拉数据，刷 UI。
    /// 真正生产代码里这里会先查 Repository（Step 3），没缓存才发请求。
    func switchTab(_ tag: TagModel) {
        tabName = tag.tagTitle
        loadData()
    }

    // MARK: - Private

    /// First-load（switchTab 入口触发）：异步 0.5s 后拿数据。期间显示全屏 loading。
    private func loadData() {
        let originalTab = tabName

        // 1. 立刻清空当前列表（旧 tab 的数据残留不应该在新 tab 上显示）
        items = []
        adapter.performUpdates(animated: false)

        // 2. 显示全屏 loading overlay
        showLoading()

        // 3. 异步模拟网络
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.simulatedNetworkLatency) { [weak self] in
            guard let self = self else { return }
            // tabName 校验：用户在 0.5s 内可能已经切到别的 tab
            guard self.tabName == originalTab else {
                self.hideLoading()
                return
            }

            self.items = MockFeedService.makeCards(tab: self.tabName, count: 30)
            self.adapter.performUpdates(animated: false) { [weak self] _ in
                guard let self = self else { return }
                self.hideLoading()
                self.delegate?.feedViewControllerDidFinishLoading(self)
            }
            self.didFireReachBottom = false
        }
    }

    /// 下拉刷新 handler。
    /// - 异步 0.5s 后重新调 mock service，模拟一次网络往返
    /// - tabName 校验：拍快门式异步回调里要确认还在原 tab，避免用户已切走时旧响应污染当前 tab
    @objc private func handleRefresh() {
        let originalTab = tabName

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.simulatedNetworkLatency) { [weak self] in
            guard let self = self else { return }
            guard self.tabName == originalTab else {
                self.refreshControl.endRefreshing()
                return
            }

            // 重新调 mock：MockFeedService.makeCards 已经做成「每次都返回全新随机一批」，
            // 所以 IGListKit diff 会全删全插，瀑布流自然滚回顶部
            self.items = MockFeedService.makeCards(tab: self.tabName, count: 30)
            self.adapter.performUpdates(animated: false) { [weak self] _ in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.delegate?.feedViewControllerDidFinishLoading(self)
            }
            self.didFireReachBottom = false
        }
    }

    private func showLoading() {
        view.bringSubviewToFront(loadingContainer)
        loadingContainer.isHidden = false
        loadingIndicator.startAnimating()
    }

    private func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingContainer.isHidden = true
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
