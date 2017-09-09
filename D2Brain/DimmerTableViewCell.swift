//
//  DimmerTableViewCell.swift
//  D2Brain
//
//  Created by Purvang Shah on 31/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
protocol DimmerTableCellDelegate:class{
    func RequestFaileDimmer(cell:DimmerTableViewCell)
}

class DimmerTableViewCell: UITableViewCell {

    @IBOutlet var DimmerNameLabel: UILabel!
    @IBOutlet var DimmerSlider: UISlider!
    @IBOutlet var DimmerSwitch: UISwitch!
    var DimmerNumber:String!
    var DimmerIP:String!
    var MachineName:String!
    weak var delegate:DimmerTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func RequestFailed(){
        delegate?.RequestFaileDimmer(cell: self)
    }
    
    @IBAction func SwitchValueChanged(_ sender: Any) {
        var slider = String(Int(DimmerSlider.value))
        var temp = DimmerNumber
        if(Int(temp!)!<10){
            temp = "0" + DimmerNumber
        }
        if(Int(DimmerSlider.value)<10){
            slider = "0"+String(Int(DimmerSlider.value))
        }
        
        if DimmerSwitch.isOn{
            sendRequest(url: "http://\(DimmerIP!)/cdmcr.cgi?", Parameter: "DM=\(temp!)01\(slider)")
        }else{
            sendRequest(url: "http://\(DimmerIP!)/cdmcr.cgi?", Parameter: "DM=\(temp!)00\(slider)")
        }

    }
    @IBAction func DimmerValueChanged(_ sender: Any) {
        print(Int(DimmerSlider.value))
        var slider = String(Int(DimmerSlider.value))
        if(Int(DimmerSlider.value)<10){
            slider = "0"+String(Int(DimmerSlider.value))
        }
        var temp = DimmerNumber
        if(Int(temp!)!<10){
            temp = "0" + DimmerNumber
        }
        if DimmerSwitch.isOn{
            sendRequest(url: "http://\(DimmerIP!)/cdmcr.cgi?", Parameter: "DM=\(temp!)01\(slider)")
        }
        else{
            sendRequest(url: "http://\(DimmerIP!)/cdmcr.cgi?", Parameter: "DM=\(temp!)00\(slider)")
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
                    self.DimmerSwitch.isOn = false
                    
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
