//
//  QiAlbumView.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAlbumView: UIView {
    
    static var albumView:QiAlbumView = QiAlbumView.init(frame: .zero)
    static private var toView:UIView!
    class func showAlbumView(frame:CGRect,albums:[QiAlbumModel]?,toView:UIView,selected:((_ : QiAlbumModel)-> Void)?){
        self.toView = toView
        albumView.frame = frame
        if let albums = albums {
            albumView.albums = albums
            albumView.choosedAlbum = {(album)in
                selected?(album)
                dismissAlbumView()
            }
        }
        albumView.backgroundColor = .clear
        toView.addSubview(albumView)
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            if let tableView = albumView.tableView {
                tableView.frame.origin.y = 0
            }
            albumView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }, completion: nil)
    }
    
    class func dismissAlbumView(){
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
            if let tableView = albumView.tableView {
                tableView.frame.origin.y = 100.0 - albumView.bounds.height
            }
            albumView.backgroundColor = UIColor.clear
        }) { (completion) in
            albumView.removeFromSuperview()
        }
    }

    private var tableView : UITableView?
    var choosedAlbum:((_ : QiAlbumModel)-> Void)?
    var albums:[QiAlbumModel]! {
        didSet{
            if albums != oldValue && albums.count > 0{
                setupTablView()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTablView(){
        QiAlbumCell.targetSize = CGSize.init(width: 60.0 * UIScreen.main.scale, height: 60.0 * UIScreen.main.scale)
        tableView = UITableView.init(frame: .init(x: 0, y: 100 - bounds.height, width: bounds.width, height: bounds.height - 100))
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.rowHeight = 60.0
        tableView?.estimatedSectionFooterHeight = 0.0
        tableView?.estimatedSectionHeaderHeight = 0.0
        tableView?.contentInsetAdjustmentBehavior = .automatic
        tableView?.backgroundColor = UIColor.qi_colorWithHexString("0x18161D")
        tableView?.separatorStyle = .singleLine
        tableView?.layoutMargins = .zero
        tableView?.register(QiAlbumCell.self, forCellReuseIdentifier: NSStringFromClass(QiAlbumCell.self))
        addSubview(tableView!)
    }

}
extension QiAlbumView : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = albums?.count {
            return count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = albums[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(QiAlbumCell.self), for: indexPath) as? QiAlbumCell else {
            fatalError("cell复用类型错误")
        }
        cell.albumModel = model
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let model = albums[indexPath.row]
        if let choosedAlbum = choosedAlbum {
            choosedAlbum(model)
        }
    }
}
