//
//  RoomDetailCollectionViewCell.swift
//  D2Brain
//
//  Created by Purvang Shah on 14/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

class RoomDetailCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var SwitchNameLabel: UILabel!
    var SwitchIP:String!
    var SwitchNumber:String!
    
    @IBAction func SwitchValueChnaged(_ SwitchValue: UISwitch) {
        var temp = SwitchNumber
        if(Int(temp!)!<10){
            temp = "0" + SwitchNumber
        }
        if SwitchValue.isOn {
            sendRequest(url: "http://\(SwitchIP!)/cswcr.cgi?", Parameter: "SW=\(temp!)01")
        }else{
            sendRequest(url: "http://\(SwitchIP!)/cswcr.cgi?", Parameter: "SW=\(temp!)00")
        }
        
    }
    func sendRequest(url: String, Parameter: String){
        print(url)
        print(Parameter)
        let requestURL = URL(string:"\(url)\(Parameter)")!
        print("\(requestURL)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task  =  session.dataTask(with: request){ data,response,error in
            guard let  data = data,(response != nil),error == nil else{return}
            print(NSString(data:data,encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }

}
