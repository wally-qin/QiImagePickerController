//
//  QiAlbumModel.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/13.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import Photos
class QiAlbumModel: NSObject {
    //相册中相片的数量
    var assetCount : Int?
    //相册名称
    var assetName : String?
    //相片数组
    var assetArray : [QiAssetModel] = [QiAssetModel]()
    
}
