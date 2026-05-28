//
//  MockFeedService.swift
//  Lemon8_Layout_Demo
//

import UIKit

enum MockFeedService {
    static func makeCards(tab: String, count: Int) -> [CardModel] {
        let heights: [CGFloat] = [200, 260, 320, 240, 380, 300]
        return (0..<count).map { i in
            let w: CGFloat = 300
            let h = heights[i % heights.count]
            return CardModel(
                id: "\(tab)-\(i)",
                title: "\(tab) · 示例标题，瀑布流卡片 \(i)",
                content: "",
                imageURL: "https://picsum.photos/seed/\(tab)\(i)/\(Int(w))/\(Int(h))",
                imageWidth: w,
                imageHeight: h,
                userName: "用户\(i)",
                userAva: "https://i.pravatar.cc/100?img=\((i % 70) + 1)",
                likeCount: Int.random(in: 0...9999),
                videoURL: nil,
                videoCoverURL: nil
            )
        }
    }
}
