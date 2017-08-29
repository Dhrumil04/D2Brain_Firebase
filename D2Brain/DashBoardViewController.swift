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

class DashBoardViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,RoomsCellDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet var CollectionViewRooms: UICollectionView!
    @IBOutlet var MenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var MenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet var MenuView: UIView!
    var RoomName = ""
    var showmenu = false
    static var rooms = [String]()
   static var SwitchesInRoomsStore = [Dictionary<String,Any>]()
    var buttons = [UIBarButtonItem]()
    var ImagePicker = UIImagePickerController()
    var Image=[UIImage]()
    var UploadImage:UIImage!
    var oldImage:UIImage!
    static var DataLoad = true
    static var ImageURL = [String:String]()
    
   static var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    
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
    //Fetach Data Function Called
        FetchRoom()
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
            //print(indexPath)
            cell.RoomName.text = DashBoardViewController.rooms[indexPath.row]
            cell.isEditing = false
        }
        print("I have no Image in cell")
        let ImagePath = DashBoardViewController.paths.appendingPathComponent("\(DashBoardViewController.rooms[indexPath.row]).png")
                if FileManager.default.fileExists(atPath: ImagePath.path){
                    print("Image Detected at file path \(ImagePath.path)")
                    cell.RoomImage.image = UIImage(contentsOfFile: ImagePath.path)
                }
              let url = DashBoardViewController.ImageURL[DashBoardViewController.ImageURL.index(forKey: DashBoardViewController.rooms[indexPath.row])!].value
                let sendURL = URL(string:url)!
                URLSession.shared.dataTask(with: sendURL, completionHandler: { (data, response, error) in
                        if error != nil{
                            print("Printing Error")
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            cell.RoomImage.image = UIImage(data: data!)
                            do{
                                print("Writing Image at \(ImagePath)")
                                try data?.write(to: ImagePath, options: .atomic)
                            }catch{
                                print("Error Writing")
                            }
                    }
            }).resume()
        cell.delegate = self
        return cell
    }
    
    
    //MARK:- Delete Room 
    func Edit(){
        self.navigationItem.setRightBarButton(buttons[0], animated: true)
        setEditing(true, animated: true)
    }
    func done(){
        setEditing(false, animated: true)
        self.navigationItem.setRightBarButton(buttons[1], animated: true)
    }

    func delete(cell:RoomsCollectionViewCell){
            DeleteRoom(RoomName: cell.RoomName.text!)
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
        imagealert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (Pick) in
            self.ImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.ImagePicker, animated: true, completion: nil)
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
            Image.append(pickedimage)
            UploadImage = pickedimage
        }
        if let EditedImagePicked = info[UIImagePickerControllerEditedImage] as? UIImage{
            Image.append(EditedImagePicked)
            UploadImage = EditedImagePicked
        }
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "SwitchView", sender: self)
        
        
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
            //NO Error
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
    
        
    
    //MARK: - Fetch Data

    //Fetch data from firebase and get open for adding child
    func FetchRoom(){
        if(DashBoardViewController.DataLoad){
            print("In data load \(DashBoardViewController.DataLoad)")
            let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
            let uid = Auth.auth().currentUser?.uid
            let RefRoom = ref.child("users/\(uid!)/Rooms")
            RefRoom.observe(.childAdded, with: { (snap) in
                print("AddedSnap")
                print(snap.key)
                let Switches = snap.value as! NSDictionary
                if(DashBoardViewController.rooms.contains(snap.key)){
                    
                }else{
                    print("New Room")
                    DashBoardViewController.SwitchesInRoomsStore.append(Switches as! Dictionary<String, Any>)
                    DashBoardViewController.rooms.append(snap.key)
                }
            })
            RefRoom.observe(.childChanged, with: { (snapshot) in
                print("Changed Snap")
                let index = DashBoardViewController.rooms.index(of: snapshot.key)!
                DashBoardViewController.SwitchesInRoomsStore.remove(at: index)
                let Switches = snapshot.value as! NSDictionary
                DashBoardViewController.SwitchesInRoomsStore.insert(Switches as! Dictionary<String, Any>, at: index)
                print(snapshot)
            })
            RefRoom.observe(.childRemoved, with: { (snapy) in
                print("Removed Snap")
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
            ImageRef.observe(.childAdded, with: { (snapshot) in
                //print(snapshot)
                let urls = snapshot.value as! CFString
                    print(urls)
                    DashBoardViewController.ImageURL.updateValue(urls as String, forKey: snapshot.key)
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
        DashBoardViewController.DataLoad = false
    }
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

    
}



