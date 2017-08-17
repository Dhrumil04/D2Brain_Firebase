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

class DashBoardViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching,UIGestureRecognizerDelegate,RoomsCellDelegate{

    @IBOutlet var CollectionViewRooms: UICollectionView!
    @IBOutlet var MenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var MenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet var MenuView: UIView!
    var RoomName = ""
    var showmenu = false
    var rooms = [String]()
    var SwitchesInRoomsStore = [Dictionary<String,Any>]()
    var buttons = [UIBarButtonItem]()
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().isHidden = false
        print("View did load called")
        let id = Auth.auth().currentUser?.uid
        self.MenuView.layer.shadowOpacity = 1
        self.MenuView.layer.shadowRadius  = 3
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(Edit))
        lpgr.minimumPressDuration = 1.0
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.CollectionViewRooms.addGestureRecognizer(lpgr)
        let button1 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let button2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CreateRoom))
        buttons = [button1,button2]
        self.navigationItem.setRightBarButton(buttons[1], animated: true)
        FetchRoom()
        print(id ?? "Nothing")
        if (Auth.auth().currentUser == nil){
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginScreen")
            self.present(controller, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view appearing")
        MenuLeadingConstraint.constant = -140
        showmenu = false
    }
    
    
    func Edit(){
        print("Press Detected")
        setEditing(true, animated: true)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SwitchView" {
            let controller = segue.destination as? SwitchTableViewController
            controller?.RoomName = self.RoomName
            self.RoomName = ""
        }
        if segue.identifier == "RoomSegue" {
            let CellIndex = self.CollectionViewRooms.indexPath(for: sender as! UICollectionViewCell)
            let cell = CellIndex?.row
            let controller = segue.destination as? RoomViewController
            controller?.Switches = self.SwitchesInRoomsStore[cell!]
            //print(self.SwitchesInRoomsStore[cell!])
            //print(CellIndex!)
            //print(cell!)
        }
    }

    //MARK:- Collection View Datasource Method
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]){
        print("Fetehced")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(rooms.count != 0){
             return rooms.count
        }
       return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomCell", for: indexPath) as! RoomsCollectionViewCell
        if(rooms.count != 0){
            cell.RoomName.text = rooms[indexPath.row]
        }
        cell.delegate = self
        return cell
    }
    
    func done(){
        setEditing(false, animated: true)
        self.navigationItem.setRightBarButton(buttons[1], animated: true)
    }
    
    //MARK:- Delete Room 
    
    func delete(cell:RoomsCollectionViewCell){
        
            DeleteRoom(RoomName: cell.RoomName.text!)
            
        
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if(editing){
            self.navigationItem.setRightBarButton(buttons[0], animated: true)
        }
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
        
        //Alert Controller For giving Room name
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            if alert.textFields?[0].text != "" {
                self.RoomName = (alert.textFields?[0].text!)!
                self.performSegue(withIdentifier: "SwitchView", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
           alert.dismiss(animated: true, completion: nil)
        }))
           self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Menu View
    
    @IBAction func MenuButtonAction(_ sender: Any) {
        if(showmenu){
            //MenuWidthConstraint.constant = -140
            MenuLeadingConstraint.constant = -140
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        //Hiding Menu
        }
        else{
            //MenuWidthConstraint.constant = 0
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
    
    //MARK: - Fetch Data

    //Fetch data from firebase and get open for adding child
    func FetchRoom(){
        let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
        let uid = Auth.auth().currentUser?.uid
        let RefRoom = ref.child("users/\(uid!)/Rooms")
        RefRoom.observe(.childAdded, with: { (snap) in
            print("AddedSnap")
            print(snap.key)
            let Switches = snap.value as! NSDictionary
            self.SwitchesInRoomsStore.append(Switches as! Dictionary<String, Any>)
            self.rooms.append(snap.key)
            let indexpath = IndexPath(row: self.rooms.count-1, section: 0)
            //self.CollectionViewRooms.reloadItems(at: [indexpath])
            //self.CollectionViewRooms.reloadData()
            self.CollectionViewRooms.insertItems(at: [indexpath])
        })
        
        RefRoom.observe(.childChanged, with: { (snapshot) in
            print("Changed Snap")
            let index = self.rooms.index(of: snapshot.key)!
            self.SwitchesInRoomsStore.remove(at: index)
            let Switches = snapshot.value as! NSDictionary
            self.SwitchesInRoomsStore.insert(Switches as! Dictionary<String, Any>, at: index)
            print(snapshot)
        })
        RefRoom.observe(.childRemoved, with: { (snapy) in
            print("Removed Snap")
            let index = self.rooms.index(of: snapy.key)!
            self.rooms.remove(at: index)
            self.SwitchesInRoomsStore.remove(at: index)
            let indexpath = IndexPath(row: index, section: 0)
            self.CollectionViewRooms.deleteItems(at: [indexpath])
            print(snapy)
        })
    }
    
    //Remove Value from Firebase & local Rooms array
    func DeleteRoom(RoomName:String){
        let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
        let uid = Auth.auth().currentUser?.uid
        ref.child("users/\(uid!)/Rooms/").child(RoomName).removeValue()
    }
    
}
