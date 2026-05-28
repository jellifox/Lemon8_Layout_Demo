//
//  MainCollectionViewCell.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/10.
//

import UIKit
import IGListKit
import SnapKit

class MainCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    // 第二步会改成由外层 HomeVC 持有 child VC，再把 VC 注入 cell，
    // 届时 adapter 的 viewController 用真正的 VC。当前先 nil 占位让编译通过。
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
    }()

    private let collectionView: UICollectionView = {
        let layout = WaterFall()
        layout.delegate = nil 
        layout.column = 2
        layout.minimumColumnSpacing = 8
        layout.minimumInterSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private var feedData: [CardModel] = []
}
