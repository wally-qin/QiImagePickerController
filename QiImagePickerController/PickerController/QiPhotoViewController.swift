//
//  QiPhotoViewController.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/14.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import PhotosUI

class QiPhotoViewController: UIViewController {

    var currentAlbum : QiAlbumModel?
    var albums:[QiAlbumModel]?
    var columnCount : Int = 4
    
    private var titleButton : UIButton!
    private var collectionView : UICollectionView!
    private var flowLayout : UICollectionViewFlowLayout!
    private var bottomView : QiAssetPickerBottomView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        
        setupViews()
        
        QiImagePikerManager.manager.fetchAllAlbums { (albums) in
            self.albums = albums
            self.currentAlbum = albums.first
            self.titleButton.setTitle(self.currentAlbum?.assetName, for: .normal)
            self.titleButton.sizeToFit()
            if let navigationView = self.navigationItem.titleView {
                var frame = navigationView.frame
                frame.size.width = self.titleButton.frame.width + 20
                navigationView.frame = frame
                self.titleButton.center = navigationView.center
            }
            self.collectionView.reloadData()//异步操作
            DispatchQueue.main.async {
                //TODO 瀑布流倒置，请求所有
                if let assetArray = self.currentAlbum?.assetArray {
                    self.collectionView.scrollToItem(at: IndexPath.init(item: assetArray.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    private func setupNavigation() {
        let color_nav_title = UIColor.qi_colorWithHexString("#D5D6D7")
        let color_nav_titleViewBg = UIColor.qi_colorWithHexString("#494A4B")
        //let color_nav_iconviewBg = UIColor.qi_colorWithHexString("#A6A7A8")
        //由于导航栏存在模糊视图，且背景色为白色，故此处颜色为实际颜色323037 的平均值：19181b
        var mainHexColorStr = "0x313233"
        var mainHexColorValue : UInt = 0x323037
        mainHexColorValue = mainHexColorValue/2
        mainHexColorStr = String.init(format: "%.06lx", mainHexColorValue)
        let color_nav_bg = UIColor.qi_colorWithHexString(mainHexColorStr)
        
        //设置导航栏
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = color_nav_bg
        let cancel = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(cancelBarButtonItemClicked(_:)))
        cancel.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .regular),NSAttributedString.Key.foregroundColor : color_nav_title], for: .normal)
        self.navigationItem.leftBarButtonItem = cancel
        
        let navigationView = UIView.init(frame: .init(x: 0, y: 0, width: 0, height: 30))
        navigationView.backgroundColor = color_nav_titleViewBg
        titleButton = UIButton.init(frame: .zero)
        titleButton.setTitle(currentAlbum?.assetName ?? "照片", for: .normal)
        titleButton.titleLabel?.textColor = color_nav_title
        titleButton.sizeToFit()
        var frame = navigationView.frame
        frame.size.width = titleButton.frame.width + 20
        navigationView.frame = frame
        titleButton.center = navigationView.center
        titleButton.addTarget(self, action: #selector(titleButtonClicked(_:)), for: .touchUpInside)
        navigationView.addSubview(titleButton)
        
        navigationView.layer.cornerRadius = 15.0
        navigationView.layer.masksToBounds = true
        
        self.navigationItem.titleView = navigationView
        
    }
    
    private func setupViews() {
        
        let padding : CGFloat = 2.0
        let itemWidth = (self.view.bounds.width - CGFloat(columnCount + 1) * padding ) / CGFloat(columnCount)
        QiPhotoCell.imageSize =  CGSize.init(width: itemWidth * UIScreen.main.scale , height: itemWidth * UIScreen.main.scale)

        flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize = CGSize.init(width: itemWidth, height: itemWidth)
        flowLayout.sectionInset = UIEdgeInsets.init(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = padding
        flowLayout.minimumInteritemSpacing = 0
        let height = view.bounds.height - (navigationController?.toolbar.qi_height ?? 49.0) - iPhoneXSeriesBottomInset
        collectionView = UICollectionView.init(frame: .init(x: 0, y: 0, width: view.bounds.width , height: height), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.qi_colorWithHexString("0x313233")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(QiPhotoCell.self, forCellWithReuseIdentifier: NSStringFromClass(QiPhotoCell.self))
        collectionView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(collectionView)
        
        bottomView =  QiAssetPickerBottomView.init(frame: .init(x: 0, y: collectionView.qi_bottom, width: view.qi_width, height: (navigationController?.toolbar.qi_height ?? 49.0) + iPhoneXSeriesBottomInset))
        bottomView.sendButtonHandler = {
            
        }
        bottomView.previewButtonHandler = { [weak self] in
            guard let `self` = self else {return}
            let preview = QiAssetPreviewController()
            preview.currentIndex = 0
            var assetArray : [QiAssetModel] = [QiAssetModel]()
            QiImagePickerOperation.default.selectedAssets.forEach { (asset) in
                let assetModel = QiAssetModel.init()
                assetModel.asset = asset
                //TODO:1.是否需要过滤视频或者过滤图片 提供外部只选择图片或者只选择视频的接口
                assetModel.assetType = QiImagePikerManager.manager.convertPhotoAssetMediaTypeToQiAssetMediaType(asset: asset)
                //TODO:2.过滤尺寸不合适的图片
                assetArray.append(assetModel)
            }
            preview.assets = assetArray
            self.navigationController?.pushViewController(preview, animated: true)
        }
        view.addSubview(bottomView)
        
    }
    
    @objc func cancelBarButtonItemClicked(_:UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func titleButtonClicked(_ button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected {
            QiAlbumView.showAlbumView(frame: view.bounds, albums: albums, toView: view){[weak self](selectedAlbum) in
                guard let `self` = self else { return }
                self.currentAlbum = selectedAlbum
                self.collectionView.reloadData()
                DispatchQueue.main.async {
                    //TODO 瀑布流倒置，请求所有
                    if let assetArray = self.currentAlbum?.assetArray {
                        self.collectionView.scrollToItem(at: IndexPath.init(item: assetArray.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
                self.titleButton.setTitle(selectedAlbum.assetName ?? "照片", for: .normal)
                self.titleButton.sizeToFit()
                if let navigationView = self.navigationItem.titleView {
                    var frame = navigationView.frame
                    frame.size.width = self.titleButton.frame.width + 20
                    navigationView.frame = frame
                    self.titleButton.center = navigationView.center
                }
            }
        } else {
            QiAlbumView.dismissAlbumView()
        }
    }
    
    deinit {
        print("🔥")
    }

}

extension QiPhotoViewController : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let assetCount = currentAlbum?.assetCount {
            return assetCount
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(QiPhotoCell.self), for: indexPath) as? QiPhotoCell else {
            fatalError("cell获取失败")
        }
        //如何统计选中与不选中
        cell.coverButtonHandler = {[weak cell] (shouldSelected) in
            guard let wCell = cell,let asset = self.currentAlbum?.assetArray[indexPath.item].asset else { return  }
            if shouldSelected {
                if QiImagePickerOperation.default.tryAssetPick(asset: asset) {
                    wCell.coverType = .selected(QiImagePickerOperation.default.pickerOrderNum(asset: asset))
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: QiImagePickerOperation.PickerAssetsOrderNumberHasChanged), object: nil)
                } else {
                    print("选择资源异常")
                }
            } else {
                if QiImagePickerOperation.default.tryCancelAssetPick(asset: asset) {
                    wCell.coverType = .default
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: QiImagePickerOperation.PickerAssetsOrderNumberHasChanged), object: nil)
                } else {
                    print("选择资源异常")
                }
            }
        }
        if let assetModel = currentAlbum?.assetArray[indexPath.item] {
            cell.assetModel = assetModel
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let asset = self.currentAlbum?.assetArray[indexPath.item].asset else { return  }
        let num = QiImagePickerOperation.default.pickerOrderNum(asset: asset)
        if num == -1,!QiImagePickerOperation.default.shouldBePick {
           return
        } 
        let preview = QiAssetPreviewController()
        preview.currentIndex = indexPath.item
        preview.assets = currentAlbum?.assetArray
        navigationController?.pushViewController(preview, animated: true)
    }
    
    
}
