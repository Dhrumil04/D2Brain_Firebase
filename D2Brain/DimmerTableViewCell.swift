//
//  DimmerTableViewCell.swift
//  D2Brain
//
//  Created by Purvang Shah on 31/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

class DimmerTableViewCell: UITableViewCell {

    @IBOutlet var DimmerNameLabel: UILabel!
    
    @IBOutlet var DimmerSlider: UISlider!
    
    @IBOutlet var DimmerSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
