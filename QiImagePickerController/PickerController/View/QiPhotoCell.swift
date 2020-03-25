//
//  QiPhotoCell.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/14.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
enum QiCoverType {
    case `default`,prohibit(String),selected(Int)
}
class QiPhotoCell: UICollectionViewCell {
    static var imageSize : CGSize!
    private var imageView : UIImageView!
    private var typeContentView : QiMediaTypeContentView!
    private var coverView : QiCoverView!
    var coverType : QiCoverType = .default {
        didSet {
            coverView.coverType = coverType
        }
    }
    var coverButtonHandler : (( _ : Bool ) -> Void)? {
        didSet {
            coverView.coverButtonHandler = coverButtonHandler
        }
    }
    
    var assetIdentifier:String!//资产的唯一标识
    var assetModel:QiAssetModel!{
        willSet {
            typeContentView.asset = newValue
        }
        didSet {
            guard let asset = assetModel.asset else {
                return
            }
            assetIdentifier = asset.localIdentifier
            //TODO:请求图片的大小
            QiImagePikerManager.manager.requestImage(for: asset, targetSize: QiPhotoCell.imageSize) { (image, info) in
                if self.assetIdentifier == asset.localIdentifier {
                    //防止复用，回调会多次
                    /*// UIKit may have recycled this cell by the handler's activation time.
                    // Set the cell's thumbnail image only if it's still showing the same asset.*/
                    self.imageView.image = image
//                    print(info)
                }
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
        super.init(frame: frame)
        
        imageView = UIImageView.init(frame: self.bounds)
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        
        typeContentView = QiMediaTypeContentView.init(frame: .init(x: 0, y: self.bounds.height - 25.0, width: self.bounds.width, height: 25))
        typeContentView.backgroundColor = .clear
        addSubview(typeContentView)
        
        coverView = QiCoverView.init(frame: bounds)
        coverView.coverType = coverType
        addSubview(coverView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pickerAssetsOrderNumberHasChanged(_:)), name: NSNotification.Name(rawValue: QiImagePickerOperation.PickerAssetsOrderNumberHasChanged), object: nil)
        
    }
    
    @objc func pickerAssetsOrderNumberHasChanged(_ notif : Notification) {
        if let asset = assetModel.asset {
            
            let num = QiImagePickerOperation.default.pickerOrderNum(asset: asset)
            if num != -1 {
                coverType = .selected(num)
            } else {
                coverType = QiImagePickerOperation.default.shouldBePick ? .default : .prohibit("")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QiMediaTypeContentView: UIView {
    var desLabel : UILabel!
    var tipImageView : UIImageView!
    var asset : QiAssetModel? {
        didSet {
            if case .video(duration: _) = asset?.assetType {
                
                tipImageView.image = UIImage.init(named: "icon_video@2x")
                tipImageView.qi_width = 20.0
             
                desLabel.qi_left = tipImageView.qi_right + 10.0
                desLabel.text =  asset?.videoDuration
                
            } else if case .livePhoto = asset?.assetType{
                desLabel.text = nil
                desLabel.qi_width = 0.0
                tipImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
                tipImageView.qi_width = 20.0
                
            } else {
                
                desLabel.text = nil
                tipImageView.image = nil
                tipImageView.qi_width = 0.0
                desLabel.qi_left = 10.0
                if case .gifPhoto = asset?.assetType {
                    desLabel.text = "GIF"
                }
                
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layer = CAGradientLayer.init()
        layer.frame = self.bounds
        layer.locations = [0.1,1.0]
        layer.colors = [UIColor.clear.cgColor,UIColor.black.withAlphaComponent(0.4).cgColor]
        self.layer.addSublayer(layer)
        setupViews()
    }
    
    func setupViews() {
        
        tipImageView = UIImageView.init(frame: .init(x: 10, y: 0, width: 20, height: 20))
        addSubview(tipImageView)
        
        desLabel = UILabel.init(frame: .init(x: tipImageView.frame.maxX + 10, y: 0, width: self.bounds.width - tipImageView.frame.maxX - 10 - 10 - 10, height: 20))
        desLabel.numberOfLines  = 1
        desLabel.textColor = .white
        desLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addSubview(desLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QiCoverView: UIView {
    
    var coverType : QiCoverType = .default {
        didSet{
            changeCoverViewStatus()
        }
    }
    var coverButtonHandler : (( _ : Bool ) -> Void)?
    private var button : UIButton
    private var label : UILabel
    
    override init(frame: CGRect) {
        
        label = UILabel()
        button = UIButton()
        
        super.init(frame: frame)
        
        label.numberOfLines  = 1
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.qi_top = self.qi_top + 5.0
        label.qi_size = CGSize.init(width: 26.0, height: 26.0)
        label.qi_right = self.qi_right - 5.0
        addSubview(label)
        
        button.qi_top = self.qi_top
        button.qi_size = CGSize.init(width: 40.0, height: 40.0)
        button.qi_right = self.qi_right
        button.addTarget(self, action: #selector(buttonHandler(_:)), for: .touchUpInside)
        addSubview(button)
        
    }
    
    func startAnimation() {
        let keyFrameAni = CAKeyframeAnimation.init(keyPath: "transform.scale")
        keyFrameAni.values = [1.2,0.8,1.0]
        keyFrameAni.fillMode = .forwards
        keyFrameAni.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        label.layer.add(keyFrameAni, forKey: "qishare.doudong")
    }
    
    func changeCoverViewStatus() {
        switch coverType {
        case .default:
            button.isSelected = false
            label.text = ""
            label.layer.removeAnimation(forKey: "qishare.doudong")
            label.layer.borderColor = UIColor.white.cgColor
            label.layer.borderWidth = 1.5
            label.layer.cornerRadius = 13.0
            label.layer.masksToBounds = true
            label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.backgroundColor = UIColor.clear

        case .prohibit(_):
            button.isSelected = false
            label.text = ""
            label.layer.removeAnimation(forKey: "qishare.doudong")
            label.layer.borderColor = UIColor.white.cgColor
            label.layer.borderWidth = 1.5
            label.layer.cornerRadius = 13.0
            label.layer.masksToBounds = true
            label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            
        case let .selected(x):
            button.isSelected = true
            label.text = "\(x)"
            label.layer.borderWidth = 0.0
            label.layer.cornerRadius = 13.0
            label.layer.masksToBounds = true
            label.backgroundColor = UIColor.qi_colorWithHexString("#18C066")
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        }
    }
    
   
    @objc func buttonHandler( _ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            startAnimation()
        }
        coverButtonHandler?(sender.isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
