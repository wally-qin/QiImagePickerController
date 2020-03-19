//
//  QiVideoPreview.swift
//  QiImagePickerController
//
//  Created by qinwanli on 2020/3/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import AVFoundation

class QiVideoPreview: UIScrollView {
    static var QiScrollHorizalNotificationKey : String = "com.qishare.QiVideoPreview"
    private var player : AVPlayer!
    private var playerLayer : AVPlayerLayer!
    private var playButton : UIButton!
    private var singleGesture : UITapGestureRecognizer!
    var playerItem : AVPlayerItem? {
        didSet {
            if let playerItem = playerItem {
                player.replaceCurrentItem(with: playerItem)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        player = AVPlayer.init(playerItem: nil)
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = bounds
        layer.addSublayer(playerLayer)
        
        playButton = UIButton.init(frame: .init(x: 0, y: 0, width: 64, height: 64))
        playButton.setImage(UIImage.init(named: "icon_play"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonHandler(_:)), for: .touchUpInside)
        playButton.center = center
        addSubview(playButton)
        //单击手势
        singleGesture = UITapGestureRecognizer.init(target: self, action: #selector(singleTapHandler(_:)))
        addGestureRecognizer(singleGesture)
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification), name: NSNotification.Name(rawValue: QiVideoPreview.QiScrollHorizalNotificationKey), object: nil)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func receiveNotification() {
        if playButton.isSelected {
            playButton.isSelected = false
            playButton.isHidden = false
            stopAndResetPlayer()
        }
    }
    
    @objc func playButtonHandler(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.isHidden = true
            player.play()
        } else {
            sender.isHidden = false
            stopAndResetPlayer()
        }
    }
    @objc func singleTapHandler(_: UITapGestureRecognizer) {
        playButton.isSelected = !playButton.isSelected
        if playButton.isSelected {
            playButton.isHidden = true
            player.play()
        } else {
            playButton.isHidden = false
            stopAndResetPlayer()
        }
    }
    
    func stopAndResetPlayer(){
        player.pause()
        player.seek(to: CMTime.init(seconds: 0.0, preferredTimescale: 1000))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
