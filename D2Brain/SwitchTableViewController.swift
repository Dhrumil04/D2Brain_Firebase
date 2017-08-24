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
    var SwitchStore = [Dictionary<String, Any>]()
    var MachinesStore = [String]()
    var IPStore = [String]()
    var newData:Bool!
    var hasSelect = false
    var previousCount:Int!
    @IBOutlet var SegmentedControl: UISegmentedControl!
    var Select = [String:String]()
    var button = UIBarButtonItem()
    var RoomName = ""
    var UploadImage:UIImage!
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Did Load")        
        print(RoomName)
        if(RoomName != ""){
            button =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RoomCreated(sender:)))
            self.navigationItem.setRightBarButton(button, animated: true)
           
        }
        /*let send = URL(string:"https://192.168.1.178/swcr.xml")
        let parser = XMLParser(contentsOf: send!)
        let success = parser?.parse()
        parser?.delegate = self
        if(success)!{
            //print("success")
        }else{
            print("Failed")
            sendRequest(url: "", Parameter: "")
        }*/
        self.newData = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear")
        
        if (!Select.isEmpty){
            print(Select)
            self.hasSelect = true
        }
        //DataFetch()
         print("New Data value is \(self.newData)")
        if((!newData)){
            DataFetch2()
            previousCount = 0
            SegmentedControl.removeAllSegments()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("view is going to be disapear")
    }
    //MARK:- Segment Controlll Value changed
    @IBAction func SegmentControlValueChanged(_ sender: Any) {
       //self.sendRequest(url: "\(IPStore[self.SegmentedControl.selectedSegmentIndex])", Parameter: "")
        self.tableView.reloadData()
    }
     // MARK: - Navigation
    func RoomCreated(sender:UIBarButtonItem){
        print("done button pressed")
        if(!hasSelect){
            ImageUpload()
        }
        let RoomRef = self.ref.child("users/\(uid!)/Rooms")
        //print(Select)
        let Room = RoomRef.child("\(RoomName)")
        Room.setValue(Select)
        if(hasSelect){
            let controller = storyboard?.instantiateViewController(withIdentifier: "RoomDetailView") as! RoomViewController
            self.navigationController?.pushViewController(controller, animated: true)
            controller.Switches = Select
            controller.RoomName = RoomName
        }
        else{
           // let controller = storyboard?.instantiateViewController(withIdentifier: "DashBoard") as! DashBoardViewController
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
            //print("Previous Count is \(self.previousCount)")
            //print("Machine Store Count for table view \(MachinesStore.count)")
            //print("Selected Segmented Control is \(SegmentedControl.selectedSegmentIndex)")
            previousCount = MachinesStore.count
            //print("Previous Count is \(self.previousCount)")
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
        if( Select.index(forKey: "\(MachinesStore[SegmentedControl.selectedSegmentIndex])sw\(indexPath.row+1)") != nil){
            cell.accessoryType = .checkmark
            
        }else{
            cell.accessoryType = .none
        }
        if(RoomName != ""){
            cell.CellSwitch.isHidden = true
            cell.CellSwitch.isOn = false
            
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
                            print(child)
                            print("one child")
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
    }
    
    
    func sendRequest(url: String, Parameter: String){
        let requestURL = URL(string:"https://192.168.1.178/swcr.xml")!
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

    /*func DataFetch(){
        let Machines = self.ref.child("users/\(uid!)/Machines")
        Machines.observe(.value, with: { (snapshot) in
            let result = snapshot.children.allObjects as? [DataSnapshot]
            self.MachinesStore.removeAll()
            self.SwitchStore.removeAll()
            for child in result!{
                let name = child.key
                self.MachinesStore.append(name)
                let SwitchRef = self.ref.child("users/\(self.uid!)/Machines/\(name)/Switches")
                SwitchRef.observe(.value, with: { (snapshot) in
                    let dict = snapshot.value as! NSDictionary
                    let Switches = dict as! Dictionary<String, Any>
                    self.SwitchStore.append(Switches)
                    self.tableView.reloadData()
                })

            }
            print(self.MachinesStore)
            self.newData = true
        })

    }*/
     //MARK: - Upload Image
    func ImageUpload(){
        print("Upload Image Func")
        let StorageRef = Storage.storage()
        let ref = StorageRef.reference(forURL: "gs://d2brain-87137.appspot.com")
        if UploadImage != nil{
            print(RoomName)
            let image = UIImagePNGRepresentation(UploadImage)
            print("Image Uploading")
            ref.child("\(RoomName)").putData(image!, metadata: nil) { (MetaData, error) in
                if error != nil{
                    print("Error is \(error!)")
                    return
                }
                print(MetaData!)
                let Databaseref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
                let uid = Auth.auth().currentUser?.uid
                let RefRoomImages = Databaseref.child("users/\(uid!)/RoomsImagesURL/")
                print(self.RoomName)
                RefRoomImages.child("\(self.RoomName)").setValue(["ImageURL":MetaData?.downloadURL()?.absoluteString])
                
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
                self.IPStore.append(ip)
               // print("Machine Count is\(self.MachinesStore.count) and names after appending is \(self.MachinesStore)")
                //print("Switch count is \(self.MachinesStore.count) and Switches after appending is \(self.SwitchStore)")
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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
   

        */

}
