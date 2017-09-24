//
//  Room.swift
//  D2Brain
//
//  Created by Purvang Shah on 23/09/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

class Room:NSObject{
    var RoomName:String
    var Switches:Dictionary<String,String>
    
    init(RoomName:String,Switches:Dictionary<String,String>){
        self.RoomName = RoomName
        self.Switches = Switches
//        self.ImageURL = ImageURL
    }
}
