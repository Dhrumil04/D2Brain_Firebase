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
    func ChangeImage(cell:RoomsCollectionViewCell)
    func RenameRoom(cell:RoomsCollectionViewCell)
    func MasterOnOff(cell:RoomsCollectionViewCell,OnOff:String)
}


class RoomsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var RoomName: UILabel!
    @IBOutlet var RoomImage: UIImageView!
    @IBOutlet var DeleteButtonBackGroundBlur: UIVisualEffectView!
    
    @IBOutlet var RoomEditBackGroundBlur: UIVisualEffectView!
    
    @IBOutlet var MasterSwitchOffBackGroundBlur: UIVisualEffectView!
    
    @IBOutlet var MasterSwitchOnBackGroundBlur: UIVisualEffectView!
    
    weak var delegate : RoomsCellDelegate?
    var Switches:Dictionary<String,String>!
    var RoomKey = String()
    
    override func awakeFromNib() {
        self.RoomImage.layer.cornerRadius = 3.0
        self.RoomImage.clipsToBounds = true
        self.DeleteButtonBackGroundBlur.layer.cornerRadius = self.DeleteButtonBackGroundBlur.bounds.width / 2.0
        self.DeleteButtonBackGroundBlur.clipsToBounds = true
        self.MasterSwitchOnBackGroundBlur.layer.cornerRadius = self.MasterSwitchOnBackGroundBlur.bounds.width / 2.0
        self.MasterSwitchOnBackGroundBlur.clipsToBounds = true
        self.MasterSwitchOffBackGroundBlur.layer.cornerRadius = self.MasterSwitchOffBackGroundBlur.bounds.width / 2.0
        self.MasterSwitchOffBackGroundBlur.clipsToBounds = true
        self.DeleteButtonBackGroundBlur.isHidden = !isEditing
        self.RoomEditBackGroundBlur.isHidden = !isEditing
        super.awakeFromNib()
    }
    
    var isEditing : Bool = false {
        didSet{
            self.DeleteButtonBackGroundBlur.isHidden = !isEditing
            self.RoomEditBackGroundBlur.isHidden = !isEditing
        }
    }
    
    @IBAction func DeleteRoom(_ sender: Any) {
        delegate?.delete(cell: self)
    }
    
    @IBAction func MasterOff(_ sender: Any) {
        delegate?.MasterOnOff(cell: self,OnOff: "00")
    }
    @IBAction func MasterOn(_ sender: Any) {
        delegate?.MasterOnOff(cell: self, OnOff: "01")
    }
    
    
    @IBAction func ChangeImageOfRoom(_ sender: Any) {
        delegate?.ChangeImage(cell: self)
    }
    
    @IBAction func RenameRoom(_ sender: Any) {
        delegate?.RenameRoom(cell: self)
    }
    

}
