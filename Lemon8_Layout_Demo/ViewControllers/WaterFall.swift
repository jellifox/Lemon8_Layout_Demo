//
//  WaterFall.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/8.
//

import UIKit


protocol WaterFallDelegate: AnyObject {

    func waterfallLayout(_ layout: WaterFall, heightForItemAt indexPath: IndexPath) -> CGFloat

}

class WaterFall: UICollectionViewLayout {
    weak var delegate: WaterFallDelegate?
    
    var column: Int = 2
    var minimumColumnSpacing: CGFloat = 10
    var minimumInterSpacing: CGFloat = 5
    var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var columnHeights: [CGFloat] = []
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        cache.removeAll()
        columnHeights = Array(repeating: sectionInset.top, count: column)
        
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right - CGFloat(column - 1) * minimumColumnSpacing
        let itemWidth = availableWidth / CGFloat(column)
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        for item in 0..<itemCount {
            let indexPath = IndexPath(item: item, section: 0)
            
            // 找到当前最短的列
            let shortestColumn = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            
            let xOffset = sectionInset.left + CGFloat(shortestColumn) * (itemWidth + minimumColumnSpacing)
            let yOffset = columnHeights[shortestColumn]
            
            // 通过 delegate 获取 item 高度
            let itemHeight = delegate?.waterfallLayout(self, heightForItemAt: indexPath) ?? 200
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
            cache.append(attributes)
            
            // 更新该列高度
            columnHeights[shortestColumn] = yOffset + itemHeight + minimumInterSpacing
        }
        
        // 内容总高度取最长列的高度
        contentHeight = (columnHeights.max() ?? 0) - minimumInterSpacing + sectionInset.bottom
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return collectionView.bounds.width != newBounds.width
    }
    
}
