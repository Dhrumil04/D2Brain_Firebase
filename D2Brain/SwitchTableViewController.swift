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

class SwitchTableViewController: UITableViewController {

    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    var SwitchStore = [Dictionary<String, Any>]()
    var MachinesStore = [String]()
    var newData:Bool!
    var previousCount:Int!
    @IBOutlet var SegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false
        print("View Did Load")
        self.newData = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear")
        //DataFetch()
         print("New Data value is \(self.newData)")
        if((!newData)){
            DataFetch2()
            previousCount = 0
            SegmentedControl.removeAllSegments()
        }

        
        
    }
    
    @IBAction func SegmentControlValueChanged(_ sender: Any) {
        self.tableView.reloadData()
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
            print("Previous Count is \(self.previousCount)")
            print("Machine Store Count for table view \(MachinesStore.count)")
            print("Selected Segmented Control is \(SegmentedControl.selectedSegmentIndex)")
            previousCount = MachinesStore.count
            print("Previous Count is \(self.previousCount)")
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
        return cell
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

    @IBAction func RenameSwitch(RenameButton: UIButton) {
        AlertRename(title: "Rename",message: "",RenameButton: RenameButton)
        
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
    func DataFetch2(){
        let Machines = self.ref.child("users/\(uid!)/Machines")
        Machines.observe(.childAdded, with: { (snapshot) in
            //print(snapshot)
            let result = snapshot.value as! [String:AnyObject]
            //print(result)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                let name = result["MachineName"] as! String
                let Switches = result["Switches"] as! NSDictionary
                self.SwitchStore.append(Switches as! Dictionary<String, Any>)
                self.MachinesStore.append(name)
                print("Machine Count is\(self.MachinesStore.count) and names after appending is \(self.MachinesStore)")
                print("Switch count is \(self.MachinesStore.count) and Switches after appending is \(self.SwitchStore)")
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
