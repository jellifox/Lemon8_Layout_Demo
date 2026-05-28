//
//  TagSectionController.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/10.
//

import UIKit
import IGListKit

protocol TagSectionControllerDelegate: AnyObject {
    func tagSectionController(_ controller: TagSectionController, didSelectTag tag: TagModel)
}

class TagSectionController: ListSectionController {
    private var tagModel: TagModel?
    weak var delegate: TagSectionControllerDelegate?

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        guard let tag = tagModel else {
            return CGSize(width: 60, height: 32)
        }

        let font = UIFont.systemFont(ofSize: 14)
        let textWidth = (tag.tagTitle as NSString).size(withAttributes: [.font: font]).width
        let cellWidth = ceil(textWidth) + 32 // 16pt padding on each side
        let cellHeight: CGFloat = 32 // 8pt padding top + ~16pt text + 8pt padding bottom
        return CGSize(width: cellWidth, height: cellHeight)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: TagCollectionViewCell.self, for: self, at: index) as? TagCollectionViewCell,
              let tagModel = tagModel else {
            return UICollectionViewCell()
        }

        cell.configure(with: tagModel)
        return cell
    }

    override func didSelectItem(at index: Int) {
        guard let tagModel = tagModel else { return }
        delegate?.tagSectionController(self, didSelectTag: tagModel)
    }

    override func didUpdate(to object: Any) {
        tagModel = object as? TagModel
    }
}
