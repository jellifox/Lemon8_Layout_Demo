//
//  CardModel.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/2/10.
//

import Foundation
import UIKit
import IGListDiffKit

final class CardModel{
    let id: String
    let title: String
    let content: String
    let imageURL: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let userName: String
    let userAva: String
    let likeCount: Int
    
    let videoURL: String?
    let videoCoverURL: String?
    
    var isVideo: Bool{
        return videoURL != nil
    }
    
    init(id: String, title: String, content: String, imageURL: String, imageWidth: CGFloat, imageHeight: CGFloat, userName: String, userAva: String, likeCount: Int, videoURL: String?, videoCoverURL: String?) {
        self.id = id
        self.title = title
        self.content = content
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.userName = userName
        self.userAva = userAva
        self.likeCount = likeCount
        self.videoURL = videoURL
        self.videoCoverURL = videoCoverURL
    }
    
    var imageAspectRatio: CGFloat {
        guard imageWidth > 0 else { return 1.2 }
        return imageHeight / imageWidth
    }
}

// MARK: - ListDiff
extension CardModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
      return id as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? CardModel else { return false }
        return  id == object.id &&
                title == object.title &&
                content == object.content &&
                imageURL == object.imageURL &&
                likeCount == object.likeCount
    }
}
