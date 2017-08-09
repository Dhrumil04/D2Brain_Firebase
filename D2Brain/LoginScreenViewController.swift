//
//  LoginScreenViewController.swift
//  
//
//  Created by Purvang Shah on 26/07/17.
//
//

import UIKit

class LoginScreenViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        print("LoginScreen called")
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.hidesBackButton = true
        //navigationItem.backBarButtonItem?.isEnabled = false
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Login"{
            if let destination = segue.destination as? LoginPopup{
                destination.segueIndetifier = "Login"
            }
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
