//
//  SwitchTableViewCell.swift
//  D2Brain
//
//  Created by Purvang Shah on 07/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
protocol SwitchTableCellDelegate:class{
    func RequestFailedSwitch(cell:SwitchTableViewCell)
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet var SwitchNameLabel: UILabel!
    @IBOutlet var CellSwitch: UISwitch!
    var SwitchNumber:String!
    var SwicthIP:String!
    var MachineName:String!
    weak var delegate : SwitchTableCellDelegate?
    
    @IBOutlet var SwitchNumberToDisplay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func RequestFailed(){
        delegate?.RequestFailedSwitch(cell: self)
    }
    
    
    @IBAction func SwitchValueChanged(_ SwitchValue: UISwitch) {
        var temp = SwitchNumber
        if(Int(temp!)!<10){
            temp = "0" + SwitchNumber
        }
        if SwitchValue.isOn {
             sendRequest(url: "http://\(SwicthIP!)/cswcr.cgi?", Parameter: "SW=\(temp!)01")
        }else{
             sendRequest(url: "http://\(SwicthIP!)/cswcr.cgi?", Parameter: "SW=\(temp!)00")
        }
        
        
    }
    
    func sendRequest(url: String, Parameter: String){
        print(url)
        print(Parameter)
        let requestURL = URL(string:"\(url)\(Parameter)")!
        print("\(requestURL)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 1.5
        config.timeoutIntervalForResource = 1.5
        let session = URLSession(configuration: config)
        let task  =  session.dataTask(with: request){ data,response,error in
            guard let  data = data,(response != nil),error == nil else{
                print("Error Succes is not here")
                DispatchQueue.main.sync {
                    self.RequestFailed()
                    self.CellSwitch.isOn = false
                }
                print(error!)
                print("UI updated")
                //Give alert here
                return
            }
            print(NSString(data:data,encoding: String.Encoding.utf8.rawValue)!)
            //print(response!)
        }
        task.resume()
    }
}
