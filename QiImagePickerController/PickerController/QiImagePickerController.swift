//
//  QiImagePickerController.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/11.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiImagePickerController: UINavigationController {
    
    private lazy var tipLabel : UILabel = {
        
        let label = UILabel.init(frame: CGRect.init(x: 20, y: KStatusBarHeight + self.navigationBar.frame.height
            + 20, width: self.view.bounds.width - 40, height: 100))
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        if !QiImagePikerManager.manager.photoAuthorizationStatusIsAuthorized(firstSystemRequest: { (isAuthorized) in
            if isAuthorized {
                if let _ = self.tipLabel.superview {
                    self.tipLabel.removeFromSuperview()
                }
            } else {
                //未授权
                self.tipLabel.text = "请在iphone的“设置-隐私-照片”选项中，允许访问你的手机相册"
                self.view.addSubview(self.tipLabel)
            }
        }){
            //未授权
            self.tipLabel.text = "请在iphone的“设置-隐私-照片”选项中，允许访问你的手机相册"
            self.view.addSubview(self.tipLabel)
        }
        
        // Do any additional setup after loading the view.
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
