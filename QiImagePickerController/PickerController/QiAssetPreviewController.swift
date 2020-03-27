//
//  QiAssetPreviewController.swift
//  QiImagePickerController
//
//  Created by QLY on 2020/3/18.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAssetPreviewController: UIViewController {
    //全封装
    
    private var previewer : QiAssetPagePreviewer!
    private var topView : QiAssetPreviewTopView!
    private var bottomView : QiAssetPreviewBottomView!
    var assets : [QiAssetModel]?
    var currentIndex : Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = "预览"
        view.backgroundColor = .white
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate

        setupViews()
        
    }
    
    func setupViews() {
        
        guard let assets = self.assets,let index = currentIndex else {
            return
        }
        
        previewer = QiAssetPagePreviewer.init(frame: view.bounds, dataSource: assets, atIndex: index)
        previewer.scrolledCompletion = {[weak self] (index) in
            guard let `self` = self else { return }
            self.topView.assetModel = self.assets?[index]
        }
        previewer.singleTapHandler = { [weak self] in
            guard let `self` = self else {return}
            UIView.animate(withDuration: 0.25) {
                self.topView.isHidden = !self.topView.isHidden
                self.bottomView.isHidden = !self.bottomView.isHidden
            }
        }
        view.addSubview(previewer)
        
        topView = QiAssetPreviewTopView.init(frame: .init(x: 0, y: 0, width: view.bounds.width, height: KStatusBarHeight + (navigationController?.navigationBar.frame.height ?? 44.0)))
        topView.assetModel = assets[index]
        topView.navigationBack = { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        view.addSubview(topView)
        let y = view.qi_height - ((navigationController?.toolbar.qi_height ?? 49.0) + iPhoneXSeriesBottomInset)
        bottomView = QiAssetPreviewBottomView.init(frame: .init(x: 0, y: y, width: view.qi_width, height: (navigationController?.toolbar.qi_height ?? 49.0) + iPhoneXSeriesBottomInset))
        view.addSubview(bottomView)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
