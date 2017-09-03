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

class RoomViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,XMLParserDelegate {

    @IBOutlet var DetailRoomCollectionView: UICollectionView!
    
    var Switches = Dictionary<String,Any>()
    var copySwitches : Dictionary<String,Any>!
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
    let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                        qos: .background,
                                        target: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        BackGroundImage.image = Image
        copySwitches = Switches
        RefRoom = ref.child("users/\(uid!)/Rooms/\(RoomName)")
        self.Changehandle = RefRoom.observe(.childChanged, with: { (snapshot) in
            print("In room view snpashot name changed \(snapshot)")
            self.Switches.updateValue(snapshot.value as! String, forKey: snapshot.key)
            self.DetailRoomCollectionView.reloadData()
        })
        self.RemoveSwitch = ref.child("users/\(uid!)/Rooms/\(RoomName)")
        self.RemoveSwitchHandle = RemoveSwitch.observe(.childRemoved, with: { (snapshot) in
            print("In room view snpashot name changed \(snapshot)")
            self.Switches.removeValue(forKey: snapshot.key)
            self.DetailRoomCollectionView.reloadData()
        })
//
//
        
        // Do any additional setup after loading the view.
        let Machines = DashBoardViewController.MachineStore.values
        for key in Machines{
            self.Name = key.MachineName
            self.number = 1
         backgroundQueue.async {
            let switchsend = URL(string:"http://\(key.MachineIP)/swcr.xml")
            self.parser = XMLParser(contentsOf: switchsend!)!
            self.parser.delegate = self
            let success = self.parser.parse()
            //sendRequest(url: "", Parameter: "")
            if(success){
                print("success")
                self.number = 1
                let dimmersend = URL(string:"http://\(key.MachineIP)/dmcr.xml")
                self.parser = XMLParser(contentsOf: dimmersend!)!
                self.parser.delegate = self
                let dmsuccess = self.parser.parse()
                //sendRequest(url: "", Parameter: "")
                        if(dmsuccess){
                            print("success")
                            DispatchQueue.main.async {
                                self.DetailRoomCollectionView.reloadData()
                            }
                        }else{
                            print("Failed")
                        }
                    }else{
                print("Failed")
            }
        }
        
//            self.number = 1
//            let dimmersend = URL(string:"http://192.168.1.25/dmcr.xml")
//            parser = XMLParser(contentsOf: dimmersend!)!
//            parser.delegate = self
//            let dmsuccess = parser.parse()
//            //sendRequest(url: "", Parameter: "")
//            if(dmsuccess){
//                print("success")
//                //self.tableView.reloadData()
//            }else{
//                SwitchState.removeAll()
//                print("Failed")
//            }

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
    
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RoomToSwitchView" {
            print("Segue called in room view")
            let controller = segue.destination as? SwitchTableViewController
            controller?.Select = Switches as! [String : String]
            controller?.RoomName = RoomName
            controller?.ToReturnImage = Image
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override  func viewWillDisappear(_ animated: Bool) {
        //print("view disappearing")
    }
    
    @IBAction func BackButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       let keys = Switches.keys
        for key in keys{
            let Separateswitch = key.components(separatedBy: "sw")
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
            let names = copySwitches[copySwitches.index(forKey: key)!].value
            cell.SwitchNameLabel.text = names as? String
            let SeparateStringSwitch = key.components(separatedBy: "sw")
            let MachineIndex = DashBoardViewController.MachineStore.index(forKey: (SeparateStringSwitch[0]))
            let Machine = DashBoardViewController.MachineStore[MachineIndex!].value
            cell.SwitchIP = Machine.MachineIP
            cell.SwitchNumber = SeparateStringSwitch[1]
            if(SwitchState.index(forKey: key) != nil){
                cell.Switch.isOn = SwitchState[SwitchState.index(forKey: key)!].value
            }else{
                cell.Switch.isOn = false
            }
            
            cell.contentView.layer.cornerRadius = 9.0
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.masksToBounds = true
            if(Switches.isEmpty){
                Switches = copySwitches
            }
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomDimmerCell", for: indexPath) as! RoomDetailDimmerViewCell
            let key = DimmerKey[indexPath.row]
            let name = copySwitches[copySwitches.index(forKey: key)!].value
            let SeparateStringSwitch = key.components(separatedBy: "dm")
            let MachineIndex = DashBoardViewController.MachineStore.index(forKey: (SeparateStringSwitch[0]))
            let Machine = DashBoardViewController.MachineStore[MachineIndex!].value
            cell.DimmerIP = Machine.MachineIP
            cell.DimmerNumber = SeparateStringSwitch[1]
            if(DimmerState.index(forKey: key) != nil){
                cell.DimmerSwitch.isOn = DimmerState[DimmerState.index(forKey: key)!].value
                let value = NumberFormatter().number(from: DimmerValue[DimmerValue.index(forKey: key)!].value)
                cell.DimmerSlider.value = (value?.floatValue)!
            }else{
                cell.DimmerSwitch.isOn = false
                cell.DimmerSlider.value = 0.0
            }
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.masksToBounds = true
            cell.DimmerNameLabel.text = name as? String
            
            return cell
        }

    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //print("Printing  Start Element \(elementName)")
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("Printing End Element \(elementName)")
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print("Found Characters \(string)")
        if (string != "\n"){
            if(string.characters.count >= 3){
                //Dimmer State and value to derived here
                let index = string.index(string.startIndex, offsetBy: 1)
                if(string[index] == "0"){
                    //print("Printing string of state of dimmer \(string[index])")
                    //DimmerState.append(false)
                    DimmerState.updateValue(false, forKey: "\(self.Name)dm\(number)")
                }else{
                    DimmerState.updateValue(false, forKey: "\(self.Name)dm\(number)")
                }
                let next = string.index(string.startIndex, offsetBy: 2)
                print(string[Range(next..<string.endIndex)])
                //DimmerValue.append(string[Range(next..<string.endIndex)])
                DimmerValue.updateValue(string[Range(next..<string.endIndex)], forKey: "\(self.Name)dm\(number)")
                number = number+1
            }else{
                if(string == "00"){
                    SwitchState.updateValue(false, forKey: "\(self.Name)sw\(number)")
                }else{
                   SwitchState.updateValue(true, forKey: "\(self.Name)sw\(number)")
                }
                number = number+1
            }
        }
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error occured \(parseError)")
    }
    

        
}
