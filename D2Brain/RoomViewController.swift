//
//  RoomViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 14/08/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    
    var Switches:Dictionary<String,Any>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override  func viewWillDisappear(_ animated: Bool) {
        print("view disappearing")
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
         print(names!)
        cell.SwitchNameLabel.text = names as? String
        cell.contentView.layer.cornerRadius = 9.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.masksToBounds = true
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
