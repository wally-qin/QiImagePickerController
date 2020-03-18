//
//  QiAlbumCell.swift
//  QiImagePickerController
//
//  Created by apple on 2020/2/19.
//  Copyright © 2020 QiShare. All rights reserved.
//

import UIKit

class QiAlbumCell: UITableViewCell {
    static var targetSize : CGSize!
    private var titleImageView: UIImageView!
    private var titleLabel : UILabel!
    var albumModel : QiAlbumModel? {
        didSet {
            if let album = albumModel,let assetName = album.assetName,let count = album.assetCount {
                let countString = "(" + "\(count)" + ")"
                let range = ((assetName + countString) as NSString).range(of: countString)
                let attributedText = NSMutableAttributedString.init(string: assetName + countString, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)])
                attributedText.setAttributes([NSAttributedString.Key.foregroundColor : UIColor.systemGray,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)], range:range)
                titleLabel.attributedText = attributedText
                
                if let asset = album.assetArray.last?.asset {
                    QiImagePikerManager.manager.requestImage(for: asset, targetSize: QiAlbumCell.targetSize) { [weak self](image, info) in
                        guard let `self` = self else {return}
                        self.titleImageView.image = image
                    }
                }
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleImageView = UIImageView.init(frame: .zero)
        titleImageView.backgroundColor = .cyan
        contentView.addSubview(titleImageView)
        titleLabel = UILabel.init(frame: .zero)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = UIColor.qi_colorWithHexString("0x18161D")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleImageView.frame = .init(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height)
        titleLabel.sizeToFit()
        titleLabel.qi_left = titleImageView.qi_right + 10
        titleLabel.qi_centerY = self.contentView.qi_centerY
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
