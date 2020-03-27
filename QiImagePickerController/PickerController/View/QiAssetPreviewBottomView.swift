//
//  QiAssetPreviewBottomView.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/27.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAssetPreviewBottomView: UIView {
    
    private var editButton : UIButton!
    private var originButton : UIButton!
    private var sendButton : UIButton!
    var editButtonHandler : (()->())?
    var originButtonHandler : (()->())?
    var sendButtonHandler : (()->())?
    var color_back : UIColor = UIColor.qi_colorWithHexString("#434445").withAlphaComponent(0.8)
    var color_disable : UIColor = UIColor.qi_colorWithHexString("#7B7C7D")
    var color_normal : UIColor = UIColor.white
    var color_send_normalbg : UIColor = UIColor.qi_colorWithHexString("#32E96D")
    var color_send_disablebg : UIColor = UIColor.qi_colorWithHexString("#515253")
    var font_main : UIFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    override init(frame: CGRect) {

        super.init(frame: frame)
        
        self.backgroundColor = color_back

        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .systemChromeMaterialDark))
        effectView.frame = bounds
        self.addSubview(effectView)
        
        editButton = UIButton.init(frame: .zero)
        editButton.setAttributedTitle(NSAttributedString.init(string: "编辑", attributes: [NSAttributedString.Key.foregroundColor : color_normal,NSAttributedString.Key.font : font_main]), for: .normal)
        editButton.setAttributedTitle(NSAttributedString.init(string: "编辑", attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue,NSAttributedString.Key.font : font_main]), for: .disabled)
        editButton.addTarget(self, action: #selector(editButtonButtonHandler(_ :)), for: .touchUpInside)
        editButton.sizeToFit()
        editButton.qi_width += 26.0
        editButton.qi_height = 30.0
        editButton.qi_left = 0
        editButton.qi_top = 9.5
        addSubview(editButton)
        
        //控制全局设置的
        originButton = UIButton.init(frame: .zero)
        originButton.setAttributedTitle(NSAttributedString.init(string: "原图", attributes: [NSAttributedString.Key.foregroundColor : color_normal,NSAttributedString.Key.font : font_main]), for: .normal)
        originButton.setImage(UIImage.init(named: "icon_bottom_unselected"), for: .normal)
        originButton.setImage(UIImage.init(named: "icon_bottom_select"), for: .selected)
        originButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: -5)
        originButton.addTarget(self, action: #selector(setOriginImageHandler(_ :)), for: .touchUpInside)
        originButton.sizeToFit()
        originButton.qi_width += 16.0
        originButton.qi_height = 30.0
        originButton.qi_centerX = self.qi_centerX
        originButton.qi_top = 9.5
        addSubview(originButton)
        
        sendButton = UIButton.init(frame: .zero)
        sendButton.setAttributedTitle(NSAttributedString.init(string: "发送", attributes: [NSAttributedString.Key.foregroundColor : color_normal,NSAttributedString.Key.font : font_main]), for: .normal)
        sendButton.setAttributedTitle(NSAttributedString.init(string: "发送", attributes: [NSAttributedString.Key.foregroundColor : color_disable,NSAttributedString.Key.font : font_main]), for: .disabled)
        sendButton.addTarget(self, action: #selector(sendButtonHandler(_ :)), for: .touchUpInside)
        sendButton.setBackgroundImage(UIImage.qi_colorImage(color_send_normalbg), for: .normal)
        sendButton.setBackgroundImage(UIImage.qi_colorImage(color_send_disablebg), for: .disabled)
        sendButton.sizeToFit()
        sendButton.qi_width += 20.0
        sendButton.qi_height = 30.0
        sendButton.qi_top = 9.5
        sendButton.qi_right = self.qi_right - 10.0
        sendButton.layer.cornerRadius = 4.0
        sendButton.layer.masksToBounds = true
        addSubview(sendButton)
    }
    
    @objc func sendButtonHandler(_ sender : UIButton) {
        sendButtonHandler?()
    }

    @objc func setOriginImageHandler(_ sender : UIButton) {
        originButtonHandler?()
    }
    @objc func editButtonButtonHandler(_ sender : UIButton) {
        editButtonHandler?()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
