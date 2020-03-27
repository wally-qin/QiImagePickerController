//
//  QiAssetPreviewTopView.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/23.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAssetPreviewTopView: UIView {
    
    private var label : UILabel!
    private var imageView : UIImageView!
    private var backButton : UIButton
    private var doneButton : UIButton
    private var coverType : QiCoverType = .default {
        didSet{
           changePikerStatus()
        }
    }
    var navigationBack:(()->())?
    var doneBtnClikedBack:((_ : Bool)->())?
    var assetModel : QiAssetModel? {
        didSet {
            guard let asset = assetModel?.asset else {
                return
            }
            //设置选择状态
            let num = QiImagePickerOperation.default.pickerOrderNum(asset: asset)
            if num != -1 {
                coverType = .selected(num)
            } else {
                coverType = QiImagePickerOperation.default.shouldBePick ? .default : .prohibit("")
            }
        }
    }
    override init(frame: CGRect) {
        backButton = UIButton.init(frame: .zero)
        doneButton = UIButton.init(frame: .zero)
        label = UILabel()
        imageView = UIImageView()
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.qi_colorWithHexString("#434445").withAlphaComponent(0.8)
        
        backButton.setImage(UIImage.init(named: "icon_navi_back"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -16, bottom: 0, right: 16)
        backButton.addTarget(self, action: #selector(navigationBackAction(_:)), for: UIControl.Event.touchUpInside)
        backButton.qi_left = 8
        backButton.qi_width = 60.0
        backButton.qi_top = KStatusBarHeight
        backButton.qi_height = 44.0
        addSubview(backButton)
        
        label.numberOfLines  = 1
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.qi_top = KStatusBarHeight + 7.0
        label.qi_size = CGSize.init(width: 30.0, height: 30.0)
        label.qi_right = self.qi_right - 16.0
        label.backgroundColor = UIColor.qi_colorWithHexString("#18C066")
        label.layer.cornerRadius = label.qi_width/2.0
        label.layer.masksToBounds = true
        addSubview(label)
        
        imageView.qi_top = KStatusBarHeight + 7.0
        imageView.qi_size = CGSize.init(width: 30.0, height: 30.0)
        imageView.qi_right = self.qi_right - 16.0
        imageView.image = UIImage.init(named: "icon_navi_mark")
        addSubview(imageView)
        
        doneButton.addTarget(self, action: #selector(doneButtonAction(_:)), for: UIControl.Event.touchUpInside)
        doneButton.qi_width = 60.0
        doneButton.qi_right = self.qi_right - 16.0
        doneButton.qi_top = KStatusBarHeight
        doneButton.qi_height = 44.0
        self.addSubview(doneButton)
    }
    
    @objc func navigationBackAction(_ : UIButton) {
        navigationBack?()
    }
    
    @objc func doneButtonAction(_ sender :UIButton){
        sender.isSelected = !sender.isSelected
        //选择与取消选择
        guard let asset = assetModel?.asset else {
            return
        }
        if sender.isSelected {
            startAnimation()
            if QiImagePickerOperation.default.tryAssetPick(asset: asset) {
                coverType = .selected(QiImagePickerOperation.default.pickerOrderNum(asset: asset))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: QiImagePickerOperation.PickerAssetsOrderNumberHasChanged), object: nil)
            } else {
                print("选择资源异常")
            }
        } else {
            if QiImagePickerOperation.default.tryCancelAssetPick(asset: asset) {
                coverType = .default
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: QiImagePickerOperation.PickerAssetsOrderNumberHasChanged), object: nil)
            } else {
                print("选择资源异常")
            }
        }
        doneBtnClikedBack?(sender.isSelected)
    }
    
    func startAnimation() {
        let keyFrameAni = CAKeyframeAnimation.init(keyPath: "transform.scale")
        keyFrameAni.values = [1.2,0.8,1.0]
        keyFrameAni.fillMode = .forwards
        keyFrameAni.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        label.layer.add(keyFrameAni, forKey: "qishare.doudong")
    }
    
    func changePikerStatus() {
        switch coverType {
        case .default:
            doneButton.isSelected = false
            label.text = ""
            label.isHidden = true
            imageView.isHidden = false
            label.layer.removeAnimation(forKey: "qishare.doudong")

        case .prohibit(_):
            doneButton.isSelected = false
            label.text = ""
            label.isHidden = true
            imageView.isHidden = false
            label.layer.removeAnimation(forKey: "qishare.doudong")
            
        case let .selected(x):
            doneButton.isSelected = true
            label.text = "\(x)"
            label.isHidden = false
            imageView.isHidden = true
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
