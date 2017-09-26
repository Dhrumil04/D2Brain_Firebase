//
//  MachineTableViewCell.swift
//  D2Brain
//
//  Created by Purvang Shah on 06/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

class MachineTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet var MachineName: UILabel!
    @IBOutlet var MachineIP: UILabel!
    @IBOutlet var MachineSerialNumber: UILabel!
    var key:String!
    @IBAction func DeleteMachine(_ sender: Any) {
        print(self)
    }
    
   
}
