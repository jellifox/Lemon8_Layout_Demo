//
//  FeedTabCell.swift
//  Lemon8_Layout_Demo
//
//  外层横滑 paging UICollectionView 里的「画框」cell。
//  一个 cell = 一个 tab 的位置，全屏宽。
//
//  cell 本身不画 feed，B 阶段会把 FeedViewController.view 塞进 contentView。
//  A 阶段先建好壳子，方法签名留着、实现暂时为空，方便 HomeVC 编译过。
//

import UIKit

final class FeedTabCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        // A 阶段先放一个临时占位标签，便于跑起来时看到「这里有 3 个 page」。
        // B 阶段装上 FeedVC 后会被遮住，再删除。
        let placeholder = UILabel()
        placeholder.text = "(待装 FeedVC)"
        placeholder.textColor = .lightGray
        placeholder.font = .systemFont(ofSize: 16)
        placeholder.textAlignment = .center
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Bind / Unbind（B 阶段填实现）

    /// 把一个 child VC 的 view 装进 cell.contentView。
    /// addChild / didMove 由 HomeVC 在 cellForItemAt 时调用，cell 只管接管 view。
    func bind(vcView: UIView) {
        // B 阶段实现
    }

    /// cell 滚出屏幕时调用，把 view 摘下来。
    /// removeFromParent / willMove(nil) 由 HomeVC 在 didEndDisplaying 时调用。
    func unbind() {
        // B 阶段实现
    }
}
