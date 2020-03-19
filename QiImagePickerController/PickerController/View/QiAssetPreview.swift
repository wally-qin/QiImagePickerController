//
//  QiAssetPreview.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import Photos
class QiAssetPreview: UIView {
    
    var assetModel : QiAssetModel? {
        didSet {
          changeAssetForPreview()
        }
    }
    //图片和gif
    private lazy var photoPreview : QiPhotoPreview = {
        let preview = QiPhotoPreview.init(frame: bounds)
        return preview
    }()
    //动图
    private lazy var livePhotoPreview : QiLivePhotoPreview = {
        let preview = QiLivePhotoPreview.init(frame: bounds)
        return preview
    }()
    //视频
    private lazy var videoPreview : QiVideoPreview = {
        let preview = QiVideoPreview.init(frame: bounds)
        return preview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoPreview)
        addSubview(videoPreview)
        addSubview(livePhotoPreview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoPreview.frame = bounds
        livePhotoPreview.frame = bounds
        videoPreview.frame = bounds
    }
    
    func changeAssetForPreview() -> Void {
        guard let model = assetModel,let asset = assetModel?.asset else { return  }
        switch model.assetType {
        case .gifPhoto:
            previewGifImage(asset: asset)
        case .photo:
            previewImage(asset: asset)
        case .livePhoto:
            previewLivePhoto(asset: asset)
        case .video(_):
            previewVideo(asset: asset)
        case .audio:
            print("audio")
        }
    }
    
    func previewImage(asset:PHAsset) {
        videoPreview.isHidden = true
        livePhotoPreview.isHidden = true
        photoPreview.isHidden = false
        bringSubviewToFront(photoPreview)
        QiImagePikerManager.manager.requestPreviewImage(for: asset) { [weak self](image, info) in
            guard let `self` = self else {return}
            guard let image = image else {return}
            self.photoPreview.imageSource = .other(image)
        }
    }
    func previewGifImage(asset:PHAsset) {
        videoPreview.isHidden = true
        livePhotoPreview.isHidden = true
        photoPreview.isHidden = false
        bringSubviewToFront(photoPreview)
        QiImagePikerManager.manager.requestImageData(for: asset) { [weak self](data, some, orientation, info) in
            guard let `self` = self else {return}
            guard let data = data else {return}
            self.photoPreview.imageSource = .gif(data)
        }
    }
    func previewVideo(asset:PHAsset) {
        photoPreview.isHidden = true
        livePhotoPreview.isHidden = true
        videoPreview.isHidden = false
        bringSubviewToFront(videoPreview)
        QiImagePikerManager.manager.requestPlayerItem(for: asset) { [weak self] (playerItem, info) in
            guard let `self` = self else {return}
            self.videoPreview.playerItem = playerItem
        }
    }
    func previewLivePhoto(asset:PHAsset) {
        photoPreview.isHidden = true
        videoPreview.isHidden = true
        livePhotoPreview.isHidden = false
        bringSubviewToFront(livePhotoPreview)
        QiImagePikerManager.manager.requestPreviewLiveImage(for: asset) { [weak self] (livePhoto, info) in
            guard let `self` = self else {return}
            self.livePhotoPreview.livePhoto = livePhoto
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

