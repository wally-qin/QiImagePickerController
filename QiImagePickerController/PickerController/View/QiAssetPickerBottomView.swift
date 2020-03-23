//
//  QiAssetPickerBottomView.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/23.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAssetPickerBottomView: UIView {

    private var label : UILabel!
    private var imageView : UIImageView!
    
    override init(frame: CGRect) {
        label = UILabel()
        imageView = UIImageView()
        
        super.init(frame: frame)
        
        label.numberOfLines  = 1
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.qi_top = KStatusBarHeight + 7.0
        label.qi_size = CGSize.init(width: 30.0, height: 30.0)
        label.qi_right = self.qi_right - 5.0
        label.backgroundColor = UIColor.qi_colorWithHexString("#18C066")
        addSubview(label)
        
        imageView.frame = label.bounds
        imageView.image = UIImage.init(named: "icon_navi_mark")
        addSubview(imageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
