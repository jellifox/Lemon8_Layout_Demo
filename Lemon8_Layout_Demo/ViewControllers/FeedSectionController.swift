//
//  FeedSectionController.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/9.
//

import UIKit
import IGListKit
import Kingfisher

protocol FeedSectionControllerDelegate: AnyObject {
    func feedSectionController(_ controller: FeedSectionController, didSelectFeed feed: CardModel)
}

class FeedSectionController: ListSectionController {
    private var feedModel: CardModel?
    weak var delegate: FeedSectionControllerDelegate?
    
    override func sizeForItem(at index: Int) -> CGSize {
        let containerWidth = collectionContext?.containerSize.width ?? UIScreen.main.bounds.width
        let width = (containerWidth - 24) / 2

        guard let model = feedModel else {
            return CGSize(width: width, height: 250)
        }

        let imageHeight = width * model.imageAspectRatio
        return CGSize(width: width, height: imageHeight + 56)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CardCollectionViewCell.self, for: self, at: index) as? CardCollectionViewCell,
              let feedModel = feedModel else {
            return UICollectionViewCell()
        }

        cell.configure(with: feedModel)
        return cell
    }

    override func didSelectItem(at index: Int) {
        guard let feedModel = feedModel else { return }
        delegate?.feedSectionController(self, didSelectFeed: feedModel)
    }

    override func didUpdate(to object: Any) {
        feedModel = object as? CardModel
    }
}


