//
//  QiLivePhotoPreview.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import PhotosUI
class QiLivePhotoPreview: UIScrollView {
    static var QiScrollHorizalEndNotificationKey : String = "com.qishare.QiLivePhotoPreview"
    private var livePhotoView : PHLivePhotoView!
    private var singleGesture : UITapGestureRecognizer!
    private var doubleGesture : UITapGestureRecognizer!
    var livePhoto : PHLivePhoto? {
        didSet {
            if let livePhoto = livePhoto {
                livePhotoView.livePhoto = livePhoto
                livePhotoView.startPlayback(with: .full)
            }
        }
    }
    override init(frame: CGRect) {
        
        livePhotoView = PHLivePhotoView.init(frame: .zero)
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = .fast
        minimumZoomScale = 1.0
        maximumZoomScale = 3.0
        scrollsToTop = false
        delaysContentTouches = false
        alwaysBounceHorizontal = true
        delegate = self
        
        livePhotoView.frame = bounds
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.backgroundColor = .clear
        livePhotoView.isMuted = false
        addSubview(livePhotoView)
       
        //单击手势
        singleGesture = UITapGestureRecognizer.init(target: self, action: #selector(singleTapHandler(_:)))
        addGestureRecognizer(singleGesture)
        
        doubleGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapHandler(_:)))
        doubleGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleGesture)
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification), name: NSNotification.Name(rawValue: QiLivePhotoPreview.QiScrollHorizalEndNotificationKey), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receiveNotification() {
        guard zoomScale != minimumZoomScale else {
            return
        }
        self.setZoomScale(minimumZoomScale, animated: false)
        
    }
    
    @objc func singleTapHandler(_: UITapGestureRecognizer) {
        
    }
    
    @objc func doubleTapHandler(_ sender : UITapGestureRecognizer) {
        let point = sender.location(in: self)
        if (self.zoomScale == self.maximumZoomScale){
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else{
            self.zoom(to: CGRect(x: point.x, y: point.y, width: 1, height: 1), animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension QiLivePhotoPreview : UIScrollViewDelegate {
   
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return livePhotoView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let szw = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let szh = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let w = livePhotoView.frame.size.width
        let h = livePhotoView.frame.size.height
        var rect = livePhotoView.frame
        rect.origin.x = (szw > w) ? (szw-w)/2: 0
        rect.origin.y = (szh > h) ? (szh-h)/2: 0
        livePhotoView.frame = rect;
    }
    
}
