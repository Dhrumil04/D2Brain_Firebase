//
//  Machine.swift
//  D2Brain
//
//  Created by Purvang Shah on 06/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

class Machine:NSObject{
    
    var MachineName : String
    var MachineIP : String
    var MachineSerialNumber:String
    var Switches:Dictionary<String,String>
    var Dimmers:Dictionary<String,String>
    
    init(Name:String,IP:String,Serial:String,Switches:Dictionary<String,String>,Dimmers:Dictionary<String,String>){
        self.MachineName = Name
        self.MachineIP = IP
        self.MachineSerialNumber = Serial
        self.Switches = Switches
        self.Dimmers = Dimmers
        super.init()
    }
}
