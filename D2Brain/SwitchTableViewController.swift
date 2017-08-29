//
//  SwitchTableViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 07/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
class SwitchTableViewController: UITableViewController,XMLParserDelegate {

    //MARK: - Variable Declaration
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    
    let Sref = Storage.storage().reference(forURL: "gs://d2brain-87137.appspot.com")
    var SwitchStore = [Dictionary<String, Any>]()
    var MachinesStore = [String]()
    static var IPStore = [String]()
    var newData:Bool!
    var hasSelect = false
    var previousCount:Int!
    @IBOutlet var SegmentedControl: UISegmentedControl!
    var Select = [String:String]()
    var button = UIBarButtonItem()
    var RoomName:String = ""
    var UploadImage:UIImage!
    var parser = XMLParser()
    var SwitchState = [Bool]()
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Swicth Table View Did Load")
        if (!Select.isEmpty){
            print("Printing Select \(Select)")
            self.hasSelect = true
        }
        print(RoomName)
        if(RoomName != ""){
            button =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RoomCreated(sender:)))
            self.navigationItem.setRightBarButton(button, animated: true)
        }
        if(RoomName == ""){
            let send = URL(string:"http://192.168.1.25/swcr.xml")
            parser = XMLParser(contentsOf: send!)!
            parser.delegate = self
            let success = parser.parse()
            
            //sendRequest(url: "", Parameter: "")
            if(success){
                print("success")
                self.tableView.reloadData()
            }else{
                print("Failed")
            }
        }
               self.newData = false
    }
    override func viewWillAppear(_ animated: Bool) {
        print("Switch Table View Will Appear")
         print("New Data value is \(self.newData)")
        if((!newData)){
            DataFetch2()
            previousCount = 0
            SegmentedControl.removeAllSegments()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("Switch Table view is going to be disapear")
    }
    //MARK:- Segment Controlll Value changed
    @IBAction func SegmentControlValueChanged(_ sender: Any) {
        if(RoomName == ""){
            let send = URL(string:"http://192.168.1.25/swcr.xml")
            parser = XMLParser(contentsOf: send!)!
            parser.delegate = self
            let success = parser.parse()
            //sendRequest(url: "", Parameter: "")
            if(success){
                print("success")
                self.tableView.reloadData()
            }else{
                print("Failed")
            }
        }
        self.tableView.reloadData()
    }
     // MARK: - Room Creation
    func RoomCreated(sender:UIBarButtonItem){
        print("done button pressed and Room Creating From SwitchTableView")
        if(!hasSelect){
            ImageUpload()
        }
        let RoomRef = self.ref.child("users/\(uid!)/Rooms")
        let Room = RoomRef.child("\(RoomName)")
        Room.setValue(Select)
        if(hasSelect){
            let controller = storyboard?.instantiateViewController(withIdentifier: "RoomDetailView") as! RoomViewController
            self.navigationController?.pushViewController(controller, animated: true)
            controller.Switches = Select
            controller.RoomName = RoomName
        }
        else{
            DashBoardViewController.rooms.append("\(RoomName)")
            DashBoardViewController.SwitchesInRoomsStore.append(Select)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if((SwitchStore.count) != 0){
            if(newData){
                if(MachinesStore.count == 1){
                    self.SegmentedControl.isHidden = true
                }else{
                    self.SegmentedControl.isHidden = false
                }
                for segment in previousCount..<MachinesStore.count{
                    self.SegmentedControl.insertSegment(withTitle: MachinesStore[segment], at: segment, animated: true)
                    print("Segment is \(segment)")
                }
        }
            if(self.SegmentedControl.selectedSegmentIndex == -1){
                self.SegmentedControl.selectedSegmentIndex = 0
            }
           previousCount = MachinesStore.count
            return SwitchStore[self.SegmentedControl.selectedSegmentIndex].count
        }else{
            self.SegmentedControl.isHidden = true
            return 0
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchTableViewCell
        let segment = self.SwitchStore[self.SegmentedControl.selectedSegmentIndex]
        let sw = segment["sw\(indexPath.row+1)"] as! String
        cell.SwitchNameLabel.text = sw
        cell.selectionStyle = .none
        //print(SwitchState[indexPath.row])
        if(SwitchState.count != 0){
            cell.CellSwitch.isOn = SwitchState[indexPath.row]
        }else{
            cell.CellSwitch.isOn = false
        }
        
        cell.SwitchNumber = "\(indexPath.row+1)"
        //cell.SwicthIP = SwitchTableViewController.IPStore[self.SegmentedControl.selectedSegmentIndex]
        let MachineName = MachinesStore[SegmentedControl.selectedSegmentIndex]
        let MachineIndex = DashBoardViewController.MachineStore.index(forKey: MachineName)
        let Machine = DashBoardViewController.MachineStore[MachineIndex!].value
        cell.SwicthIP = Machine.MachineIP
        if( Select.index(forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])sw\(indexPath.row+1)") != nil){
            cell.accessoryType = .checkmark
            
        }else{
            cell.accessoryType = .none
        }
        if(RoomName != ""){
            cell.CellSwitch.isHidden = true
        }
            return cell
    }
    //MARK:- Table view Selection Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(RoomName != ""){
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                Select.removeValue(forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])sw\(indexPath.row+1)")
                print(Select)
            }else{
                let cell = tableView.cellForRow(at: indexPath) as! SwitchTableViewCell
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                Select.updateValue((cell.SwitchNameLabel.text!),forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])sw\(indexPath.row+1)")
                print(Select)
            }

        }
        
    }
    
    //MARK: - Switch Rename
    @IBAction func RenameSwitch(RenameButton: UIButton) {
        AlertRename(title: "Rename",message: "",RenameButton: RenameButton)
    }
    func AlertRename(title:String,message:String,RenameButton:UIButton){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action) in
            if let cell = RenameButton.superview?.superview as? SwitchTableViewCell {
                let indexPath = self.tableView.indexPath(for: cell)
                print((indexPath?.row)!)
                let index = (indexPath?.row)!
                print(index)
                print(alert.textFields?[0].text ?? "Nothing in textField")
                if(alert.textFields?[0].text != ""){
                    let text = alert.textFields?[0].text
                    let Machineref = self.ref.child("users/\(self.uid!)/Machines/\(self.MachinesStore[self.SegmentedControl.selectedSegmentIndex])")
                    Machineref.child("Switches/sw\(index+1)").setValue(text)
                    let RoomRef = self.ref.child("users/\(self.uid!)/Rooms")
                    let room =  RoomRef.queryOrdered(byChild: "\(self.MachinesStore[self.SegmentedControl.selectedSegmentIndex])sw\(index+1)").queryEqual(toValue: cell.SwitchNameLabel.text)
                    room.observeSingleEvent(of: .value, with: { (snap) in
                        print(snap)
                        let result = snap.children.allObjects as? [DataSnapshot]
                        for child in result!{
                            //print(child)
                            //print("one child")
                            let RoomName = child.key
                            let ChangeRef = RoomRef.child("\(RoomName)/\(self.MachinesStore[self.SegmentedControl.selectedSegmentIndex])sw\(index+1)")
                            ChangeRef.setValue("\(text!)")
                        }
                        
                    })
                    self.tableView.reloadData()
                }
                
            }
            
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - XML Parser Method
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("Printing  Start Element \(elementName)")
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("Printing End Element \(elementName)")
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("Found Characters \(string)")
        if (string != "\n"){
            if(string == "00"){
                SwitchState.append(false)
            }else{
                SwitchState.append(true)
            }
        }
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error occured \(parseError)")
    }

    func sendRequest(url: String, Parameter: String){
        let requestURL = URL(string:"http://192.168.1.25/swcr.xml")!
        print("\(requestURL)")
        let request = URLRequest(url: requestURL)
        let task = URLSession.shared.dataTask(with: request) { data,response,error in
            guard let data = data else{
                print("Request failed \(String(describing: error))")
                return
            }
            let res = String(data: data,encoding:.utf8)
            //print(res?.removeSubrange(<#T##bounds: Range<String.Index>##Range<String.Index>#>))
            print("raw respnose\(String(describing: res))")
        }

        task.resume()
    }
     //MARK: - Upload Image
    func ImageUpload(){
        print("Upload Image Func")
        let StorageRef = Storage.storage()
        let ref = StorageRef.reference(forURL: "gs://d2brain-87137.appspot.com")
        if UploadImage != nil{
            print(RoomName)
            let image = UIImagePNGRepresentation(UploadImage)
            print("Image Uploading")
            let Databaseref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
            let uid = Auth.auth().currentUser?.uid
            let RefRoomImages = Databaseref.child("users/\(uid!)/RoomsImagesURL/")
            let ImagePath = DashBoardViewController.paths.appendingPathComponent("\(self.RoomName).png")
            do{
                try image?.write(to: ImagePath, options: .atomic)
            }catch{
                print("Caching Writing ")
            }
            let makingTempUrl = self.RoomName.components(separatedBy: " ")
            DashBoardViewController.ImageURL.updateValue("https://\(makingTempUrl[0]).com", forKey:"\(self.RoomName)")
            RefRoomImages.setValue(DashBoardViewController.ImageURL)
            ref.child("\(RoomName)").putData(image!, metadata: nil) { (MetaData, error) in
                if error != nil{
                    print("Error is \(error!)")
                    return
                }
                if (MetaData?.downloadURL()?.absoluteString != nil){
                    DashBoardViewController.ImageURL.updateValue((MetaData?.downloadURL()?.absoluteString)!, forKey:"\(self.RoomName)")
                    print(DashBoardViewController.ImageURL)
                    RefRoomImages.setValue(DashBoardViewController.ImageURL)
                }
                
            }
            
        }
        
    }

    //MARK: - DataFetch
    func DataFetch2(){
        let Machines = self.ref.child("users/\(uid!)/Machines")
        Machines.observe(.childAdded, with: { (snapshot) in
            //print(snapshot)
            let result = snapshot.value as! [String:AnyObject]
            //print(result)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                let name = result["MachineName"] as! String
                let ip = result["IP"] as! String
                let Switches = result["Switches"] as! NSDictionary
                self.SwitchStore.append(Switches as! Dictionary<String, Any>)
                self.MachinesStore.append(name)
                SwitchTableViewController.IPStore.append(ip)
                self.newData = true
                self.tableView.reloadData()
            })
           
        })
        Machines.observe(.childChanged, with: { (snap) in
            let ChangeResult = snap.value as! [String:AnyObject]
            let FindName = ChangeResult["MachineName"] as! String
            print("chnage \(FindName)")
            let index = self.MachinesStore.index(of: FindName)
            let Switches = ChangeResult["Switches"] as! NSDictionary
            self.SwitchStore.remove(at: index!)
            self.SwitchStore.insert(Switches as! Dictionary<String, Any>, at: index!)
            self.tableView.reloadData()
        })
    }

}
