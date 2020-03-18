//
//  QiAlbumViewController.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/11.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit
import Photos

class QiAlbumViewController: UIViewController {

    private var tableView : UITableView!
    
    private var albums:[QiAlbumModel] = [QiAlbumModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        QiImagePikerManager.manager.fetchAllAlbums { (albums) in
            print(albums)
            self.albums = albums
            self.tableView.reloadData()
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTablView()
        
        // Do any additional setup after loading the view.
    }
    
    func setupTablView(){
        tableView = UITableView.init(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50.0
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.backgroundColor = .gray
        tableView.separatorStyle = .singleLine
        tableView.layoutMargins = .zero
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        view.addSubview(tableView)
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

extension QiAlbumViewController : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = albums[indexPath.row]
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = model.assetName! + " " + "\(model.assetCount!)"
        return cell
    }
}
