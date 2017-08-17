//
//  RoomsCollectionViewCell.swift
//  D2Brain
//
//  Created by Purvang Shah on 13/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

protocol RoomsCellDelegate : class{
    func delete(cell:RoomsCollectionViewCell)
}


class RoomsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var RoomName: UILabel!
    @IBOutlet var RoomImage: UIImageView!
    @IBOutlet var DeleteButtonBackGroundBlur: UIVisualEffectView!
    
    weak var delegate : RoomsCellDelegate?
    
    override func awakeFromNib() {
        self.RoomImage.layer.cornerRadius = 3.0
        self.RoomImage.clipsToBounds = true
        self.DeleteButtonBackGroundBlur.layer.cornerRadius = self.DeleteButtonBackGroundBlur.bounds.width / 2.0
        self.DeleteButtonBackGroundBlur.clipsToBounds = true
        self.DeleteButtonBackGroundBlur.isHidden = !isEditing
        
    }
    
    var isEditing : Bool = false {
        didSet{
            self.DeleteButtonBackGroundBlur.isHidden = !isEditing
        }
    }
    
    @IBAction func DeleteRoom(_ sender: Any) {
        
        delegate?.delete(cell: self)
    }
    

}
