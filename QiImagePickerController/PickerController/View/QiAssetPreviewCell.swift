//
//  QiAssetPreviewCell.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAssetPreviewCell: UICollectionViewCell {
    var assetModel : QiAssetModel? {
        willSet {
            preview.assetModel = newValue
        }
    }
    private var preview : QiAssetPreview!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        preview = QiAssetPreview.init(frame: bounds)
        self.addSubview(preview)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
