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

class RoomViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet var DetailRoomCollectionView: UICollectionView!
    
    var Switches = Dictionary<String,Any>()
    var copySwitches : Dictionary<String,Any>!
    var Changehandle: DatabaseHandle!
    var RoomName = ""
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    let uid = Auth.auth().currentUser?.uid
    var RefRoom : DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        copySwitches = Switches
        RefRoom = ref.child("users/\(uid!)/Rooms/\(RoomName)")
        self.Changehandle = RefRoom.observe(.childChanged, with: { (snapshot) in
            print("In room view snpashot name changed \(snapshot)")
            self.Switches.updateValue(snapshot.value as! String, forKey: snapshot.key)
            self.DetailRoomCollectionView.reloadData()
        })
       

        // Do any additional setup after loading the view.
    }

    override func viewDidDisappear(_ animated: Bool) {
        if self.Changehandle != nil{
             RefRoom.removeObserver(withHandle: self.Changehandle)
            print("Removing change handle")
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print(Switches.count)
        //print(Switches)
        return Switches.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomSwitchCell", for: indexPath) as! RoomDetailCollectionViewCell
       // print(Switches.popFirst()?.value ?? "HI")
            let names = Switches.popFirst()?.value
            //print(names!)
            cell.SwitchNameLabel.text = names as? String
            cell.contentView.layer.cornerRadius = 9.0
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.masksToBounds = true
            if(Switches.isEmpty){
                Switches = copySwitches
            }
               return cell
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
