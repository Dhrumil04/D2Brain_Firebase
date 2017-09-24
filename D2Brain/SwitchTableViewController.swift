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
class SwitchTableViewController: UITableViewController,XMLParserDelegate{
    
    //MARK: - Variable Declaration
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    let Sref = Storage.storage().reference(forURL: "gs://d2brain-87137.appspot.com")
    var newData:Bool!
    var hasSelect = false
    var previousCount = 0
    @IBOutlet var SegmentedControl: UISegmentedControl!
    var Select = [String:String]()
    var button = UIBarButtonItem()
    var RoomName:String = ""
    var UploadImage:UIImage!
    var parser = XMLParser()
    @IBOutlet var SwitchDimmerSegment: UISegmentedControl!
    var ToReturnImage:UIImage!
    var MachineName:String = ""
    @IBOutlet var ViewToDisplayHeader: UIView!
    let SearchController = UISearchController(searchResultsController: nil )
    var AllSwitches = Dictionary<String,String>()
    var FilterArray = Dictionary<String,String>()
    var controller = UISearchController()
    var number = 1
    var SwitchStateDict = Dictionary<String,Bool>()
    var DimmerStateDict = Dictionary<String,Bool>()
    var DimmerValueDict = Dictionary<String,String>()
    var ArrayToAlert = [String]()
    var RoomKey = String()
    var isFromRoom = Bool()
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Swicth Table View Did Load")
        
        //Search Controller Set
        SearchController.delegate = self
        SearchController.searchResultsUpdater = self
        SearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        //SearchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        //ViewToDisplayHeader.addSubview(SearchController.searchBar)
        
        //Set Switches any Selected or Not
        if (!Select.isEmpty){
            print("Printing Select \(Select)")
            self.hasSelect = true
        }
        print(RoomName)
        //New Room or exsting Room then Displaying Done button at Right at Navigation bar
        if(isFromRoom){
            button =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RoomCreated(sender:)))
            self.navigationItem.setRightBarButton(button, animated: true)
        }
        //Set One Time New Data updated or not from firebase
        self.newData = false
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        print("Switch Table View Will Appear")
        print("New Data value is \(self.newData)")
        //Firebase Data fetch,Set Segment previous Count and Remove All Segment to create from scratch updated
        if(!newData){
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

        let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: SegmentedControl.selectedSegmentIndex)
        let Machine = MachinesViewController.MachineStore[IndexForMachine].value
        if(SwitchDimmerSegment.selectedSegmentIndex == 0){
            if(!isFromRoom){
                sendRequest(url: Machine.MachineIP, Parameter: "swcr.xml", MachineName: Machine.MachineName)
            }
        }else{
            if(!isFromRoom){
                sendRequest(url: Machine.MachineIP, Parameter: "dmcr.xml", MachineName: Machine.MachineName)
            }
        }
        self.tableView.reloadData()
    }
    
    @IBAction func SwitchDimmerSelectionChanged(_ sender: Any) {
        let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: SegmentedControl.selectedSegmentIndex)
        let Machine = MachinesViewController.MachineStore[IndexForMachine].value
        if(SwitchDimmerSegment.selectedSegmentIndex == 0){
            if(!isFromRoom){
                sendRequest(url: Machine.MachineIP, Parameter: "swcr.xml", MachineName: Machine.MachineName)
            }
        }else{
            if(!isFromRoom){
                sendRequest(url: Machine.MachineIP, Parameter: "dmcr.xml", MachineName: Machine.MachineName)
            }
        }
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - Room Creation
    func RoomCreated(sender:UIBarButtonItem){
        print("done button pressed and Room Creating From SwitchTableView")
        // Check Wether Room is already Created or not
        let RoomRef = self.ref.child("users/\(uid!)/Rooms")
        if(hasSelect){
            //If Room is already Created then just Give it new value of Selection and just passing RoomName And Image
            RoomRef.child(RoomKey).child("Switches").setValue(Select)
            let controller = storyboard?.instantiateViewController(withIdentifier: "RoomDetailView") as! RoomViewController
            self.navigationController?.pushViewController(controller, animated: true)
            controller.Switches = Select
            controller.Image = ToReturnImage
        }
        else if(!Select.isEmpty && !hasSelect){
            //If Room is not created then append it in Room Array and Give it a Selection Array and Go to Main DashBoard
//            DashBoardViewController.rooms.append("\(RoomName)")
//            DashBoardViewController.SwitchesInRoomsStore.append(Select)
            self.RoomKey = RoomRef.childByAutoId().key
            print(RoomName)
            print(Select)
            ImageUpload()
            RoomRef.child(RoomKey).setValue(["RoomName":RoomName,"Switches":Select])
            DashBoardViewController.NewRooms.updateValue(Room(RoomName: RoomName, Switches: Select), forKey: RoomKey)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    //MARK: - Upload Image For Room
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
            DashBoardViewController.ImageURL.updateValue("https://\(makingTempUrl[0]).com", forKey:self.RoomKey)
            print(DashBoardViewController.ImageURL)
            RefRoomImages.setValue(DashBoardViewController.ImageURL)
            ref.child(uid!).child(RoomKey).putData(image!, metadata: nil) { (MetaData, error) in
                if error != nil{
                    print("Error is \(error!)")
                    return
                }
                if (MetaData?.downloadURL()?.absoluteString != nil){
                    DashBoardViewController.ImageURL.updateValue((MetaData?.downloadURL()?.absoluteString)!, forKey:self.RoomKey)
                    print(DashBoardViewController.ImageURL)
                    RefRoomImages.setValue(DashBoardViewController.ImageURL)
                }
                
            }
            
        }
        
    }

       // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Setting the Machine Segment Controll to display or not if there is Only One Machine
        if(MachinesViewController.MachineStore.count != 0){
//                if(DashBoardViewController.MachineStore.count == 1){
//                    //self.SegmentedControl.isHidden = true
//                }else{
//                    if(!controller.isActive){
//                        self.SegmentedControl.isHidden = false
//                    }
//            }
            for segment in previousCount..<MachinesViewController.MachineStore.count{
                //Creating Segment For Machine from nil to get latest Fetched Data
                let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: segment)
                let Machine = MachinesViewController.MachineStore[IndexForMachine].value
                self.SegmentedControl.insertSegment(withTitle: Machine.MachineName, at: segment, animated: true)
            }
            if(self.SegmentedControl.selectedSegmentIndex == -1){
                //If no Segment is Created then Selected Segmented index is -1 such that set it to 0
              self.SegmentedControl.selectedSegmentIndex = 0
            }
            //Set Previos Count of Segment if there is new Machine is created then dont conflict
            //previousCount = MachinesStore.count
            previousCount = MachinesViewController.MachineStore.count
            print("Reloading Table Data this print is in number of RowSection Method")
            //If Flitering is enable then give count of filter array
            if(isFiltering()){
                return FilterArray.count
            }
            //If Switch segment selected(index is 0) then give it a Switch Count else Dimmer count
            let IndexForSelectedMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: self.SegmentedControl.selectedSegmentIndex)
            if(SwitchDimmerSegment.selectedSegmentIndex == 0){
                let Machine = MachinesViewController.MachineStore[IndexForSelectedMachine]
                return Machine.value.Switches.count
            }else{
                let Machine = MachinesViewController.MachineStore[IndexForSelectedMachine]
                return Machine.value.Dimmers.count
            }
        }else{
            //No data then blank view
            self.SegmentedControl.isHidden = true
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Select Height of cell for Switch and Dimmer Differently
        if(isFiltering()){
            let FirstElement = FilterArray[FilterArray.index(FilterArray.startIndex, offsetBy: indexPath.row)]
            if(FirstElement.key.components(separatedBy: "Switch").count == 2){
                return 65
            }else{
                return 110
            }
        }
        if(SwitchDimmerSegment.selectedSegmentIndex == 0){
            return 65
        }
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (isFiltering()){
            let FirstElement = FilterArray[FilterArray.index(FilterArray.startIndex, offsetBy: indexPath.row)]
            if(FirstElement.key.components(separatedBy: "Switch").count == 2){
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchTableViewCell
                cell.SwitchNameLabel.text = FirstElement.value
                let Separated = FirstElement.key.components(separatedBy: "Switch")
                if (SwitchStateDict.index(forKey: FirstElement.key) != nil){
                    cell.CellSwitch.isOn = SwitchStateDict[SwitchStateDict.index(forKey: FirstElement.key)!].value
                }else{
                    cell.CellSwitch.isOn = false
                }
                cell.SwitchNumber = Separated[1]
                let Machine = MachinesViewController.MachineStore[MachinesViewController.MachineStore.index(forKey: (Separated[0]))!].value
                cell.SwicthIP = Machine.MachineIP
                cell.MachineName = Machine.MachineName
                cell.delegate = self
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DimmerCell") as! DimmerTableViewCell
                cell.DimmerNameLabel.text = FirstElement.value
                let Separated = FirstElement.key.components(separatedBy: "Dimmer")
                cell.DimmerNumber = Separated[1]
                let Machine = MachinesViewController.MachineStore[MachinesViewController.MachineStore.index(forKey: (Separated[0]))!].value
                cell.DimmerIP = Machine.MachineIP
                cell.MachineName = Machine.MachineName
                if(DimmerStateDict.index(forKey: FirstElement.key) != nil){
                    cell.DimmerSwitch.isOn = DimmerStateDict[DimmerStateDict.index(forKey: FirstElement.key)!].value
                    let value = NumberFormatter().number(from: DimmerValueDict[DimmerValueDict.index(forKey: FirstElement.key)!].value)
                    cell.DimmerSlider.value = (value?.floatValue)!
                    
                }else{
                    cell.DimmerSwitch.isOn = false
                    cell.DimmerSlider.value = 0.0
                }
                cell.delegate = self
                return cell
            }
        }
        if(SwitchDimmerSegment.selectedSegmentIndex == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchTableViewCell
            let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: SegmentedControl.selectedSegmentIndex)
            let Machine = MachinesViewController.MachineStore[IndexForMachine]
            let IndexForSwitch = Machine.value.Switches.index(forKey: "Switch\(indexPath.row+1)")
            let sw = Machine.value.Switches[IndexForSwitch!].value
            cell.SwitchNameLabel.text = sw
            cell.selectionStyle = .none
            //cell.SwitchNumberToDisplay.text = "\(indexPath.row+1)"
            if(isFromRoom){
                if( Select.index(forKey: "\(Machine.key)Switch\(indexPath.row+1)") != nil){
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
                cell.CellSwitch.isHidden = true
            }else{
                if (SwitchStateDict.index(forKey: "\(Machine.value.MachineName)sw\(indexPath.row+1)") != nil){
                    cell.CellSwitch.isOn = SwitchStateDict[SwitchStateDict.index(forKey: "\(Machine.value.MachineName)sw\(indexPath.row+1)")!].value
                }else{
                    cell.CellSwitch.isOn = false
                }
                cell.SwitchNumber = "\(indexPath.row+1)"
                cell.SwicthIP = Machine.value.MachineIP
                cell.MachineName = Machine.value.MachineName
            }
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DimmerCell") as! DimmerTableViewCell
            cell.selectionStyle = .none
            let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: SegmentedControl.selectedSegmentIndex)
            let Machine = MachinesViewController.MachineStore[IndexForMachine]
            let IndexForDimmer = Machine.value.Dimmers.index(forKey: "Dimmer\(indexPath.row+1)")
            let dm = Machine.value.Dimmers[IndexForDimmer!].value
            cell.DimmerNameLabel.text = dm
            if( Select.index(forKey: "\(Machine.key)Dimmer\(indexPath.row+1)") != nil){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            if(isFromRoom){
                cell.DimmerSwitch.isHidden = true
                cell.DimmerSlider.isHidden = true
            }else{
                cell.DimmerIP = Machine.value.MachineIP
                cell.DimmerNumber = "\(indexPath.row+1)"
                cell.MachineName = Machine.value.MachineName
                if(DimmerStateDict.index(forKey: "\(Machine.value.MachineName)dm\(indexPath.row+1)") != nil){
                    cell.DimmerSwitch.isOn = DimmerStateDict[DimmerStateDict.index(forKey: "\(Machine.value.MachineName)dm\(indexPath.row+1)")!].value
                    let value = NumberFormatter().number(from: DimmerValueDict[DimmerValueDict.index(forKey: "\(Machine.value.MachineName)dm\(indexPath.row+1)")!].value)
                    cell.DimmerSlider.value = (value?.floatValue)!
                }else{
                    cell.DimmerSwitch.isOn = false
                    cell.DimmerSlider.value = 0.0
                }
            }
            cell.delegate = self
            return cell
        }
    }
    //MARK:- Table view Selection Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(isFromRoom){
            let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: SegmentedControl.selectedSegmentIndex)
            let Machine = MachinesViewController.MachineStore[IndexForMachine]
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                if(SwitchDimmerSegment.selectedSegmentIndex == 0){
                    Select.removeValue(forKey: "\(Machine.key)Switch\(indexPath.row+1)")
                }else{
                    Select.removeValue(forKey: "\(Machine.key)Dimmer\(indexPath.row+1)")
                }
                print(Select)
            }else{
                if(SwitchDimmerSegment.selectedSegmentIndex == 0){
                    let cell = tableView.cellForRow(at: indexPath) as! SwitchTableViewCell
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    Select.updateValue((cell.SwitchNameLabel.text!),forKey: "\(Machine.key)Switch\(indexPath.row+1)")
                }else{
                    let cell = tableView.cellForRow(at: indexPath) as! DimmerTableViewCell
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    Select.updateValue((cell.DimmerNameLabel.text!), forKey: "\(Machine.key)Dimmer\(indexPath.row+1)")
                }
                print(Select)
            }
        }
    }
    
    //MARK: - Switch/Dimmer Rename
    
    @IBAction func RenameSwitch(RenameButton: UIButton) {
        AlertRenameSwitch(title: "Rename",message: "",RenameButton: RenameButton)
    }
    @IBAction func RenameDimmer(RenameButton: UIButton) {
        AlertRenameDimmer(title: "Rename", message: "", RenameButton: RenameButton)
        
    }
    func AlertRenameSwitch(title:String,message:String,RenameButton:UIButton){
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
                    let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: self.SegmentedControl.selectedSegmentIndex)
                    let Machine = MachinesViewController.MachineStore[IndexForMachine]
                    let Machineref = self.ref.child("users/\(self.uid!)/Machines/\(Machine.key)")
                    Machineref.child("Switches/Switch\(index+1)").setValue(text)
                    let RoomRef = self.ref.child("users/\(self.uid!)/Rooms")
                    let room =  RoomRef.queryOrdered(byChild: "\(Machine.key)Switch\(index+1)").queryEqual(toValue: cell.SwitchNameLabel.text)
                    room.observeSingleEvent(of: .value, with: { (snap) in
                        print(snap)
                        let result = snap.children.allObjects as? [DataSnapshot]
                        for child in result!{
                            //print(child)
                            //print("one child")
                            let RoomName = child.key
                            let ChangeRef = RoomRef.child("\(RoomName)/\(Machine.key)Switch\(index+1)")
                            ChangeRef.setValue("\(text!)")
                        }
                    })
                }
            }
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    func AlertRenameDimmer(title:String,message:String,RenameButton:UIButton){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action) in
            if let cell = RenameButton.superview?.superview as? DimmerTableViewCell {
                let indexPath = self.tableView.indexPath(for: cell)
                print((indexPath?.row)!)
                let index = (indexPath?.row)!
                print(index)
                print(alert.textFields?[0].text ?? "Nothing in textField")
                if(alert.textFields?[0].text != ""){
                    let text = alert.textFields?[0].text
                    let IndexForMachine = MachinesViewController.MachineStore.index(MachinesViewController.MachineStore.startIndex, offsetBy: self.SegmentedControl.selectedSegmentIndex)
                    let Machine = MachinesViewController.MachineStore[IndexForMachine]
                    let Machineref = self.ref.child("users/\(self.uid!)/Machines/\(Machine.key)")
                    Machineref.child("Dimmers/Dimmer\(index+1)").setValue(text)
                    let RoomRef = self.ref.child("users/\(self.uid!)/Rooms")
                    let room =  RoomRef.queryOrdered(byChild: "\(Machine.key)Dimmer\(index+1)").queryEqual(toValue: cell.DimmerNameLabel.text)
                    room.observeSingleEvent(of: .value, with: { (snap) in
                        print(snap)
                        let result = snap.children.allObjects as? [DataSnapshot]
                        for child in result!{
                            //print(child)
                            //print("one child")
                            let RoomName = child.key
                            let ChangeRef = RoomRef.child("\(RoomName)/\(Machine.key)Dimmer\(index+1)")
                            ChangeRef.setValue("\(text!)")
                        }
                        
                    })
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
                    DimmerStateDict.updateValue(false, forKey: "\(self.MachineName)dm\(self.number)")
                }else{
                    DimmerStateDict.updateValue(true, forKey: "\(self.MachineName)dm\(self.number)")
                }
                let next = string.index(string.startIndex, offsetBy: 2)
                //print(string[Range(next..<string.endIndex)])
                DimmerValueDict.updateValue(string[Range(next..<string.endIndex)], forKey: "\(self.MachineName)dm\(self.number)")
            }else{
                if(string == "00"){
                    SwitchStateDict.updateValue(false, forKey: "\(self.MachineName)sw\(self.number)")
                    
                }else{
                    SwitchStateDict.updateValue(true, forKey: "\(self.MachineName)sw\(self.number)")
                }
                
            }
            number = number+1
        }
        
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error occured \(parseError)")
    }
    
    func DataLoadFailed(MachineName:String){
        let alert = UIAlertController(title: "\(MachineName)", message: "Can't connect", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (ok) in
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
    
    func sendRequest(url: String, Parameter: String ,MachineName:String){
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
                    self.DataLoadFailed(MachineName: MachineName)
                }
                return
            }
            let res = String(data: data,encoding:.utf8)
            print("raw respnose\(String(describing: res))")
            self.parser = XMLParser(data: data)
            self.parser.delegate = self
            self.number = 1
            self.MachineName = MachineName
            let suc = self.parser.parse()
            if(suc){
                print("xml parsing done")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        task.resume()
    }
   
    
   
    
    //MARK: - DataFetch
    func DataFetch2(){
        let Machines = self.ref.child("users/\(uid!)/Machines")
        Machines.observe(.childAdded, with: { (snapshot) in
            let result = snapshot.value as! [String:AnyObject]
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                let newMachine = Machine(Name: result["MachineName"] as! String,  IP: result["IP"] as! String, Serial:  result["SerialNumber"] as! String, Switches: result["Switches"] as! Dictionary<String, String>, Dimmers: result["Dimmers"] as! Dictionary<String, String>)
                if(!self.newData){
                    let MachineIndex = MachinesViewController.MachineStore.startIndex
                    let Machine = MachinesViewController.MachineStore[MachineIndex].value
                    print("Printing machine name \(Machine.MachineName)")
                    self.MachineName = Machine.MachineName
                    if(self.SwitchDimmerSegment.selectedSegmentIndex == 0){
                        if(!self.isFromRoom){
                            self.sendRequest(url: Machine.MachineIP, Parameter: "swcr.xml", MachineName: self.MachineName)
                        }
                    }
                }
                self.newData = true
                if(MachinesViewController.MachineStore.updateValue(newMachine, forKey: snapshot.key) == nil){
                    self.tableView.reloadData()
                }
            })
        })
        Machines.observe(.childChanged, with: { (snap) in
            print(snap)
            let ChangeResult = snap.value as! [String:AnyObject]
            let MachineIndex =  MachinesViewController.MachineStore.index(forKey: snap.key)
            MachinesViewController.MachineStore[MachineIndex!].value.Switches = ChangeResult["Switches"] as! Dictionary<String,String>
            MachinesViewController.MachineStore[MachineIndex!].value.Dimmers = ChangeResult["Dimmers"] as! Dictionary<String,String>
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
    }
    func Fetch(){
            let Machineref = self.ref.child("users/\(uid!)/Machines/")
               Machineref.observe(.value, with: { (snapshot) in
                let Machines = snapshot.children.allObjects as? [DataSnapshot]
                for Machine in Machines!{
                    let MachineKey = Machine.key
                    let Value = Machine.value as! [String:AnyObject]
                    let Switches = Value["Switches"] as! NSDictionary
                    let Dimmers = Value["Dimmers"] as! NSDictionary
                    for Switchkey in Switches.allKeys{
                        let SwitchName = Switches.value(forKey: Switchkey as! String) as! String
                        self.AllSwitches.updateValue(SwitchName, forKey: "\(MachineKey)\(Switchkey)")
                    }
                    for Dimmerkey in Dimmers.allKeys{
                        let DimmerName = Dimmers.value(forKey: Dimmerkey as! String) as! String
                        self.AllSwitches.updateValue(DimmerName, forKey: "\(MachineKey)\(Dimmerkey)")
                    }
                    // print("All Switches printing is \(self.AllSwitches)")
                }
            })
        
    }
 
}

// MARK: - UISearchResultsUpdating,UISearchControllerDelegate
extension SwitchTableViewController:UISearchResultsUpdating,UISearchControllerDelegate{
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return controller.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(searchText: String) {
        FilterArray.removeAll()
        for (key,value) in AllSwitches{
            if(value.lowercased().contains(searchText.lowercased())){
                FilterArray.updateValue(value, forKey: key)
            }
        }
        self.tableView.reloadData()
    }
    func didDismissSearchController(_ searchController: UISearchController) {
        // ViewToDisplayHeader.isHidden = true
        
        SegmentedControl.isHidden = false
        SwitchDimmerSegment.isHidden = false
    }
    func willPresentSearchController(_ searchController: UISearchController) {
        //ViewToDisplayHeader.frame.size.height = 50
        Fetch()
        for (_,value) in MachinesViewController.MachineStore{
            sendRequestForSearch(url: value.MachineIP, Parameter: "swcr.xml", MachineName: value.MachineName)
        }
        SegmentedControl.isHidden = true
        SwitchDimmerSegment.isHidden = true
    }
    func isFiltering() -> Bool {
        return controller.isActive && !searchBarIsEmpty()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        controller = searchController
    }
    func sendRequestForSearch(url: String, Parameter: String ,MachineName:String){
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
            self.number = 1
            self.MachineName = MachineName
            let suc = self.parser.parse()
            if(suc){
                print("xml parsing done")
                if(Parameter == "swcr.xml"){
                    self.sendRequestForSearch(url: url, Parameter: "dmcr.xml",MachineName: MachineName)
                }else{
                    //Reload Data here
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }

}
// MARK: - SwitchTableCellDelegate,DimmerTableCellDelegate
extension SwitchTableViewController:SwitchTableCellDelegate,DimmerTableCellDelegate{
    func RequestFailedSwitch(cell: SwitchTableViewCell) {
        self.DataLoadFailed(MachineName: cell.MachineName)
    }
    func RequestFaileDimmer(cell: DimmerTableViewCell) {
        self.DataLoadFailed(MachineName: cell.MachineName)
    }
}




