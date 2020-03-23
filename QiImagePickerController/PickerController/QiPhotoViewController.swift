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
        //设置导航栏
        let cancel = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(cancelBarButtonItemClicked(_:)))
        cancel.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .regular),NSAttributedString.Key.foregroundColor : UIColor.blue], for: .normal)
        self.navigationItem.leftBarButtonItem = cancel
        
        let navigationView = UIView.init(frame: .init(x: 0, y: 0, width: 0, height: 30))
        navigationView.backgroundColor = UIColor.orange
        titleButton = UIButton.init(frame: .zero)
        titleButton.setTitle(currentAlbum?.assetName ?? "照片", for: .normal)
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
        collectionView = UICollectionView.init(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(QiPhotoCell.self, forCellWithReuseIdentifier: NSStringFromClass(QiPhotoCell.self))
        collectionView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(collectionView)
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
        let preview = QiAssetPreviewController()
        preview.currentIndex = indexPath.item
        preview.assets = currentAlbum?.assetArray
        navigationController?.pushViewController(preview, animated: true)
    }
    
    
}
