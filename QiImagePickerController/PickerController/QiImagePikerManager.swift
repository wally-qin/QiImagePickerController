//
//  QiImagePikerManager.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/14.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import Photos
class QiImagePikerManager: NSObject {
    
    static let manager = QiImagePikerManager()
    var imageManager : PHCachingImageManager = PHCachingImageManager()
    //MARK:用户是否授权相册
    func photoAuthorizationStatusIsAuthorized(firstSystemRequest:((_ : Bool)->Void)?) -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
        case .denied:
            //被拒绝
            print("请在iphone的“设置-隐私-照片”选项中，允许访问你的手机相册")
            return false
        case .notDetermined:
            //去请求权限
            PHPhotoLibrary.requestAuthorization { [weak self](status) in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    if let firstSystemRequest = firstSystemRequest {
                        firstSystemRequest(self.photoAuthorizationStatusIsAuthorized(firstSystemRequest: nil))
                    }
                }
            }
            return false
        default:
            return false
        }
    }
    
    
    //MARK:获取模型化的数据
    func fetchAllAlbums(completion:@escaping ((_ : [QiAlbumModel])->Void)){
        
        let fetchAlbumData = {
            //请求相册数据
                   let option = PHFetchOptions.init()
                   //时间排序由近到远
                   option.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
                   //设置获取的资源类型
                   //option.predicate = NSPredicate.init(format: "mediaType == \(PHAssetMediaType.video)")
                   //option.predicate = NSPredicate.init(format: "mediaType == \(PHAssetMediaType.image)")
                   
                   /*PHAssetCollectionType
                    .smartAlbum:只能相册
                    .album:相册
                    */
                   
                   /*PHAssetCollectionSubtype
                    
                    .albumRegular:在“照片”应用中创建的相册。
                    .albumSyncedEvent:从iPhoto同步到设备的事件。
                    .albumSyncedFaces:从iPhoto同步到设备的Faces组。
                    .albumSyncedAlbum:从iPhoto同步到设备的相册。
                    .albumImported:从相机或外部存储器导入的相册。
                    
                    PHAssetCollectionType.album专用，关于icloud相册：
                    
                    .albumMyPhotoStream:用户的个人iCloud照片流。
                    .albumCloudShared:iCloud共享照片流。
                    
                    PHAssetCollectionType.smartAlbum专用：
                    
                    .smartAlbumGeneric:没有更多特定子类型的智能相册。
                    .smartAlbumPanoramas:将照片库中所有全景照片分组的智能相册。
                    .smartAlbumVideos:将相册中所有视频资产分组的智能相册。
                    .smartAlbumFavorites:智能相册，将用户标记为收藏的所有资产进行分组。
                    .smartAlbumTimelapses:智能相册，将照片库中的所有延时视频分组。
                    .smartAlbumAllHidden:智能相册，将“照片”应用中“瞬间”视图中隐藏的所有资产分组。
                    .smartAlbumRecentlyAdded:智能相册，对最近添加到照片库的资产进行分组。
                    .smartAlbumBursts: 智能相册，将照片库中所有突发的照片序列分组。
                    .smartAlbumSlomoVideos:智能相册，将照片库中的所有慢动作视频进行分组。
                    .smartAlbumUserLibrary:智能相册，该相册将源自用户自己的库的所有资产进行分组（与iCloud共享相册中的资产相对）。
                    .smartAlbumSelfPortraits:智能相册，该相册将使用设备的前置摄像头捕获的所有照片和视频分组。
                    .smartAlbumScreenshots:智能相册，将使用设备的屏幕快照功能捕获的所有图像分组。
                    .smartAlbumDepthEffect:智能相册，该相册将在兼容设备上使用“深度效果”相机模式拍摄的所有图像分组。
                    .smartAlbumLivePhotos:将所有Live Photo资产分组的智能相册。
                    .smartAlbumAnimated:将所有图像动画资产分组的智能相册。
                    .smartAlbumLongExposures: 智能相册，该相册将启用“长时间曝光”变化的所有实时照片资产分组。
                    .smartAlbumUnableToUpload:
                    
                    若不在乎额外的subType .any:表示所有可能的子类型的位掩码。
                    */
                   
                   let myPhotoStreamAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: nil)
                   let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                   //从iphoto同步到设备的相册
                   let syncedAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: nil)
                   //iCloud共享照片流。
                   let sharedAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: nil)
                   //所有相册
                   var allAlbums : [PHFetchResult<PHAssetCollection>]
                   
                   //从用户创建的相册和文件夹的照片库层次结构的根目录检索集合
                   if let topLevelUserCollections = PHAssetCollection.fetchTopLevelUserCollections(with: nil) as? PHFetchResult<PHAssetCollection>   {
                       allAlbums = [myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbum,sharedAlbums]
                   } else {
                       allAlbums = [myPhotoStreamAlbum,smartAlbums,syncedAlbum,sharedAlbums]
                   }
                   var albums : [QiAlbumModel] = [QiAlbumModel]()
                   for fetchResult in allAlbums {
                       fetchResult.enumerateObjects({[weak self] (assetCollection, index, stop) in
                           guard let `self` = self else {return}
                           guard let albumModel = self.convertFetchedPhotoAssetCollectionToQiAlbumModel(assetCollection: assetCollection, option: option) else {return}
                           //添加时，拍的照片放在最前面，是不是相册的数据记录 涉及照相机界面放置？ 需不需要 直接获取图片资源
                           if assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                               albums.insert(albumModel, at: 0)//拍的照片优先靠前
                           } else {
                               albums.append(albumModel)
                           }
                       })
                   }
                   completion(albums)
        }
        //设置授权
        if photoAuthorizationStatusIsAuthorized(firstSystemRequest: { (isAuthorized) in
            //
            if isAuthorized {
                fetchAlbumData()
            } else {
                //未授权
            }
        }){
            fetchAlbumData()
        } else {
            //未授权
        }

        
    }
    
    //MARK:相册模型化
    func convertFetchedPhotoAssetCollectionToQiAlbumModel(assetCollection:PHAssetCollection,option: PHFetchOptions) -> QiAlbumModel? {
        //预估过滤不是相机胶卷（拍照保存的相册）的空相册。注：8.0.0 ~ 8.0.2系统拍照后的图片会保存在最近添加中.smartAlbumRecentlyAdded忽略10以下
        var albumModel:QiAlbumModel?
        if assetCollection.estimatedAssetCount >= 0 || assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
            let result = PHAsset.fetchAssets(in: assetCollection, options: option)
            //实际数量过滤,
            if result.count > 0 && assetCollection.assetCollectionSubtype != .smartAlbumAllHidden {
                albumModel = QiAlbumModel.init()
                albumModel?.assetName = assetCollection.localizedTitle
                albumModel?.assetCount = result.count
                //图片数组
                albumModel?.assetArray = self.convertFetchedPhotoAssetToQiAssetModel(fetchResult: result)
                print(assetCollection.localizedTitle! + "---" + "\(result.count)")
            }
        }
        return albumModel
        
    }
    //MARK:相片模型化
    func convertFetchedPhotoAssetToQiAssetModel(fetchResult:PHFetchResult<PHAsset>)->[QiAssetModel] {
        
        var assetModelArray : [QiAssetModel] = [QiAssetModel]()
        fetchResult.enumerateObjects {[weak self] (asset, index, stop) in
            let assetModel = QiAssetModel.init()
            assetModel.asset = asset
            //TODO:1.是否需要过滤视频或者过滤图片 提供外部只选择图片或者只选择视频的接口
            assetModel.assetType = self!.convertPhotoAssetMediaTypeToQiAssetMediaType(asset: asset)
            //TODO:2.过滤尺寸不合适的图片
            assetModelArray.append(assetModel)
        }
        
        return assetModelArray
    }
    //MARk:通过PHAsset获取指定大小的图片
    @discardableResult
    func requestImage(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        
        /*@params options:用于指定如何处理照片请求，比如预处理返回图像尺寸，图片下载数据的输送模式和下载图像进度信息，
         如果PHImageRequestOptions.isSynchronous = No或者此参数为nil 则resultHandler可能被调用1次或多次。
         在这种情况下 ，请求的结果将在主线程上异步回调resultHandler，但是如果deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic（默认就是）则代表若有任何图像数据立即可用，则在调用线程上同步调用resultHandler。
         若PHImageRequestOptions.isSynchronous = YES，则在调用线程上同步回调resultHandler一次。同步请求是无法取消的.
         @param resultHandler 根据PHImageRequestOptions options参数中指定的选项，在当前线程上同步或在主线程上异步调用一次或多次的block.*/
        let options = PHImageRequestOptions.init()
        //按照微信显示方式请求
        options.resizeMode = .exact
        options.normalizedCropRect = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //还可以有进度
        return imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options, resultHandler: resultHandler)
    }
    
    func convertPhotoAssetMediaTypeToQiAssetMediaType(asset:PHAsset) -> QiAssetMediaType {
        var assetType : QiAssetMediaType = .photo
        if asset.mediaType == .audio {
            assetType = .audio
        } else if asset.mediaType == .video {
            assetType = .video(duration: asset.duration)
        } else if asset.mediaType == .image {
            if asset.playbackStyle == .livePhoto {
                assetType = .livePhoto
            } else if asset.playbackStyle == .imageAnimated  {
                assetType = .gifPhoto
            }
        } else {
            assetType = .photo
        }
        return assetType
    }
}
