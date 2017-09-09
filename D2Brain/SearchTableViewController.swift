//
//  SearchTableViewController.swift
//  D2Brain
//
//  Created by Purvang Shah on 07/09/17.
//  Copyright © 2017 psolution. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class SearchTableViewController: UITableViewController,UISearchResultsUpdating {
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference(fromURL:"https://d2brain-87137.firebaseio.com/")
    var AllSwitches = Dictionary<String,String>()
    var Switches = [NSDictionary]()
    var number = 0
    let SearchController = UISearchController(searchResultsController: nil)
    var FilterArray = Dictionary<String,String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        Fetch()
        SearchController.searchResultsUpdater = self
        SearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = SearchController.searchBar

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return SearchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(searchText: String) {
        for (key,value) in AllSwitches{
            if value == searchText {
                FilterArray.updateValue(value, forKey: key)
            }
        }
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return SearchController.isActive && !searchBarIsEmpty()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if isFiltering() {
            return 1
        }
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(isFiltering()){
            return FilterArray.count
        }
        if(Switches.count != 0){
            return Switches[section].count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchSwitchCell", for: indexPath) as! SearchTableViewCell
        if (isFiltering()){
            cell.SwitchNameLabel.text = FilterArray.popFirst()?.value
        }else{
             cell.SwitchNameLabel.text = Switches[indexPath.section].value(forKey: "sw\(indexPath.row+1)") as? String
        }
        
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: SearchController.searchBar.text!)
    }
 
    func Fetch(){
        let Machineref = self.ref.child("users/\(uid!)/Machines/")
        Machineref.observe(.value, with: { (snapshot) in
            let Machines = snapshot.children.allObjects as? [DataSnapshot]
            for Machine in Machines!{
                let MachineName = Machine.key
                let Value = Machine.value as! [String:AnyObject]
                let Switches = Value["Switches"] as! NSDictionary
                let Dimmers = Value["Dimmer"] as! NSDictionary
                for Switchkey in Switches.allKeys{
                    let SwitchName = Switches.value(forKey: Switchkey as! String) as! String
                    self.AllSwitches.updateValue(SwitchName, forKey: "\(MachineName)\(Switchkey)")
                    self.Switches.append(Switches)
                }
                for Dimmerkey in Dimmers.allKeys{
                    let DimmerName = Dimmers.value(forKey: Dimmerkey as! String) as! String
                    self.AllSwitches.updateValue(DimmerName, forKey: "\(MachineName)\(Dimmerkey)")
                }
                print("All Switches printing is \(self.AllSwitches)")
            }
            self.tableView.reloadData()
        })
    }

}
