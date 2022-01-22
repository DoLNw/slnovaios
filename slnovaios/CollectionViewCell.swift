//
//  CollectionViewCell.swift
//  slnovaios
//
//  Created by Jcwang on 2022/1/19.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.contentView.layer.cornerRadius = 12
//        self.contentView.layer.borderWidth = 2.5
//        self.contentView.layer.borderColor = UIColor.systemTeal.cgColor
//        self.contentView.layer.masksToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
}
