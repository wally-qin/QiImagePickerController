//
//  ViewController.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/11.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let buttton = UIButton.init(frame: .init(x: 0, y: 0, width: 100, height: 40))
        buttton.setTitle("选择图片", for: .normal)
        buttton.setTitleColor(.blue, for: .normal)
        buttton.center = view.center
        buttton.addTarget(self, action: #selector(pickerImage(_:)), for: .touchUpInside)
        view.addSubview(buttton)
        // Do any additional setup after loading the view.
    }
    
    @objc func pickerImage(_ : UIButton) {
        let pickerCtrl = QiImagePickerController.init(rootViewController: QiPhotoViewController.init())
        pickerCtrl.modalPresentationStyle = .fullScreen
        self.present(pickerCtrl, animated: true, completion: nil)
    }


}

