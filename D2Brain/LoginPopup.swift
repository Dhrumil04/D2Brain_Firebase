//
//  LoginPopup.swift
//  D2Brain
//
//  Created by Purvang Shah on 26/07/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginPopup: UIViewController,UITextFieldDelegate {

    @IBOutlet var Password: UITextField!
    @IBOutlet var Email: UITextField!
    var segueIndetifier = "signup"
    @IBOutlet var LoginSignUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if segueIndetifier == "Login"{
            LoginSignUpButton.setTitle("Login", for: .normal)
        }
       self.Email.delegate = self
        self.Password.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.delegate = self
        textField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func LoginSignUpAction(_ sender: Any) {
        if segueIndetifier == "Login"{
            if Email.text != "" && Password.text != nil{
                Auth.auth().signIn(withEmail: Email.text!, password: Password.text!){ (user,error) in
                    if error != nil {
                        print("This is Error")
                        print(error!.localizedDescription)
                        return
                    }
                    if user != nil{
                        print("This is User Info")
                        print(user!.email!)
                        print(user!.uid)
                        let controller  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Root")
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                }
            print("Login")
            //login logic
            }
        }
        else{
            if Email.text != "" && Password.text != nil{
                Auth.auth().createUser(withEmail: Email.text!, password: Password.text!){ (user,error) in
                    if error != nil {
                            print("This is Error")
                            print(error!.localizedDescription)
                            return
                        }
                    if user != nil{
                            print("This is User Info")
                            print(user!.email!)
                            print(user!.uid)
                            let controller  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Root")
                            self.present(controller, animated: true, completion: nil)

                        }
                    }

            print("signup")
            //signuplogic
                }
    
    
            }
        }
}
