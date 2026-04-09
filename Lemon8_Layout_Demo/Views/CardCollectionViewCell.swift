//
//  CardCollectionViewCell.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/9.
//

import UIKit
import Kingfisher
import SnapKit

class CardCollectionViewCell: UICollectionViewCell {
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorAvatarImageView = UIImageView()
    private let authorNameLabel = UILabel()
    private let likeButton = UIButton()
    private let likeCountLabel = UILabel()
    
    private let playOverlayView = UIImageView(image: UIImage(systemName: "play.circle.fill"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupGesture()
    }
    
    private func setupUI() {
        containerView.backgroundColor = .systemBackground
        containerView
    }
    
    
}
