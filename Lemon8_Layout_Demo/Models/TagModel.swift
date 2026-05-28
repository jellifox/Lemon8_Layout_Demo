//
//  TagModel.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/9.
//

import Foundation
import UIKit
import IGListDiffKit

final class TagModel{
    let tagID: String
    let tagTitle: String
    
    init(tagID: String, tagTitle: String) {
        self.tagID = tagID
        self.tagTitle = tagTitle
    }
}

extension TagModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
      return tagID as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? TagModel else { return false }
        return  tagTitle == object.tagTitle
    }
}
