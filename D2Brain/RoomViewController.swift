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

class RoomViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

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
    override func viewDidLoad() {
        super.viewDidLoad()
        
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


        // Do any additional setup after loading the view.
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Switches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/4-10, height: collectionView.bounds.size.width/4-10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomSwitchCell", for: indexPath) as! RoomDetailCollectionViewCell
       // print(Switches.popFirst()?.value ?? "HI")
            let names = Switches.popFirst()?.value

            cell.SwitchNameLabel.text = names as? String
            cell.contentView.layer.cornerRadius = 9.0
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.masksToBounds = true
            if(Switches.isEmpty){
                Switches = copySwitches
            }
               return cell
    
    }
}
