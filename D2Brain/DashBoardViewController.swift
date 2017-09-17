//
//  DashBoardViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 29/07/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DashBoardViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet var CollectionViewRooms: UICollectionView!
    @IBOutlet var MenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var MenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet var MenuView: UIView!
    var RoomName = ""
    var showmenu = false
    var EditImage = false
    static var DataLoad = true
    static var rooms = [String]()
   static var SwitchesInRoomsStore = [Dictionary<String,Any>]()
    var buttons = [UIBarButtonItem]()
    var ImagePicker = UIImagePickerController()
    var UploadImage:UIImage!
    var oldImage:UIImage!
    static var ImageURL = [String:String]()
    static var oldImageURL = [String:String]()
    static var MachineStore = Dictionary<String,Machine>()
   static var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var ArrayToAlert = [String]()
    var SearchController = UISearchController()
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if (Auth.auth().currentUser == nil){
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginScreen")
            self.present(controller, animated: true, completion: nil)
        }else{
            print("Dash Board View did load called")
    //Delegates Set
            CollectionViewRooms.delegate = self
            CollectionViewRooms.dataSource = self
            ImagePicker.delegate = self
    //View Set by Programming
            UINavigationBar.appearance().isHidden = false
            self.MenuView.layer.shadowOpacity = 1
            self.MenuView.layer.shadowRadius  = 3
            let button1 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
            let button2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CreateRoom))
            buttons = [button1,button2]
            self.navigationItem.setRightBarButton(buttons[1], animated: true)
    //Adding GestureRecogniser for long tap
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(Edit))
            lpgr.minimumPressDuration = 1.0
            lpgr.delaysTouchesBegan = true
            lpgr.delegate = self
            self.CollectionViewRooms.addGestureRecognizer(lpgr)
    //Adding Search Controller
            let controller = storyboard?.instantiateViewController(withIdentifier: "SwitchTableView") as! SwitchTableViewController
             SearchController = UISearchController(searchResultsController: controller)
            SearchController.dimsBackgroundDuringPresentation = false
            self.SearchController.hidesNavigationBarDuringPresentation = false
            self.SearchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
            definesPresentationContext = true
            //SearchController.searchBar.sizeToFit()
            self.navigationItem.titleView = SearchController.searchBar
            SearchController.delegate = controller
            SearchController.searchResultsUpdater = controller
    //Fetach Data Function Called
        FetchRoom()
        fetchMachine()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        print("DashBoard view appearing")
    //Menuview Setting Constrains
        MenuLeadingConstraint.constant = -140
        showmenu = false
    //Collection View Data load
        self.CollectionViewRooms.reloadData()
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SwitchView" {
            let controller = segue.destination as? SwitchTableViewController
            controller?.RoomName = self.RoomName
            controller?.UploadImage = UploadImage
            self.RoomName = ""
        }
        if segue.identifier == "RoomSegue" {
            let CellIndex = self.CollectionViewRooms.indexPath(for: sender as! UICollectionViewCell)
            let cell = CellIndex?.row
            let controller = segue.destination as? RoomViewController
            controller?.Switches = DashBoardViewController.SwitchesInRoomsStore[cell!]
            print(DashBoardViewController.rooms[cell!])
            controller?.RoomName = DashBoardViewController.rooms[cell!]
            let RoomCell = sender as! RoomsCollectionViewCell
            controller?.Image = RoomCell.RoomImage.image
        }
    }

    //MARK:- Collection View Datasource Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(DashBoardViewController.rooms.count != 0){
            return DashBoardViewController.rooms.count
        }
            return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/3-10, height: collectionView.bounds.size.width/3-10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomCell", for: indexPath) as! RoomsCollectionViewCell
        if(DashBoardViewController.rooms.count != 0){
            cell.RoomName.text = DashBoardViewController.rooms[indexPath.row]
            //cell.isEditing = false
            let ImagePath = DashBoardViewController.paths.appendingPathComponent("\(DashBoardViewController.rooms[indexPath.row]).png")
            print(DashBoardViewController.oldImageURL)
            if(DashBoardViewController.oldImageURL != DashBoardViewController.ImageURL){
                if (DashBoardViewController.ImageURL.index(forKey: DashBoardViewController.rooms[indexPath.row]) != nil){
                    let url = DashBoardViewController.ImageURL[DashBoardViewController.ImageURL.index(forKey: DashBoardViewController.rooms[indexPath.row])!].value
                    let sendURL = URL(string:url)!
                    URLSession.shared.dataTask(with: sendURL, completionHandler: { (data, response, error) in
                        if error != nil{
                            print("Printing Error")
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            //cell.RoomImage.image = UIImage(data: data!)
                            do{
                                print("Writing Image at \(ImagePath)")
                                try data?.write(to: ImagePath, options: .atomic)
                            }catch{
                                print("Error Writing")
                            }
                        }
                        DashBoardViewController.oldImageURL = DashBoardViewController.ImageURL
                    }).resume()
                }
            }
            if FileManager.default.fileExists(atPath: ImagePath.path){
                print("Image Detected at file path \(ImagePath.path)")
                cell.RoomImage.image = UIImage(contentsOfFile: ImagePath.path)
            }
        }
        cell.delegate = self
        return cell
    }
    
    
    //MARK:- Editing of Room
    func Edit(){
        self.navigationItem.setRightBarButton(buttons[0], animated: true)
        setEditing(true, animated: true)
    }
    func done(){
        setEditing(false, animated: true)
        self.navigationItem.setRightBarButton(buttons[1], animated: true)
    }

        override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if let indexPaths = CollectionViewRooms?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = CollectionViewRooms?.cellForItem(at: indexPath) as? RoomsCollectionViewCell{
                    cell.isEditing = editing
                }
            }
        }
        
    }
    
    //MARK:- Room Create Funtion
    func CreateRoom() {
        RoomName(title:"Create Room",message:"Give a Name")
    }
    func RoomName(title:String,message:String){
        let imagealert = UIAlertController(title: "Choose Image", message: "For Your Room", preferredStyle: .actionSheet)
        imagealert.popoverPresentationController?.sourceView = self.view
        imagealert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height*0.4)
        imagealert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (Pick) in
            self.ImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.EditImage = false
            self.present(self.ImagePicker, animated: true, completion: nil)
        }))
        imagealert.addAction(UIAlertAction(title: "Skip", style: .default, handler: { (skip) in
            self.UploadImage = #imageLiteral(resourceName: "Living Room")
            imagealert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "SwitchView", sender: self)
        }))
        imagealert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (NotPick) in
            imagealert.dismiss(animated: true, completion: nil)
        }))
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            if alert.textFields?[0].text != "" {
                self.RoomName = (alert.textFields?[0].text!)!
                self.present(imagealert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("In image view")
        if let pickedimage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            print("I have Image")
            UploadImage = pickedimage
        }
        if let EditedImagePicked = info[UIImagePickerControllerEditedImage] as? UIImage{
            UploadImage = EditedImagePicked
        }
        self.dismiss(animated: true, completion: nil)
        if(EditImage){
            ImageUpload()
        }else{
            self.performSegue(withIdentifier: "SwitchView", sender: self)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    //MARK:- Menu View
    @IBAction func MenuButtonAction(_ sender: Any) {
        if(showmenu){
            MenuLeadingConstraint.constant = -140
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        //Hiding Menu
        }
        else{
            MenuLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        //Showing Menu With animation
        }
        showmenu = !showmenu
        //Change Menu Bool Value
    }

    //MARK: - Logout Function
    @IBAction func LogoutAction(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }
        catch let SignOutError as NSError{
            print(SignOutError)
        }
    }
    
    func reload(){
    //Reload Collection View in main Thread
        DispatchQueue.main.async {
            self.CollectionViewRooms.reloadData()
        }
    }
    //MARK:- Upload Image/Write on local
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
            ref.child(uid!).child("\(RoomName)").putData(image!, metadata: nil) { (MetaData, error) in
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


    //MARK: - Fetch Data From Firebase

    //Fetch data from firebase and get open for adding child
    func FetchRoom(){
        if(DashBoardViewController.DataLoad){
            print("In data load \(DashBoardViewController.DataLoad)")
            let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
            let uid = Auth.auth().currentUser?.uid
            let RefRoom = ref.child("users/\(uid!)/Rooms")
            RefRoom.observe(.childAdded, with: { (snap) in
                print("AddedSnap 1")
                print(snap.key)
                let Switches = snap.value as! NSDictionary
                if(DashBoardViewController.rooms.contains(snap.key)){
                    
                }else{
                    print("New Room created 2")
                    DashBoardViewController.SwitchesInRoomsStore.append(Switches as! Dictionary<String, Any>)
                    DashBoardViewController.rooms.append(snap.key)
                }
            })
            RefRoom.observe(.childChanged, with: { (snapshot) in
                print("Changed Snap 3")
                let index = DashBoardViewController.rooms.index(of: snapshot.key)!
                DashBoardViewController.SwitchesInRoomsStore.remove(at: index)
                let Switches = snapshot.value as! NSDictionary
                DashBoardViewController.SwitchesInRoomsStore.insert(Switches as! Dictionary<String, Any>, at: index)
                print(snapshot)
            })
            RefRoom.observe(.childRemoved, with: { (snapy) in
                print("Removed Snap 4")
                if(DashBoardViewController.rooms.contains(snapy.key)){
                    let index = DashBoardViewController.rooms.index(of: snapy.key)
                    print(index!)
                    if((index) != nil){
                        DashBoardViewController.rooms.remove(at: index!)
                        print(DashBoardViewController.rooms.count)
                        DashBoardViewController.SwitchesInRoomsStore.remove(at: index!)
                        print(snapy)
                    }
                }
            })
            let ImageRef = ref.child("users/\(uid!)/RoomsImagesURL")
            ImageRef.observe(.value, with: { (snapshot) in
                //print(snapshot)
                print("Child Added 5")
                let urls = snapshot.children.allObjects as! [DataSnapshot]
                print(urls)
                //DashBoardViewController.ImageURL.updateValue(urls as String, forKey: snapshot.key)
                for url in urls{
                    DashBoardViewController.ImageURL.updateValue(url.value as! String, forKey: url.key)
                }
                print(DashBoardViewController.ImageURL)
                self.reload()
            })
            ImageRef.observe(.childRemoved, with: { (snap) in
                print("ImageURlS Remove Module")
                if((DashBoardViewController.ImageURL.index(forKey: snap.key)) != nil){
                    print("Changing")
                    DashBoardViewController.ImageURL.removeValue(forKey: snap.key)
                    self.reload()
                }
            })
        }
    }
    
//MARK:- DeleteRoom FirebaseFunction
    //Remove Value from Firebase & local Rooms array
    func DeleteRoom(RoomName:String){
        let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
        let uid = Auth.auth().currentUser?.uid
        ref.child("users/\(uid!)/Rooms/").child(RoomName).removeValue()
         ref.child("users/\(uid!)/RoomsImagesURL/").child("\(RoomName)").removeValue()
        let index = DashBoardViewController.rooms.index(of: RoomName)!
        DashBoardViewController.rooms.remove(at: index)
        DashBoardViewController.SwitchesInRoomsStore.remove(at: index)
        DashBoardViewController.ImageURL.removeValue(forKey: RoomName)
        self.CollectionViewRooms.reloadData()
    }
    func RenameRoom(OldName:String,NewName:String){
        let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
        let uid = Auth.auth().currentUser?.uid
        let setRef = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
        ref.child("users/\(uid!)/Rooms/").child(OldName).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let tempSwitches = snapshot.value as! NSDictionary
            print(tempSwitches)
            setRef.child("users/\(uid!)/Rooms/").child(NewName).setValue(tempSwitches)
            setRef.child("users/\(uid!)/RoomsImagesURL/").setValue(DashBoardViewController.ImageURL)
            self.DeleteRoom(RoomName: OldName)
        })

    }
    func updateUrl(OldName:String,NewName:String){
        let ChangeRef = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
        let uid = Auth.auth().currentUser?.uid
        ChangeRef.child("users/\(uid!)/RoomsImagesURL/").child(OldName).observeSingleEvent(of: .value, with: { (snap) in
            let tempUrl = snap.value as! CFString
            print(tempUrl)
            DashBoardViewController.ImageURL.updateValue(tempUrl as String, forKey: NewName)
            DashBoardViewController.ImageURL.removeValue(forKey: OldName)
             let ImagePath = DashBoardViewController.paths.appendingPathComponent("\(OldName).png")
             let ImagePathToWrite = DashBoardViewController.paths.appendingPathComponent("\(NewName).png")
            do{
                let Image = UIImage(contentsOfFile: ImagePath.path)
                let data = UIImagePNGRepresentation(Image!)
               try data?.write(to: ImagePathToWrite, options: .atomic)
            }catch{
                print("Catching write Image")
            }
            self.RenameRoom(OldName: OldName, NewName: NewName)
        })
    
    }
    func fetchMachine(){
        if(DashBoardViewController.DataLoad){
            let uid = Auth.auth().currentUser?.uid
            let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
            let Machineref = ref.child("users/\(uid!)/Machines/")
            Machineref.observe(.childAdded, with: { (snapshot) in
                let MachineDict = snapshot.value as! [String:AnyObject]
                let newMachine = Machine(Name: MachineDict["MachineName"] as! String,  IP: MachineDict["IP"] as! String, Serial:  MachineDict["SerialNumber"] as! String)
                DashBoardViewController.MachineStore.updateValue(newMachine, forKey: newMachine.MachineName)
            })
            Machineref.observe(.childRemoved, with: { (snap) in
                let Remover = snap.value as! [String:AnyObject]
                let newMachine = Machine(Name: Remover["MachineName"] as! String,  IP: Remover["IP"] as! String, Serial:  Remover["SerialNumber"] as! String)
                DashBoardViewController.MachineStore.removeValue(forKey: newMachine.MachineName)
            })

        }
        DashBoardViewController.DataLoad = false
    }
    
}

extension DashBoardViewController:RoomsCellDelegate {
    func delete(cell:RoomsCollectionViewCell){
        DeleteRoom(RoomName: cell.RoomName.text!)
    }
    func ChangeImage(cell: RoomsCollectionViewCell) {
        print("Chnage Image called for \(cell.RoomName.text!)")
        self.RoomName = cell.RoomName.text!
        self.ImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.EditImage = true
        self.present(self.ImagePicker, animated: true, completion: nil)
    }
    func RenameRoom(cell: RoomsCollectionViewCell) {
        AlertForRename(OldName: cell.RoomName.text!)
    }
    func MasterOnOff(cell: RoomsCollectionViewCell,OnOff:String) {
        print("Rooms \(DashBoardViewController.rooms)")
        let index = DashBoardViewController.rooms.index(of: cell.RoomName.text!)
        print("Index For Room is \(index!)")
        let SwitchesForRoom = DashBoardViewController.SwitchesInRoomsStore[index!]
        let keys = SwitchesForRoom.keys
        for key in keys{
            let Separate = key.components(separatedBy: "sw")
            if(Separate.count == 2){
                let Machine = DashBoardViewController.MachineStore[DashBoardViewController.MachineStore.index(forKey: Separate[0])!].value
                let IP = Machine.MachineIP
                var temp = Separate[1]
                if(Int(temp)!<10){
                    temp = "0" + Separate[1]
                }
                sendRequest(url: "http://\(IP)/cswcr.cgi?", Parameter: "SW=\(temp)\(OnOff)",MachineName: Separate[0])
            }else{
                let DimmerSeparate = key.components(separatedBy: "dm")
                let Machine = DashBoardViewController.MachineStore[DashBoardViewController.MachineStore.index(forKey: DimmerSeparate[0])!].value
                let IP = Machine.MachineIP
                var temp = DimmerSeparate[1]
                if(Int(temp)!<10){
                    temp = "0" + DimmerSeparate[1]
                }
                sendRequest(url: "http://\(IP)/cdmcr.cgi?", Parameter: "DM=\(temp)\(OnOff)50",MachineName: DimmerSeparate[0])
            }
        }
    }
    //MARK:- Master On Off Send Request Function
    func sendRequest(url: String, Parameter: String,MachineName:String){
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
                DispatchQueue.main.sync {
                    //Give Alert Here
                    self.AlertForFailed(MachineName: MachineName)
                }
                print(error!)
                return
            }
            print(NSString(data:data,encoding: String.Encoding.utf8.rawValue)!)
            //print(response!)
        }
        task.resume()
    }
    func AlertForRename(OldName:String){
        let RenameAlert = UIAlertController(title: "Give New Name", message: "", preferredStyle: .alert)
        
        RenameAlert.addTextField { (textfield) in
            textfield.text = ""
        }
        RenameAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            if RenameAlert.textFields?[0].text != "" {
                self.updateUrl(OldName: OldName, NewName: (RenameAlert.textFields?[0].text)!)
                RenameAlert.dismiss(animated: true, completion: nil)
            }
        }))
        RenameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action2) in
            RenameAlert.dismiss(animated: true, completion: nil)
        }))
        self.present(RenameAlert, animated: true, completion: nil)
    }
    

    func AlertForFailed(MachineName:String){
        if (!self.ArrayToAlert.contains(MachineName)){
            self.ArrayToAlert.append(MachineName)
        }
        let alert = UIAlertController(title: MachineName, message: "Can't Connect", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (disconnect) in
            alert.dismiss(animated: true, completion: nil)
            if(!self.ArrayToAlert.isEmpty){
                self.ArrayToAlert.remove(at: 0)
                if(!self.ArrayToAlert.isEmpty){
                    self.AlertForFailed(MachineName: self.ArrayToAlert[0])
                }
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

}


