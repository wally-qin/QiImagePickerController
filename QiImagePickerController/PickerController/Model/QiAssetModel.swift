//
//  QiAssetModel.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/13.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import Photos

enum QiAssetMediaType {
    case photo,livePhoto,gifPhoto,video(duration:TimeInterval),audio
}


class QiAssetModel: NSObject {
    
    var asset : PHAsset?
    //是否选择
    //视频的时长
    var videoDuration : String?
    //资产类型
    var assetType : QiAssetMediaType = .photo {
        willSet{
            if case .video(duration: let time) = newValue {
                let timeLength : Int = Int(time)
                switch timeLength {
                case 0..<60:
                    videoDuration = "00" + ":" + String.init(format: "%.2d",timeLength)
                case 60..<3600:
                    videoDuration = String.init(format: "%.2d",timeLength/60) + ":" + String.init(format: "%.2d",timeLength%60)
                default:
                    videoDuration = String.init(format: "%.2d",timeLength/3600) + ":" + String.init(format: "%.2d",timeLength/60) + ":" + String.init(format: "%.2d",timeLength%60)
                }
            }
        }
    }
}
