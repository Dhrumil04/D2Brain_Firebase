//
//  RoomDetailDimmerViewCell.swift
//  
//
//  Created by Purvang Shah on 31/08/17.
//
//

import UIKit

class RoomDetailDimmerViewCell: UICollectionViewCell {
    
    @IBOutlet var DimmerSlider: UISlider!
    
    @IBOutlet var DimmerSwitch: UISwitch!
    @IBOutlet var DimmerNameLabel: UILabel!
    var DimmerIP:String!
    var DimmerNumber:String!
}
