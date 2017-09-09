//
//  RoomDetailDimmerViewCell.swift
//  
//
//  Created by Purvang Shah on 31/08/17.
//
//

import UIKit
protocol RoomDetailDimmerDelegate:class{
    func RequestFailedDimmer(cell:RoomDetailDimmerViewCell)
}

class RoomDetailDimmerViewCell: UICollectionViewCell {
    
    @IBOutlet var DimmerSlider: UISlider!
    
    @IBOutlet var DimmerSwitch: UISwitch!
    @IBOutlet var DimmerNameLabel: UILabel!
    var DimmerIP:String!
    var DimmerNumber:String!
    weak var delegate : RoomDetailDimmerDelegate?
    var MachineName:String!
    
    @IBAction func DimmerSliderValueChanged(_ sender: Any) {
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
    func RequestFailed(){
        delegate?.RequestFailedDimmer(cell: self)
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
