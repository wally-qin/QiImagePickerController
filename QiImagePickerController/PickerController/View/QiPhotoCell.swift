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
class QiPhotoCell: UICollectionViewCell {
    static var imageSize : CGSize!
    var imageView : UIImageView!
    var typeContentView : QiMediaTypeContentView!
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
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView.init(frame: self.bounds)
        addSubview(imageView)
        
        typeContentView = QiMediaTypeContentView.init(frame: .init(x: 0, y: self.bounds.height - 25.0, width: self.bounds.width, height: 25))
        typeContentView.backgroundColor = .clear
        addSubview(typeContentView)
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
