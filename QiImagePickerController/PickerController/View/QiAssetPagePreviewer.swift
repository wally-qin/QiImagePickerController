//
//  QiAssetPagePreviewer.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAssetPagePreviewer: UIView {
    
    private var dataSource : [QiAssetModel]
    private var currentIndex : Int
    private var collectionView : UICollectionView!
    init(frame: CGRect,dataSource : [QiAssetModel],atIndex:Int) {
        self.dataSource = dataSource
        self.currentIndex = atIndex
        super.init(frame: frame)
        setupCollectionViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    private func setupCollectionViews(){
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize.init(width: bounds.width, height: bounds.height - 64.0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        collectionView = UICollectionView.init(frame: bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(QiAssetPreviewCell.self, forCellWithReuseIdentifier: NSStringFromClass(QiAssetPreviewCell.self))
        addSubview(collectionView)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {return}
            self.collectionView.scrollToItem(at: IndexPath.init(row: self.currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension QiAssetPagePreviewer : UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(QiAssetPreviewCell.self), for: indexPath) as? QiAssetPreviewCell else {
            fatalError("Cell复用出错")
        }
        cell.assetModel = dataSource[indexPath.row]
        return cell
    }
    
    
}
extension QiAssetPagePreviewer : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notification.Name.init(QiVideoPreview.QiScrollHorizalNotificationKey), object: nil)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            NotificationCenter.default.post(name: Notification.Name.init(QiPhotoPreview.QiScrollHorizalEndNotificationKey), object: nil)
             NotificationCenter.default.post(name: Notification.Name.init(QiLivePhotoPreview.QiScrollHorizalEndNotificationKey), object: nil)
        }
    }
    
}
