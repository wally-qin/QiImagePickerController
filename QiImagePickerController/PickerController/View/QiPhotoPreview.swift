//
//  QiPhotoPreview.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
enum Qi_ImageType {
    case gif(Data),other(UIImage)
}

class QiPhotoPreview: UIScrollView {
    static var QiScrollHorizalEndNotificationKey : String = "com.qishare.QiPhotoPreview"
    private var imageView: GIFImageView
    private var singleGesture : UITapGestureRecognizer!
    private var doubleGesture : UITapGestureRecognizer!
    var imageSource : Qi_ImageType? {
        didSet {
            if case let .gif(gifData) = imageSource {
                imageView.animate(withGIFData: gifData)
            }
            if case let .other(image) = imageSource {
                imageView.stopAnimatingGIF()
                imageView.image = image
            }
        }
    }
    
    
    override init(frame: CGRect) {
        
        imageView = GIFImageView.init(frame: .zero)
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = .fast
        minimumZoomScale = 1.0
        maximumZoomScale = 3.0
        scrollsToTop = false
        alwaysBounceHorizontal = true
        delaysContentTouches = false
        delegate = self
        
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        //单击手势
        singleGesture = UITapGestureRecognizer.init(target: self, action: #selector(singleTapHandler(_:)))
        addGestureRecognizer(singleGesture)
        //双击
        doubleGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapHandler(_:)))
        doubleGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleGesture)
        //An example where this method might be called is when you want a single-tap gesture require that a double-tap gesture fail.
        singleGesture.require(toFail: doubleGesture)
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification), name: NSNotification.Name(rawValue: QiPhotoPreview.QiScrollHorizalEndNotificationKey), object: nil)
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
        NotificationCenter.default.post(name: Notification.Name.init("com.qishare.imagetap"), object: nil)
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

extension QiPhotoPreview : UIScrollViewDelegate {
   
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let szw = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let szh = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let w = imageView.frame.size.width
        let h = imageView.frame.size.height
        var rect = imageView.frame
        rect.origin.x = (szw > w) ? (szw-w)/2: 0
        rect.origin.y = (szh > h) ? (szh-h)/2: 0
        imageView.frame = rect;
    }
    
}
