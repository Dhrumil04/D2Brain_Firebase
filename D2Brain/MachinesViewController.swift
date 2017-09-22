
//  MachinesViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 06/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MachinesViewController: UITableViewController {

    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    var copyStore: Dictionary<String,Machine>!
    override func viewDidLoad() {
        super.viewDidLoad()
        copyStore = DashBoardViewController.MachineStore
        let Machineref = self.ref.child("users/\(uid!)/Machines/")
        Machineref.observe(.childAdded, with: { (snapshot) in
            let key = snapshot.key
            let MachineDict = snapshot.value as! [String:AnyObject]
            let newMachine = Machine(Name: MachineDict["MachineName"] as! String,  IP: MachineDict["IP"] as! String, Serial:  MachineDict["SerialNumber"] as! String, Switches: MachineDict["Switches"] as! Dictionary<String, String>, Dimmers: MachineDict["Dimmers"] as! Dictionary<String, String>)
                DashBoardViewController.MachineStore.updateValue(newMachine, forKey: key)
            self.tableView.reloadData()
        })
        Machineref.observe(.childRemoved, with: { (snap) in
            let key = snap.key
            DashBoardViewController.MachineStore.removeValue(forKey: key)
            self.tableView.reloadData()
        })
        
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DashBoardViewController.MachineStore.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MachineCell") as! MachineTableViewCell
        if(self.copyStore.isEmpty){
            copyStore = DashBoardViewController.MachineStore
        }
        let MachineCell = self.copyStore.popFirst()
        cell.MachineName.text = MachineCell?.value.MachineName
        cell.MachineIP.text = MachineCell?.value.MachineIP
        cell.MachineSerialNumber.text = MachineCell?.value.MachineSerialNumber
        cell.key = MachineCell?.key
        return cell
    }

    func AlertDelete(title:String,message:String,DeleteButton:UIButton){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if let cell = DeleteButton.superview?.superview as? MachineTableViewCell {
                let indexPath = self.tableView.indexPath(for: cell)
                print((indexPath?.row)!)
                let Machineref = self.ref.child("users/\(self.uid!)/Machines/")
                print("Deleting Machine \(cell.MachineName.text!)")
                Machineref.child(cell.key!).removeValue()
                self.DeleteSwicthesInRoom(DeletedMachine: cell.key!)
                self.DeleteDimmerInRoom(DeletedMachine: cell.key!)
                DashBoardViewController.MachineStore.removeValue(forKey: cell.key!)
                self.tableView.reloadData()
            }

            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func DeleteMachineCell(DeleteButton:UIButton) {
        AlertDelete(title: "Delete", message: "Are you sure you want to Delete this Machine?", DeleteButton: DeleteButton)
        
    }

    func DeleteSwicthesInRoom(DeletedMachine:String){
        print("Removing")
        let SwitchRemover = self.ref.child("users/\(self.uid!)/Rooms/")
        SwitchRemover.observeSingleEvent(of: .value, with: { (snapshot) in
            let Objects = snapshot.children.allObjects as! [DataSnapshot]
            for childs in Objects {
                print(childs)
                let Switches = childs.children.allObjects as! [DataSnapshot]
                for SingleSwitch in Switches {
                    print(SingleSwitch)
                    let MachineSeparateName = SingleSwitch.key.components(separatedBy: "Switch")
                    print(MachineSeparateName)
                    if (MachineSeparateName[0] == DeletedMachine){
                        print("in remove \(MachineSeparateName[0])")
                       self.ref.child("users/\(self.uid!)/Rooms/").child("\(childs.key)").child("\(SingleSwitch.key)").removeValue()
                    }
                }
            }
            
        })
        
        
    }
    func DeleteDimmerInRoom(DeletedMachine:String){
        print("Removing")
        let DimmerRemover = self.ref.child("users/\(self.uid!)/Rooms/")
        DimmerRemover.observeSingleEvent(of: .value, with: { (snapshot) in
            let Objects = snapshot.children.allObjects as! [DataSnapshot]
            for childs in Objects {
                print(childs)
                let Switches = childs.children.allObjects as! [DataSnapshot]
                for SingleSwitch in Switches {
                    print(SingleSwitch)
                    let MachineSeparateName = SingleSwitch.key.components(separatedBy: "Dimmer")
                    print(MachineSeparateName)
                    if (MachineSeparateName[0] == DeletedMachine){
                        print("in remove \(MachineSeparateName[0])")
                        self.ref.child("users/\(self.uid!)/Rooms/").child("\(childs.key)").child("\(SingleSwitch.key)").removeValue()
                    }
                }
            }
            
        })
        
        
    }


}
