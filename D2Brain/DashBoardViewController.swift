//
//  DashBoardViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 29/07/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseAuth


class DashBoardViewController: UIViewController {

    
    @IBOutlet var MenuLeadingConstraint: NSLayoutConstraint!
   
    @IBOutlet var MenuWidthConstraint: NSLayoutConstraint!
   
    @IBOutlet var MenuView: UIView!
    var newData = false
    var RoomName = ""
    var showmenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().isHidden = false
        print("View did load called")
       // MenuWidthConstraint.constant = -140
        let id = Auth.auth().currentUser?.uid
        self.MenuView.layer.shadowOpacity = 1
        self.MenuView.layer.shadowRadius  = 3
        
        print(id ?? "Nothing")
        if (Auth.auth().currentUser == nil){
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginScreen")
            self.present(controller, animated: true, completion: nil)
    
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func CreateRoom(_ sender: Any) {
        RoomName(title:"Create Room",message:"Give a Name")
    }
    func RoomName(title:String,message:String){
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        MenuLeadingConstraint.constant = -140
        showmenu = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "SwitchView" {
                    let controller = segue.destination as? SwitchTableViewController
                    controller?.RoomName = self.RoomName
                    self.RoomName = ""
            }
     
     }
    
    @IBAction func MenuButtonAction(_ sender: Any) {
        
        if(showmenu){
            //MenuWidthConstraint.constant = -140
            MenuLeadingConstraint.constant = -140
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
                       print("Hide")

        }
        else{
            //MenuWidthConstraint.constant = 0
            MenuLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })

                        print("Show")
        }
        showmenu = !showmenu
    }

    @IBAction func LogoutAction(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            print("No Error")
            
        }
        catch let SignOutError as NSError{
            print(SignOutError)
            
        }
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
