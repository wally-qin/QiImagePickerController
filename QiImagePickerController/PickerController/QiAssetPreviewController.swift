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
    var assets : [QiAssetModel]?
    var currentIndex : Int?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = "预览"
        view.backgroundColor = .white
        
        if let assets = self.assets,let index = currentIndex {
            previewer = QiAssetPagePreviewer.init(frame: view.bounds, dataSource: assets, atIndex: index)
            view.addSubview(previewer)
        }
        
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
