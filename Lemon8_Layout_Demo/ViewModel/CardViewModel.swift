//
//  CardViewModel.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2026/4/9.
//

import Foundation
import RxSwift
import RxRelay

class CardViewModel {
    let cellTapped = PublishRelay<CardModel>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        // 在这里处理业务逻辑，比如调 API 或 统计埋点
    //        cellTapped.subscribe(onNext: { model in
    //            print("处理业务逻辑: 用户点击了 \(model.title)")
    //        }).disposed(by: disposeBag)
    }
}
