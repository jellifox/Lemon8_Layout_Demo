//
//  MockFeedService.swift
//  Lemon8_Layout_Demo
//

import UIKit

enum MockFeedService {

    // MARK: - Tabs

    static func makeTabs() -> [TagModel] {
        return [
            TagModel(tagID: "foryou",  tagTitle: "推荐"),
            TagModel(tagID: "fashion", tagTitle: "时尚"),
            TagModel(tagID: "food",    tagTitle: "美食"),
        ]
    }

    // MARK: - Cards

    /// 每次调用生成一批"全新"卡片：
    /// - 同批内 id 全唯一（tab + fetchID + i），跨批不可能撞
    /// - 标题、图片 seed、高度、用户名、头像、点赞数、是否视频，全随机
    /// 目的：每次 fetch 都让 IGListKit 真把列表 diff 成全删全插，
    /// 配合 loading 动画做出真实的"加载完毕替换内容"的体感。
    static func makeCards(tab: String, count: Int) -> [CardModel] {
        let fetchID = "\(Int(Date().timeIntervalSince1970 * 1000))-\(Int.random(in: 0...999))"

        return (0..<count).map { i in
            let id = "\(tab)-\(fetchID)-\(i)"
            let w: CGFloat = 300
            let h = randomImageHeight()
            let imageSeed = "\(fetchID)-\(i)"
            let imageURL = "https://picsum.photos/seed/\(imageSeed)/\(Int(w))/\(Int(h))"

            let isVideo = shouldBeVideo()
            // 视频卡片的封面用同一张 picsum，URL 是 mock 字符串（不真播放，只让 cell 显示 playOverlay）
            let videoURL: String? = isVideo ? "mock://video/\(id)" : nil
            let videoCoverURL: String? = isVideo ? imageURL : nil

            return CardModel(
                id: id,
                title: randomTitle(for: tab),
                content: "",
                imageURL: imageURL,
                imageWidth: w,
                imageHeight: h,
                userName: randomUserName(),
                userAva: randomAvatarURL(),
                likeCount: randomLikeCount(),
                videoURL: videoURL,
                videoCoverURL: videoCoverURL
            )
        }
    }

    // MARK: - Title pool (主题分池)

    private static let recommendTitles: [String] = [
        "今日份的小确幸", "周末好物分享", "打卡新店", "生活仪式感",
        "无聊但是有趣", "宝藏 app 推荐", "猫狗日常", "随手拍",
        "上班族午餐", "工位改造", "好物种草", "周末摆烂",
        "今天看到的", "通勤路上", "晚安日记", "小众展览",
        "复购清单", "近期电影", "随便聊聊", "好久不见",
    ]

    private static let fashionTitles: [String] = [
        "秋冬叠穿公式", "极简风格分享", "通勤穿搭", "小个子救星",
        "日杂风 OOTD", "可可爱爱发卡", "百搭白衬衫", "美甲灵感",
        "丹宁单品", "今日妆容教程", "梨型身材选裤", "韩剧女主同款",
        "高质感平价", "围巾搭配", "vintage 复古风", "复古口红试色",
        "高级感配色", "毛绒外套", "知性穿搭", "懒人妆容",
    ]

    private static let foodTitles: [String] = [
        "家庭版麻婆豆腐", "30 秒早餐", "深夜食堂打卡", "甜品教程",
        "懒人减脂餐", "电饭锅蛋糕", "厨房新手必看", "私房菜谱",
        "周末烘焙", "面包机配方", "韩式拌饭", "夜宵推荐",
        "广式糖水", "0 失败戚风", "网红甜品复刻", "一人食食谱",
        "外卖避雷", "家常下饭菜", "咖啡馆探店", "宝藏小馆",
    ]

    private static let titlePrefixes: [String] = ["实测", "亲测", "避雷", "种草", "宝藏", "出片", "高分"]

    private static let titleSuffixes: [String] = [
        "", "", "", "", "", "", "", "",   // 8 个空：~62% 概率无后缀
        "(必看)", "(收藏向)", "✨", "🔥", "💄",
    ]

    private static func randomTitle(for tab: String) -> String {
        let pool: [String]
        switch tab {
        case "时尚": pool = fashionTitles
        case "美食": pool = foodTitles
        default:    pool = recommendTitles
        }
        let main = pool.randomElement() ?? "示例标题"

        // 25% 概率带前缀
        let hasPrefix = Int.random(in: 0..<100) < 25
        let prefix = hasPrefix ? "\(titlePrefixes.randomElement() ?? "") " : ""
        let suffix = titleSuffixes.randomElement() ?? ""

        return prefix + main + suffix
    }

    // MARK: - Image

    /// 11 档高度，撑出瀑布流的高低差
    private static let imageHeightPool: [CGFloat] = [
        180, 200, 220, 240, 260, 280, 300, 320, 360, 400, 420,
    ]

    private static func randomImageHeight() -> CGFloat {
        return imageHeightPool.randomElement() ?? 280
    }

    // MARK: - User

    private static let userNamesPool: [String] = [
        "晚风", "山有木", "小笼包", "白桃汽水", "栗子蛋糕", "野生柠檬", "苏打绿",
        "桐桐", "暖暖", "夏目", "Lin", "果酱", "可乐", "三月",
        "卷卷头", "海盐", "麦芽糖", "树懒先生", "热可可", "麋鹿", "南风",
        "Mia", "Yuki", "Alex", "Emma", "Echo", "Cici", "Aki", "Noah",
    ]

    private static func randomUserName() -> String {
        return userNamesPool.randomElement() ?? "匿名用户"
    }

    private static func randomAvatarURL() -> String {
        // pravatar 的 img 参数 1~70
        let img = Int.random(in: 1...70)
        return "https://i.pravatar.cc/100?img=\(img)"
    }

    // MARK: - Stats

    /// 加权随机点赞数：80% 小数 / 15% 中等 / 5% 爆款，更像真实分布
    private static func randomLikeCount() -> Int {
        let r = Int.random(in: 0..<100)
        switch r {
        case 0..<80:  return Int.random(in: 0...100)
        case 80..<95: return Int.random(in: 100...5000)
        default:      return Int.random(in: 5000...99999)
        }
    }

    /// 20% 概率是视频卡
    private static func shouldBeVideo() -> Bool {
        return Int.random(in: 0..<100) < 20
    }
}
