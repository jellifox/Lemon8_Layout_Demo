//
//  TagCollectionViewCell.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/9.
//
//  Tab bar 风格的标签 cell。
//  「下方横线」由 HomeVC 持有的 floatingIndicator 浮层负责（为了实时跟随手势滑动），
//  cell 自己只负责字重切换（加粗 / 普通）。
//

import UIKit
import SnapKit

class TagCollectionViewCell: UICollectionViewCell {

    // MARK: - Style
    private static let normalFont    = UIFont.systemFont(ofSize: 14, weight: .regular)
    private static let selectedFont  = UIFont.systemFont(ofSize: 14, weight: .semibold)
    private static let normalColor   = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    private static let selectedColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)

    // MARK: - Subviews
    private let tagLabel = UILabel()

    // MARK: - Selection
    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tagLabel.text = nil
    }

    // MARK: - UI
    private func setupUI() {
        contentView.backgroundColor = .clear

        tagLabel.font = Self.normalFont
        tagLabel.textColor = Self.normalColor
        tagLabel.textAlignment = .center
        contentView.addSubview(tagLabel)

        tagLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func updateAppearance() {
        tagLabel.font      = isSelected ? Self.selectedFont  : Self.normalFont
        tagLabel.textColor = isSelected ? Self.selectedColor : Self.normalColor
    }

    // MARK: - Configure
    func configure(with tag: TagModel) {
        tagLabel.text = tag.tagTitle
    }
}
