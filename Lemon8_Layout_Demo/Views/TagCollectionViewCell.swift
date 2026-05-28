//
//  TagCollectionViewCell.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/9.
//

import UIKit
import SnapKit

class TagCollectionViewCell: UICollectionViewCell {
    private let tagLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tagLabel.text = nil
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        tagLabel.font = .systemFont(ofSize: 14)
        tagLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        contentView.addSubview(tagLabel)

        tagLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    func configure(with tag: TagModel) {
        tagLabel.text = tag.tagTitle
    }
}
