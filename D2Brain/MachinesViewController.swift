
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
    var Machinecount = 0
    var MachineStore = [Machine]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let Machineref = self.ref.child("users/\(uid!)/Machines/")
        Machineref.observe(.childAdded, with: { (snapshot) in
           // print(snapshot)
            let MachineDict = snapshot.value as! [String:AnyObject]
            //print(MachineDict)
            let newMachine = Machine(Name: MachineDict["MachineName"] as! String,  IP: MachineDict["IP"] as! String, Serial:  MachineDict["SerialNumber"] as! String)
            self.MachineStore.append(newMachine)
            print(self.MachineStore.count)
            self.tableView.reloadData()
        })
        
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.MachineStore.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MachineCell") as! MachineTableViewCell
        let MachineCell = MachineStore[indexPath.row]
        cell.MachineName.text = MachineCell.MachineName
        cell.MachineIP.text = MachineCell.MachineIP
        cell.MachineSerialNumber.text = MachineCell.MachineSerialNumber
        return cell
    }

    func AlertDelete(title:String,message:String,DeleteButton:UIButton){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if let cell = DeleteButton.superview?.superview as? MachineTableViewCell {
                let indexPath = self.tableView.indexPath(for: cell)
                print((indexPath?.row)!)
                self.MachineStore.remove(at: (indexPath?.row)!)
                let Machineref = self.ref.child("users/\(self.uid!)/Machines/")
                Machineref.child(cell.MachineName.text!).removeValue()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
