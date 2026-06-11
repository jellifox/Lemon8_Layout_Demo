//
//  HomeViewController.swift
//  Lemon8_Layout_Demo
//
//  外层"大 VC"。承载顶部 tag bar + 底部横滑 paging cv。
//  A 阶段只搭骨架：顶部 3 个 tag 可视觉切换，底部 3 个空 page 可横滑（cell 显示占位）。
//  B 阶段会把 FeedViewController.view 装进 MainCollectionViewCell。
//

import UIKit
import IGListKit

final class HomeViewController: UIViewController {

    // MARK: - Data
    private let tabs: [TagModel] = MockFeedService.makeTabs()
    private var selectedTagIndex: Int = 0
    // B 阶段重构（cell-owned VC）：FeedVC 不再由 HomeVC 持有数组，
    // 而是由每个 MainCollectionViewCell 自己持有。HomeVC 仅在 cellForItemAt
    // 时通过 addChild 接管 VC 的父子关系。

    // MARK: - Top tag bar
    private let topTagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        cv.allowsSelection = true
        cv.allowsMultipleSelection = false
        return cv
    }()

    private lazy var topAdapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    // MARK: - Floating indicator (浮在 topTagCV 上方的「下方横线」，跟随手势实时滑动)
    private static let indicatorWidth: CGFloat = 16
    private static let indicatorHeight: CGFloat = 3
    private let floatingIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        v.layer.cornerRadius = 1.5
        v.isHidden = true // 首次 layout 完成后再显示，避免位置闪烁
        return v
    }()

    // MARK: - Bottom paging cv
    private static let pagingCellID = "MainCollectionViewCell"

    private let pagingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = false
        return cv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(topTagCollectionView)
        view.addSubview(pagingCollectionView)
        view.addSubview(floatingIndicator) // 在 topTagCV 之上的 z-order

        // Top
        topAdapter.collectionView = topTagCollectionView
        topAdapter.dataSource = self
        topAdapter.performUpdates(animated: false)

        // Bottom
        pagingCollectionView.dataSource = self
        pagingCollectionView.delegate = self
        pagingCollectionView.register(
            MainCollectionViewCell.self,
            forCellWithReuseIdentifier: Self.pagingCellID
        )
        // B 阶段重构：不再预先 addChild 任何 FeedVC。
        // 改由 cellForItemAt 在第一次拿到 cell 时，addChild(cell.feedVC)。
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 初始选中第一个 tag。延后到 viewDidAppear，确保 adapter 已经把 cell 创建出来。
        if topTagCollectionView.indexPathsForSelectedItems?.isEmpty ?? true {
            let ip = IndexPath(item: 0, section: selectedTagIndex)
            topTagCollectionView.selectItem(at: ip, animated: false, scrollPosition: [])
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topHeight: CGFloat = 44
        let safeTop = view.safeAreaInsets.top

        topTagCollectionView.frame = CGRect(
            x: 0,
            y: safeTop,
            width: view.bounds.width,
            height: topHeight
        )
        pagingCollectionView.frame = CGRect(
            x: 0,
            y: safeTop + topHeight,
            width: view.bounds.width,
            height: view.bounds.height - safeTop - topHeight
        )

        // paging cv 的 itemSize 跟随 cv 自己的 size
        if let flow = pagingCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let newSize = pagingCollectionView.bounds.size
            if flow.itemSize != newSize, newSize.width > 0, newSize.height > 0 {
                flow.itemSize = newSize
                flow.invalidateLayout()
            }
        }

        // 给 floatingIndicator 一个初始位置（停在当前选中的 tag 下方）
        // dispatch async 确保 topCV 已经完成 cell 布局
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateIndicatorPosition(progress: CGFloat(self.selectedTagIndex))
            self.floatingIndicator.isHidden = false
        }
    }
}

// MARK: - ListAdapterDataSource (top tag bar)
extension HomeViewController: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return tabs
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sc = TagSectionController()
        sc.delegate = self
        return sc
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

// MARK: - TagSectionControllerDelegate
extension HomeViewController: TagSectionControllerDelegate {

    func tagSectionController(_ controller: TagSectionController, didSelectTag tag: TagModel) {
        guard let idx = tabs.firstIndex(where: { $0.tagID == tag.tagID }) else { return }
        handleTagTap(at: idx)
    }
}

// MARK: - FeedViewControllerDelegate
extension HomeViewController: FeedViewControllerDelegate {

    func feedViewController(_ vc: FeedViewController, didTapCard card: CardModel) {
        print("[Home] didTapCard: tab=\(vc.tabName), title=\(card.title)")
        // 后续 Step：跳到详情页 / 埋点
    }

    func feedViewControllerDidReachBottom(_ vc: FeedViewController) {
        print("[Home] didReachBottom: tab=\(vc.tabName)")
        // 后续 Step：触发分页加载
    }

    func feedViewControllerDidFinishLoading(_ vc: FeedViewController) {
        print("[Home] didFinishLoading: tab=\(vc.tabName)")
        // 后续 Step：隐藏 loading 占位
    }

    func feedViewController(_ vc: FeedViewController, didFailLoading error: Error) {
        print("[Home] didFailLoading: tab=\(vc.tabName), error=\(error)")
        // 后续 Step：显示重试
    }
}

// MARK: - Central sync (C 阶段：HomeVC 中央调度顶部与底部的联动)
private extension HomeViewController {

    /// 顶部 tag 被点击时调用。
    /// - tag 自己的视觉选中由 UICollectionView 内置机制（cell.isSelected）处理，这里不重复设。
    /// - 只负责把底部 paging cv 滚到对应 page。
    func handleTagTap(at index: Int) {
        guard index != selectedTagIndex else { return } // 幂等：同 index 不动
        selectedTagIndex = index
        pagingCollectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }

    /// 底部 paging cv 横滑结束时调用（手动 deceleration 结束 / 程序 scroll 动画结束）。
    /// 实时跟随模式下，selectedTagIndex 已经在 scrollViewDidScroll 中持续更新；这里
    /// 主要负责把选中的 tag 滚到 topCV 的可见区域（many-tab 时有用）。
    func handleBottomScrollEnded() {
        let pageWidth = pagingCollectionView.bounds.width
        guard pageWidth > 0 else { return }
        let index = Int((pagingCollectionView.contentOffset.x / pageWidth).rounded())
        guard index >= 0, index < tabs.count else { return }

        if index != selectedTagIndex {
            selectedTagIndex = index
        }
        // 不带幂等判断，统一让 topCV 居中显示。selectItem 不会触发 didSelectItemAt，安全。
        topTagCollectionView.selectItem(
            at: IndexPath(item: 0, section: index),
            animated: true,
            scrollPosition: .centeredHorizontally
        )
    }

    /// 实时跟随的核心：根据 pagingCV 的 progress（浮点）插值 floatingIndicator 的位置。
    /// progress = contentOffset.x / pageWidth，0 == tab 0，1 == tab 1，1.5 == 1 和 2 中间。
    func updateIndicatorPosition(progress: CGFloat) {
        guard tabs.count > 0 else { return }
        let clamped = max(0, min(CGFloat(tabs.count - 1), progress))
        let lowIdx = Int(floor(clamped))
        let highIdx = min(lowIdx + 1, tabs.count - 1)
        let frac = clamped - CGFloat(lowIdx)

        let lowIP = IndexPath(item: 0, section: lowIdx)
        let highIP = IndexPath(item: 0, section: highIdx)

        guard let lowAttr = topTagCollectionView.layoutAttributesForItem(at: lowIP) else { return }
        let highAttr = topTagCollectionView.layoutAttributesForItem(at: highIP) ?? lowAttr

        // 在 topCV 的 content 坐标系里插值出当前应该停留的中心 x
        let interpCenterX = lowAttr.center.x + (highAttr.center.x - lowAttr.center.x) * frac

        // 转换到 HomeVC.view 的坐标系：减去 topCV 的 contentOffset.x，加 topCV.frame.minX
        let xInView = topTagCollectionView.frame.minX + interpCenterX - topTagCollectionView.contentOffset.x
        let yInView = topTagCollectionView.frame.maxY - Self.indicatorHeight - 2

        floatingIndicator.frame = CGRect(
            x: xInView - Self.indicatorWidth / 2,
            y: yInView,
            width: Self.indicatorWidth,
            height: Self.indicatorHeight
        )
    }

    /// 滑动到某个 tab 过半时，更新 selectedTagIndex 触发顶部 cell 加粗切换。
    /// scrollPosition: [] 表示不让 topCV 自动滚动（drag 中不应该和用户抢滚动），end-of-scroll 时再统一 center。
    func updateBoldSelectionDuringDrag(progress: CGFloat) {
        let newIdx = Int(progress.rounded())
        guard newIdx >= 0, newIdx < tabs.count else { return }
        guard newIdx != selectedTagIndex else { return }
        selectedTagIndex = newIdx
        topTagCollectionView.selectItem(
            at: IndexPath(item: 0, section: newIdx),
            animated: false,
            scrollPosition: []
        )
    }
}

// MARK: - UICollectionViewDataSource (bottom paging cv)
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.pagingCellID,
            for: indexPath
        ) as! MainCollectionViewCell

        if cell.feedVC.parent !== self {
            addChild(cell.feedVC)
            cell.feedVC.didMove(toParent: self)
        }
        cell.bind(tab: tabs[indexPath.item], delegate: self)
        return cell
    }
}

// MARK: - UICollectionViewDelegate (bottom paging cv)
extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MainCollectionViewCell else { return }
        // B 阶段重构：cell 滚出屏幕，解除父子关系（VC 还存活，cell 持有它）。
        // 下次 cell 被复用时 cellForItemAt 会再 addChild 回来。
        if cell.feedVC.parent === self {
            cell.feedVC.willMove(toParent: nil)
            cell.feedVC.removeFromParent()
        }
    }

    // MARK: - UIScrollViewDelegate (paging cv 的 scroll 钩子)
    // 注意：只有 pagingCollectionView 的 delegate 是 HomeVC；
    // topTagCollectionView 的 delegate 是 ListAdapter，这里这些回调不会触发于它。
    // 即便如此，下面仍加 scrollView === pagingCollectionView 的判断作为防御。

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 滚动每一帧都触发（无论手势还是程序动画）。计算 progress 实时驱动 indicator + 加粗。
        guard scrollView === pagingCollectionView else { return }
        let pageWidth = pagingCollectionView.bounds.width
        guard pageWidth > 0 else { return }
        let progress = pagingCollectionView.contentOffset.x / pageWidth
        updateIndicatorPosition(progress: progress)
        updateBoldSelectionDuringDrag(progress: progress)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 手指松开后 cv 自己减速到吸附完成时触发（手势触发的横滑）
        guard scrollView === pagingCollectionView else { return }
        handleBottomScrollEnded()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 程序触发的 scrollToItem 动画结束时触发（点 tab 引起的滚动）
        guard scrollView === pagingCollectionView else { return }
        handleBottomScrollEnded()
    }
}
