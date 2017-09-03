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
    var DimmerCount = 11
    var SwitchDict = [String:String]()
    var DimmerDict = [String:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.MachineName.delegate = self
        self.IPAddress.delegate = self
        self.SerialNumber.delegate = self
        for Switch in 1..<SwitchCount{
            SwitchDict.updateValue("Switch \(Switch)", forKey: "sw\(Switch)")
        }
        for Dimmer in 1..<DimmerCount{
            DimmerDict.updateValue("Dimmer \(Dimmer)", forKey: "dm\(Dimmer)")
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
            let machine = machineref.child("\(MachineName.text!)")
           //let newMachine = Machine(Name: MachineName.text!, IP: IPAddress.text!, Serial: SerialNumber.text!)
            machine.setValue(["MachineName":MachineName.text!,"IP":IPAddress.text!,"SerialNumber":SerialNumber.text!,"Switches":SwitchDict,"Dimmer":DimmerDict])
            print("Machine adeded successfully")
           // MachinesViewController.MachineStore.updateValue(newMachine, forKey: newMachine.MachineName)
            //DashBoardViewController.MachineStore.updateValue(newMachine, forKey: newMachine.MachineName)
            dismiss(animated: true, completion: nil)
        }
        else{
            print("Fill all the fields")
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated:true,completion:nil)
    }
}
