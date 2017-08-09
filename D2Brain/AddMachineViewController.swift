//
//  AddMachineViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 30/07/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddMachineViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet var MachineName: UITextField!
    @IBOutlet var IPAddress: UITextField!
    @IBOutlet var SerialNumber: UITextField!
    var ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    var uid = Auth.auth().currentUser?.uid
    
    var SwitchCount = 34
    var SwitchDict = [String:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.MachineName.delegate = self
        self.IPAddress.delegate = self
        self.SerialNumber.delegate = self
        for Switch in 1..<SwitchCount{
            SwitchDict.updateValue("Switch \(Switch)", forKey: "sw\(Switch)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.delegate = self
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func AddAction(_ sender: Any) {
        if((MachineName.text != "") && (IPAddress.text != "") && (SerialNumber.text != "")){
            print("adding machine")
            let machineref = self.ref.child("users/\(uid!)/Machines")
            //autoid.setValue(["MachineName":MachineName.text!,"IP":IPAddress.text!,"SerialNumber":SerialNumber.text!])
            let machine = machineref.child("\(MachineName.text!)")
            machine.setValue(["MachineName":MachineName.text!,"IP":IPAddress.text!,"SerialNumber":SerialNumber.text!,"Switches":SwitchDict])
            print("Machine adeded successfully")
            //let Switches = machineref.child("\(MachineName.text!)").child("Switches")
            //Switches.setValue(self.SwitchDict)
            dismiss(animated: true, completion: nil)
        }
        else{
            print("Fill all the fields")
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated:true,completion:nil)
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
