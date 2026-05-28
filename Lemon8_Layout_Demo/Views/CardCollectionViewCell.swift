//
//  CardCollectionViewCell.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/9.
//

import UIKit
import Kingfisher
import SnapKit
import RxSwift

class CardCollectionViewCell: UICollectionViewCell {
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorAvatarImageView = UIImageView()
    private let authorNameLabel = UILabel()
    private let likeButton = UIButton()
    private let likeCountLabel = UILabel()
    
    private let playOverlayView = UIImageView(image: UIImage(systemName: "play.circle.fill"))
    
    private var imageHeightConstraint: NSLayoutConstraint?
    private var titleHeightConstraint: Constraint?
    
    // MARK: - Properties
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // UI reset
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        authorAvatarImageView.kf.cancelDownloadTask()
        authorAvatarImageView.image = nil
        titleLabel.text = nil
        authorNameLabel.text = nil
        likeCountLabel.text = nil
        likeButton.isSelected = false
        playOverlayView.isHidden = true
    }
    
    // MARK: - UI
    private func setupUI() {
        // MARK: Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)

        // MARK: Image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)

        // MARK: Play overlay (video badge)
        playOverlayView.tintColor = .white
        playOverlayView.contentMode = .scaleAspectFit
        playOverlayView.isHidden = true
        imageView.addSubview(playOverlayView)

        // MARK: Title
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        titleLabel.numberOfLines = 2
        containerView.addSubview(titleLabel)

        // MARK: Author avatar
        authorAvatarImageView.contentMode = .scaleAspectFill
        authorAvatarImageView.clipsToBounds = true
        authorAvatarImageView.layer.cornerRadius = 10
        containerView.addSubview(authorAvatarImageView)

        // MARK: Author name
        authorNameLabel.font = .systemFont(ofSize: 11, weight: .regular)
        authorNameLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        containerView.addSubview(authorNameLabel)

        // MARK: Like button
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        likeButton.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        containerView.addSubview(likeButton)

        // MARK: Like count
        likeCountLabel.font = .systemFont(ofSize: 11, weight: .regular)
        likeCountLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        containerView.addSubview(likeCountLabel)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            titleHeightConstraint = make.height.equalTo(20).constraint
        }
        
        authorAvatarImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        likeButton.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarImageView)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(20)
        }

        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarImageView)
            make.right.equalTo(likeButton.snp.left).offset(-4)
        }

        authorNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarImageView)
            make.left.equalTo(authorAvatarImageView.snp.right).offset(6)
            make.right.lessThanOrEqualTo(likeCountLabel.snp.left).offset(-8)
        }
        
        playOverlayView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.height.equalTo(40)
        }
    }
    
    func configure(with model: CardModel) {
        titleLabel.text = model.title
        authorNameLabel.text = model.userName
        likeCountLabel.text = model.likeCount > 0 ? "\(model.likeCount)" : ""

        // Image height based on aspect ratio
        imageView.snp.updateConstraints { make in
            make.height.equalTo(contentView.bounds.width * model.imageAspectRatio)
        }

        // Title height calculation
        let titleWidth = bounds.width - 16
        let titleFont = UIFont.systemFont(ofSize: 13, weight: .medium)
        let titleText = model.title as NSString
        let titleRect = titleText.boundingRect(
            with: CGSize(width: titleWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: titleFont],
            context: nil
        )
        let maxHeight = titleFont.lineHeight * 2
        let calculatedHeight = min(ceil(titleRect.height), maxHeight)
        titleHeightConstraint?.update(offset: calculatedHeight)

        // Load cover image (use videoCoverURL for videos, imageURL for posts)
        let coverURLString = model.isVideo ? (model.videoCoverURL ?? model.imageURL) : model.imageURL
        if let url = URL(string: coverURLString) {
            imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }

        // Load author avatar
        if let url = URL(string: model.userAva) {
            authorAvatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }

        playOverlayView.isHidden = !model.isVideo
    }
}
