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
    private var topView : QiAssetPickerTopView!
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
        view.addSubview(previewer)
        
        topView = QiAssetPickerTopView.init(frame: .init(x: 0, y: 0, width: view.bounds.width, height: KStatusBarHeight + (navigationController?.navigationBar.frame.height ?? 44.0)))
        topView.assetModel = assets[index]
        topView.navigationBack = { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        view.addSubview(topView)
        
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
