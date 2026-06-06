//
//  MainCollectionViewCell.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/10.
//
//  外层横滑 paging UICollectionView 里的 cell，全屏宽。
//  B 阶段重构（cell-owned VC）：cell 自己持有一个 FeedVC，cell init 时就把 VC.view 装进
//  contentView。HomeVC 在 cellForItemAt 时 addChild(cell.feedVC) + cell.bind(tab:, delegate:)。
//  cell 复用 = 同一个 cell.feedVC 切 tab 重拉数据，而不是切换 view 实例。
//

import UIKit

final class MainCollectionViewCell: UICollectionViewCell {

    /// cell 持有的内层 FeedVC。生命周期跟 cell 一致。
    /// 父子关系（addChild）由 HomeVC 在 cellForItemAt / didEndDisplaying 中管理。
    let feedVC = FeedViewController()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .white

        // 访问 feedVC.view 会触发其 viewDidLoad（懒创建 inner cv 等）。
        // 此时 contentView.bounds 可能为 0，没关系——autoresizingMask 会在 cell 拿到
        // 真正的 frame 之后自动把 vc.view 撑满。
        let v = feedVC.view!
        v.frame = contentView.bounds
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(v)
    }

    /// 绑定 tab + 设置 delegate。由 HomeVC 在 cellForItemAt 中调用。
    /// 调 switchTab 会触发 VC 内部 loadData → adapter.performUpdates。
    func bind(tab: TagModel, delegate: FeedViewControllerDelegate) {
        feedVC.delegate = delegate
        feedVC.switchTab(tab)
    }
}
