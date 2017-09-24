//
//  RoomViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 14/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RoomViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,XMLParserDelegate,RoomDetailSwitchDelegate,RoomDetailDimmerDelegate{

    @IBOutlet var DetailRoomCollectionView: UICollectionView!
    
    var Switches = Dictionary<String,Any>()
    var Changehandle: DatabaseHandle!
    var RemoveSwitchHandle: DatabaseHandle!
    var RoomName = ""
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    let uid = Auth.auth().currentUser?.uid
    var RefRoom : DatabaseReference!
    var RemoveSwitch : DatabaseReference!
    var Image : UIImage!
    @IBOutlet var BackGroundImage: UIImageView!
    var Switchkey = [String]()
    var DimmerKey = [String]()
    var SwitchState = Dictionary<String,Bool>()
    var DimmerState = Dictionary<String,Bool>()
    var DimmerValue = Dictionary<String,String>()
    var Name = ""
    var number = Int()
    var parser = XMLParser()
    var ArrayToAlert = [String]()
    var RoomKey = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        DetailRoomCollectionView.delegate = self
        
        BackGroundImage.image = Image
        RefRoom = ref.child("users/\(uid!)/Rooms/\(RoomKey)/Switches")
        self.Changehandle = RefRoom.observe(.childChanged, with: { (snapshot) in
            print("In room view snpashot name changed \(snapshot)")
            self.Switches.updateValue(snapshot.value as! String, forKey: snapshot.key)
            DispatchQueue.main.async {
                self.DetailRoomCollectionView.reloadData()
            }
        })
        self.RemoveSwitch = ref.child("users/\(uid!)/Rooms/\(RoomKey)Switches")
        self.RemoveSwitchHandle = RemoveSwitch.observe(.childRemoved, with: { (snapshot) in
            print("In room view snpashot name changed \(snapshot)")
            self.Switches.removeValue(forKey: snapshot.key)
            self.DetailRoomCollectionView.reloadData()
        })
        
        // Do any additional setup after loading the view.
        let Machines = MachinesViewController.MachineStore
        for (key,value) in Machines{
//            print("Machine Name \(key.MachineName)")
//            print("Machine Ip is \(key.MachineIP)")
            self.number = 1
            sendRequest(url:value.MachineIP, Parameter:"swcr.xml",MachineName: value.MachineName,MachineKey:key)
        }
      
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        if self.Changehandle != nil{
             RefRoom.removeObserver(withHandle: self.Changehandle)
            
            print("Removing change handle")
        }
        if self.RemoveSwitchHandle != nil{
            RemoveSwitch.removeObserver(withHandle: self.Changehandle)
            
            print("Removing Remove handle")
        }
    self.parser.abortParsing()
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomToSwitchView" {
            print("Segue called in room view")
            let controller = segue.destination as? SwitchTableViewController
            controller?.Select = Switches as! [String : String]
            controller?.RoomName = RoomName
            controller?.ToReturnImage = Image
            controller?.RoomKey = RoomKey
            controller?.isFromRoom = true
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override  func viewWillDisappear(_ animated: Bool) {
        //print("view disappearing")
    }
    
    func DataLoadFailed(MachineName:String){
        let alert = UIAlertController(title: "\(MachineName)", message: "Can't connect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (ok) in
            print("Machine Disable appeared")
                alert.dismiss(animated: true, completion: nil)
                if(!self.ArrayToAlert.isEmpty){
                    self.ArrayToAlert.remove(at: 0)
                    if(!self.ArrayToAlert.isEmpty){
                        self.DataLoadFailed(MachineName: self.ArrayToAlert[0])
                    }
                }
                
            }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func AlertRequestFailed(MachineName:String){
        let alert =  UIAlertController(title: MachineName, message: "Can't on", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (error) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func RequestFailedSwitch(cell: RoomDetailCollectionViewCell) {
        self.AlertRequestFailed(MachineName: cell.MachineName)
    }
    func RequestFailedDimmer(cell: RoomDetailDimmerViewCell) {
        self.AlertRequestFailed(MachineName: cell.MachineName)
    }
    
    @IBAction func BackButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       let keys = Switches.keys
        Switchkey.removeAll()
        DimmerKey.removeAll()
        for key in keys{
            let Separateswitch = key.components(separatedBy: "Switch")
            if(Separateswitch.count != 1){
                Switchkey.append(key)
            }else{
                DimmerKey.append(key)
            }
        }
        
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(section == 0){
            return Switchkey.count
        }else{
            return DimmerKey.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.section == 0){
             return CGSize(width: collectionView.bounds.size.width/4-10, height: collectionView.bounds.size.width/4-10)
        }
            return CGSize(width: collectionView.bounds.size.width, height: 70.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomSwitchCell", for: indexPath) as! RoomDetailCollectionViewCell

            //let key = Switches.popFirst()?.key
            let key = Switchkey[indexPath.row]
            let names = Switches[Switches.index(forKey: key)!].value
            cell.SwitchNameLabel.text = names as? String
            let SeparateStringSwitch = key.components(separatedBy: "Switch")
            let MachineIndex = MachinesViewController.MachineStore.index(forKey: (SeparateStringSwitch[0]))
            let Machine = MachinesViewController.MachineStore[MachineIndex!].value
            cell.SwitchIP = Machine.MachineIP
            cell.MachineName = Machine.MachineName
            cell.SwitchNumber = SeparateStringSwitch[1]
            if(SwitchState.index(forKey: key) != nil){
                cell.Switch.isOn = SwitchState[SwitchState.index(forKey: key)!].value
            }else{
                cell.Switch.isOn = false
            }
            
            cell.contentView.layer.cornerRadius = 9.0
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.masksToBounds = true
            
            cell.delegate = self
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomDimmerCell", for: indexPath) as! RoomDetailDimmerViewCell
            let key = DimmerKey[indexPath.row]
            let name = Switches[Switches.index(forKey: key)!].value
            let SeparateStringSwitch = key.components(separatedBy: "Dimmer")
            let MachineIndex = MachinesViewController.MachineStore.index(forKey: (SeparateStringSwitch[0]))
            let Machine = MachinesViewController.MachineStore[MachineIndex!].value
            cell.DimmerIP = Machine.MachineIP
            cell.MachineName = Machine.MachineName
            cell.DimmerNumber = SeparateStringSwitch[1]
            if(DimmerState.index(forKey: key) != nil){
                cell.DimmerSwitch.isOn = DimmerState[DimmerState.index(forKey: key)!].value
                let value = NumberFormatter().number(from: DimmerValue[DimmerValue.index(forKey: key)!].value)
                //print("value for dimmer is \((value?.floatValue)!)")
                cell.DimmerSlider.value = (value?.floatValue)!
            }else{
                cell.DimmerSwitch.isOn = false
                cell.DimmerSlider.value = 0.0
            }
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.masksToBounds = true
            cell.DimmerNameLabel.text = name as? String
            cell.delegate = self
            return cell
        }

    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("Printing  Start Element \(elementName)")
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("Printing End Element \(elementName)")
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("Found Characters \(string)")
        if (string != "\n"){
            if(string.characters.count >= 3){
                //Dimmer State and value to derived here
                let index = string.index(string.startIndex, offsetBy: 1)
                if(string[index] == "0"){
                    //print("Printing string of state of dimmer \(string[index])")
                    //DimmerState.append(false)
                    DimmerState.updateValue(false, forKey: "\(self.Name)Dimmer\(number)")
                }else{
                    DimmerState.updateValue(true, forKey: "\(self.Name)Dimmer\(number)")
                }
                let next = string.index(string.startIndex, offsetBy: 2)
//                print(string[Range(next..<string.endIndex)])
                DimmerValue.updateValue(string[Range(next..<string.endIndex)], forKey: "\(self.Name)Dimmer\(number)")
//                print("Printing self name \(self.Name)")
//                print("Priniting Number \(self.number)")
//                print("Printing Ip for machine \(self.tempIP)")
                number = number+1
            }else{
                if(string == "00"){
                    SwitchState.updateValue(false, forKey: "\(self.Name)Switch\(number)")
                }else{
                   SwitchState.updateValue(true, forKey: "\(self.Name)Switch\(number)")
//                    print("Printing self name \(self.Name)")
//                    print("Priniting Number \(self.number)")
//                    print("Printing Ip for machine \(self.tempIP)")
                }
                number = number+1
//                print("Number Increasede and number is now \(self.number)")
            }
        }
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error occured \(parseError)")
    }
    func sendRequest(url: String, Parameter: String ,MachineName:String,MachineKey:String){
        //print(url)
        //print(Parameter)
        let requestURL = URL(string:"http://\(url)/\(Parameter)")!
        print("\(requestURL)")
        let request = URLRequest(url: requestURL)
        //request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 5.0
        config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { data,response,error in
            guard let data = data else{
                print("Request failed \(String(describing: error))")
                //let make alert here
                DispatchQueue.main.async {
                    print("Machine Name in Send Request \(MachineName)")
                    print("Machine IP in send requset \(url)")
                    self.ArrayToAlert.append(MachineName)
                    self.DataLoadFailed(MachineName: MachineName)
                }
                return
            }
        let res = String(data: data,encoding:.utf8)
        print("raw respnose\(String(describing: res))")
        self.parser = XMLParser(data: data)
        self.parser.delegate = self
        self.Name = MachineKey
        let suc = self.parser.parse()
            if(suc){
                print("xml parsing done")
                if(Parameter == "swcr.xml"){
                    self.number = 1
                    self.sendRequest(url: url, Parameter: "dmcr.xml",MachineName: MachineName,MachineKey: MachineKey)
                }else{
                    //Reload Data here
                    DispatchQueue.main.async {
                        self.DetailRoomCollectionView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
}






