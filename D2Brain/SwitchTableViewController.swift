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
class SwitchTableViewController: UITableViewController,XMLParserDelegate,UISearchResultsUpdating,UISearchControllerDelegate{

//MARK: - Variable Declaration
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    let Sref = Storage.storage().reference(forURL: "gs://d2brain-87137.appspot.com")
    var SwitchStore = [Dictionary<String, Any>]()
    var DimmerStore = [Dictionary<String,Any>]()
    var MachinesStore = [String]()
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
    var DimmerState = [Bool]()
    var DimmerValue = [String]()
    @IBOutlet var SwitchDimmerSegment: UISegmentedControl!
    var ToReturnImage:UIImage!
    var IP:String!
    @IBOutlet var ViewToDisplayHeader: UIView!
    let SearchController = UISearchController(searchResultsController: nil )
    var AllSwitches = Dictionary<String,String>()
    var FilterArray = Dictionary<String,String>()
//MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Swicth Table View Did Load")
        Fetch()
    //Search Controller Set
        SearchController.delegate = self
        SearchController.searchResultsUpdater = self
        SearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        //SearchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        ViewToDisplayHeader.addSubview(SearchController.searchBar)
    
    //Set Switches any Selected or Not
        if (!Select.isEmpty){
            print("Printing Select \(Select)")
            self.hasSelect = true
        }
        print(RoomName)
    //New Room or exsting Room then Displaying Done button at Right at Navigation bar
        if(RoomName != ""){
            button =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RoomCreated(sender:)))
            self.navigationItem.setRightBarButton(button, animated: true)
        }
    //Set One Time New Data updated or not from firebase
               self.newData = false
    }
    override func viewWillAppear(_ animated: Bool) {
        print("Switch Table View Will Appear")
         print("New Data value is \(self.newData)")
        
    //Firebase Data fetch,Set Segment previous Count and Remove All Segment to create from scratch updated
        if((!newData)){
            DataFetch2()
            previousCount = 0
            SegmentedControl.removeAllSegments()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //print("Switch Table view is going to be disapear")
    }
//MARK:- Segment Controlll Value changed
    
    @IBAction func SegmentControlValueChanged(_ sender: Any) {
        let MachineName = MachinesStore[SegmentedControl.selectedSegmentIndex]
        let MachineIndex = DashBoardViewController.MachineStore.index(forKey: MachineName)
        let Machine = DashBoardViewController.MachineStore[MachineIndex!].value
        self.IP = Machine.MachineIP
        if(SwitchDimmerSegment.selectedSegmentIndex == 0){
            if(RoomName == ""){
                SwitchState.removeAll()
                sendRequest(url: self.IP!, Parameter: "swcr.xml", MachineName: MachineName)
            }

        }else{
            if(RoomName == ""){
                DimmerState.removeAll()
                DimmerValue.removeAll()
                sendRequest(url: self.IP!, Parameter: "dmcr.xml", MachineName: MachineName)
                
            }
        }
        self.tableView.reloadData()
    }
    
    @IBAction func SwitchDimmerSelectionChanged(_ sender: Any) {
        let MachineName = MachinesStore[SegmentedControl.selectedSegmentIndex]
        let MachineIndex = DashBoardViewController.MachineStore.index(forKey: MachineName)
        let Machine = DashBoardViewController.MachineStore[MachineIndex!].value
        self.IP = Machine.MachineIP
        if(SwitchDimmerSegment.selectedSegmentIndex == 0){
            if(RoomName == ""){
                SwitchState.removeAll()
                sendRequest(url: self.IP!, Parameter: "swcr.xml", MachineName: MachineName)
            }
        }else{
            if(RoomName == ""){
                DimmerState.removeAll()
                DimmerValue.removeAll()
                sendRequest(url: self.IP!, Parameter: "dmcr.xml", MachineName: MachineName)
            }
        }
        self.tableView.reloadData()
    }
    
    
    
// MARK: - Room Creation
    func RoomCreated(sender:UIBarButtonItem){
        print("done button pressed and Room Creating From SwitchTableView")
    // Check Wether Room is already Created or not
        if(!hasSelect && !Select.isEmpty){
            ImageUpload()
        }
        let RoomRef = self.ref.child("users/\(uid!)/Rooms")
        let Room = RoomRef.child("\(RoomName)")
        Room.setValue(Select)
        if(hasSelect){
    //If Room is already Created then just Give it new value of Selection and just passing RoomName And Image
            let controller = storyboard?.instantiateViewController(withIdentifier: "RoomDetailView") as! RoomViewController
            self.navigationController?.pushViewController(controller, animated: true)
            controller.Switches = Select
            controller.RoomName = RoomName
            controller.Image = ToReturnImage
        }
        else if(!Select.isEmpty){
    //If Room is not created then append it in Room Array and Give it a Selection Array and Go to Main DashBoard
            DashBoardViewController.rooms.append("\(RoomName)")
            DashBoardViewController.SwitchesInRoomsStore.append(Select)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
//MARK:- Search Controller Function and Logic
    
    func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
        return SearchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(searchText: String) {
        FilterArray.removeAll()
        for (key,value) in AllSwitches{
            let count = searchText.characters.count
            let EndIndex = value.index(value.startIndex, offsetBy: count)
            //print("Value index bound text is \(value[Range(value.startIndex..<EndIndex)])")
            if (value[Range(value.startIndex..<EndIndex)].lowercased() == searchText.lowercased()) {
                FilterArray.updateValue(value, forKey: key)
            }else if(value.lowercased().components(separatedBy: searchText.lowercased()).count > 1){
                FilterArray.updateValue(value, forKey: key)
            }
        }
        tableView.reloadData()
    }
    func didDismissSearchController(_ searchController: UISearchController) {
       // ViewToDisplayHeader.isHidden = true
        SegmentedControl.isHidden = false
        SwitchDimmerSegment.isHidden = false
    }
    func willPresentSearchController(_ searchController: UISearchController) {
        //ViewToDisplayHeader.frame.size.height = 50
        SegmentedControl.isHidden = true
        SwitchDimmerSegment.isHidden = true
    }
    func isFiltering() -> Bool {
        return SearchController.isActive && !searchBarIsEmpty()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: SearchController.searchBar.text!)
    }
    
    
// MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //Setting the Machine Segment Controll to display or not if there is Only One Room
        if((SwitchStore.count) != 0){
            if(newData){
                if(MachinesStore.count == 1){
                    self.SegmentedControl.isHidden = true
                }else{
                    if(!SearchController.isActive){
                        self.SegmentedControl.isHidden = false
                    }
                }
                for segment in previousCount..<MachinesStore.count{
            //Creating Segment For Machine from nil to get latest Fetched Data
                    self.SegmentedControl.insertSegment(withTitle: MachinesStore[segment], at: segment, animated: true)
                    //print("Segment is \(segment)")
                }
        }
            if(self.SegmentedControl.selectedSegmentIndex == -1){
        //If no Segment is Created then Selected Segmented index is -1 such that set it to 0
                self.SegmentedControl.selectedSegmentIndex = 0
            }
    //Set Previos Count of Segment if there is new Machine is created then dont conflict
        previousCount = MachinesStore.count
      
        //If Flitering is enable then give count of filter array
            if(isFiltering()){
                return FilterArray.count
            }
        //If Switch segment selected(index is 0) then give it a Switch Count else Dimmer count
            if(SwitchDimmerSegment.selectedSegmentIndex == 0){
                return SwitchStore[self.SegmentedControl.selectedSegmentIndex].count
            }else{
                return DimmerStore[self.SegmentedControl.selectedSegmentIndex].count
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
            if(FirstElement.key.components(separatedBy: "sw").count == 2){
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
            if(FirstElement.key.components(separatedBy: "sw").count == 2){
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchTableViewCell
                cell.SwitchNameLabel.text = FirstElement.value
                let Separated = FirstElement.key.components(separatedBy: "sw")
                let number = NumberFormatter().number(from: (Separated[1]))
                cell.CellSwitch.isOn = SwitchState.isEmpty ? false : SwitchState[(number?.intValue)!]
                cell.SwitchNumber = Separated[1]
                let Machine = DashBoardViewController.MachineStore[DashBoardViewController.MachineStore.index(forKey: (Separated[0]))!].value
                cell.SwicthIP = Machine.MachineIP
                cell.MachineName = Machine.MachineName
                cell.delegate = self
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DimmerCell") as! DimmerTableViewCell
                cell.DimmerNameLabel.text = FirstElement.value
                let Separated = FirstElement.key.components(separatedBy: "dm")
                let number = NumberFormatter().number(from: (Separated[1]))
                cell.DimmerNumber = Separated[1]
                let Machine = DashBoardViewController.MachineStore[DashBoardViewController.MachineStore.index(forKey: (Separated[0]))!].value
                cell.DimmerIP = Machine.MachineIP
                cell.MachineName = Machine.MachineName
                if(DimmerState.isEmpty){
                    cell.DimmerSwitch.isOn = false
                    cell.DimmerSlider.value = 0.0
                }else{
                    cell.DimmerSwitch.isOn = DimmerState[(number?.intValue)!]
                    let value = NumberFormatter().number(from: self.DimmerValue[(number?.intValue)!])
                    cell.DimmerSlider.value = (value?.floatValue)!
                }
                cell.delegate = self
                return cell
            }
        }
        if(SwitchDimmerSegment.selectedSegmentIndex == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchTableViewCell
            let Switches = self.SwitchStore[self.SegmentedControl.selectedSegmentIndex]
            let sw = Switches["sw\(indexPath.row+1)"] as! String
            cell.SwitchNameLabel.text = sw
            cell.selectionStyle = .none
            cell.CellSwitch.isOn = SwitchState.isEmpty ? false : SwitchState[indexPath.row]
            //cell.SwitchNumberToDisplay.text = "\(indexPath.row+1)"
            cell.SwitchNumber = "\(indexPath.row+1)"
            cell.SwicthIP = self.IP
            cell.MachineName = MachinesStore[SegmentedControl.selectedSegmentIndex]
            if( Select.index(forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])sw\(indexPath.row+1)") != nil){
                cell.accessoryType = .checkmark
                
            }else{
                cell.accessoryType = .none
            }
            if(RoomName != ""){
                cell.CellSwitch.isHidden = true
            }
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DimmerCell") as! DimmerTableViewCell
            cell.selectionStyle = .none
           
            if( Select.index(forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])dm\(indexPath.row+1)") != nil){
                cell.accessoryType = .checkmark
                
            }else{
                cell.accessoryType = .none
            }

            let Dimmers = self.DimmerStore[self.SegmentedControl.selectedSegmentIndex]
            let dm = Dimmers["dm\(indexPath.row+1)"] as! String
            cell.DimmerNameLabel.text = dm
            cell.DimmerIP = self.IP
            cell.DimmerNumber = "\(indexPath.row+1)"
            cell.MachineName = MachinesStore[self.SegmentedControl.selectedSegmentIndex]
            //print("Dimmer state in cell \(self.DimmerState[indexPath.row])")
            if(DimmerState.isEmpty){
                cell.DimmerSwitch.isOn = false
                cell.DimmerSlider.value = 0.0
            }else{
                cell.DimmerSwitch.isOn = DimmerState[indexPath.row]
                let number = NumberFormatter().number(from: self.DimmerValue[indexPath.row])
                cell.DimmerSlider.value = (number?.floatValue)!
            }
                if(RoomName != ""){
                cell.DimmerSwitch.isHidden = true
                cell.DimmerSlider.isHidden = true
            }
            cell.delegate = self
            return cell
        }
        
    }
//MARK:- Table view Selection Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(RoomName != ""){
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                if(SwitchDimmerSegment.selectedSegmentIndex == 0){
                    Select.removeValue(forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])sw\(indexPath.row+1)")
                }else{
                    Select.removeValue(forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])dm\(indexPath.row+1)")
                }
                print(Select)
            }else{
                if(SwitchDimmerSegment.selectedSegmentIndex == 0){
                    let cell = tableView.cellForRow(at: indexPath) as! SwitchTableViewCell
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    Select.updateValue((cell.SwitchNameLabel.text!),forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])sw\(indexPath.row+1)")
                }else{
                    let cell = tableView.cellForRow(at: indexPath) as! DimmerTableViewCell
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    Select.updateValue((cell.DimmerNameLabel.text!), forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])dm\(indexPath.row+1)")
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
                    let Machineref = self.ref.child("users/\(self.uid!)/Machines/\(self.MachinesStore[self.SegmentedControl.selectedSegmentIndex])")
                    Machineref.child("Dimmer/dm\(index+1)").setValue(text)
                    let RoomRef = self.ref.child("users/\(self.uid!)/Rooms")
                    let room =  RoomRef.queryOrdered(byChild: "\(self.MachinesStore[self.SegmentedControl.selectedSegmentIndex])dm\(index+1)").queryEqual(toValue: cell.DimmerNameLabel.text)
                    room.observeSingleEvent(of: .value, with: { (snap) in
                        print(snap)
                        let result = snap.children.allObjects as? [DataSnapshot]
                        for child in result!{
                            //print(child)
                            //print("one child")
                            let RoomName = child.key
                            let ChangeRef = RoomRef.child("\(RoomName)/\(self.MachinesStore[self.SegmentedControl.selectedSegmentIndex])dm\(index+1)")
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
                        DimmerState.append(false)
                }else{
                        DimmerState.append(true)
                }
                let next = string.index(string.startIndex, offsetBy: 2)
                //print(string[Range(next..<string.endIndex)])
                DimmerValue.append(string[Range(next..<string.endIndex)])
            }else{
                if(string == "00"){
                    SwitchState.append(false)
                }else{
                    SwitchState.append(true)
                }

            }
        }
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error occured \(parseError)")
    }

    func DataLoadFailed(MachineName:String){
        let alert = UIAlertController(title: "\(MachineName)", message: "Can't connect", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (ok) in
            print("Machine Disable appeared")
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func sendRequest(url: String, Parameter: String ,MachineName:String){
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
//                    self.ArrayToAlert.append(MachineName)
                    self.DataLoadFailed(MachineName: MachineName)
                }
                return
            }
            let res = String(data: data,encoding:.utf8)
            print("raw respnose\(String(describing: res))")
            self.parser = XMLParser(data: data)
            self.parser.delegate = self
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
                let Switches = result["Switches"] as! NSDictionary
                let Dimmers = result["Dimmer"] as! NSDictionary
                self.DimmerStore.append(Dimmers as! Dictionary<String,Any>)
                self.SwitchStore.append(Switches as! Dictionary<String, Any>)
                self.MachinesStore.append(name)
                if(!self.newData){
                    let MachineName = self.MachinesStore[0]
                    let MachineIndex = DashBoardViewController.MachineStore.index(forKey: MachineName)
                    let Machine = DashBoardViewController.MachineStore[MachineIndex!].value
                    print("Printing machine name \(Machine.MachineName)")
                    self.IP = Machine.MachineIP
                    if(self.SwitchDimmerSegment.selectedSegmentIndex == 0){
                        if(self.RoomName == ""){
                            self.SwitchState.removeAll()
                            self.sendRequest(url: self.IP!, Parameter: "swcr.xml", MachineName: MachineName)
                        }
                        
                    }

                }
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
            let Dimmers = ChangeResult["Dimmer"] as! NSDictionary
            self.SwitchStore.remove(at: index!)
            self.DimmerStore.remove(at: index!)
            self.SwitchStore.insert(Switches as! Dictionary<String, Any>, at: index!)
            self.DimmerStore.insert(Dimmers as! Dictionary<String,Any>, at: index!)
            self.tableView.reloadData()
        })
    }
    func Fetch(){
        let Machineref = self.ref.child("users/\(uid!)/Machines/")
        Machineref.observe(.value, with: { (snapshot) in
            let Machines = snapshot.children.allObjects as? [DataSnapshot]
            for Machine in Machines!{
                let MachineName = Machine.key
                let Value = Machine.value as! [String:AnyObject]
                let Switches = Value["Switches"] as! NSDictionary
                let Dimmers = Value["Dimmer"] as! NSDictionary
                for Switchkey in Switches.allKeys{
                    let SwitchName = Switches.value(forKey: Switchkey as! String) as! String
                    self.AllSwitches.updateValue(SwitchName, forKey: "\(MachineName)\(Switchkey)")
                    //self.Switches.append(Switches)
                }
                for Dimmerkey in Dimmers.allKeys{
                    let DimmerName = Dimmers.value(forKey: Dimmerkey as! String) as! String
                    self.AllSwitches.updateValue(DimmerName, forKey: "\(MachineName)\(Dimmerkey)")
                }
               // print("All Switches printing is \(self.AllSwitches)")
            }
            self.tableView.reloadData()
        })
    }
}

extension SwitchTableViewController:SwitchTableCellDelegate,DimmerTableCellDelegate{
    func RequestFailedSwitch(cell: SwitchTableViewCell) {
        self.DataLoadFailed(MachineName: cell.MachineName)
    }
    func RequestFaileDimmer(cell: DimmerTableViewCell) {
        self.DataLoadFailed(MachineName: cell.MachineName)
    }
}




