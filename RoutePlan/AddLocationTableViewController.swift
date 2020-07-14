//
//  AddLocationTableViewController.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/12.
//  Copyright © 2020 hanjian. All rights reserved.
//

import UIKit

class AddLocationTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var tips = [Any]()
    
    lazy var searchResultTableView : SearchResultTableView = {
        let searchResultTableView = SearchResultTableView(frame: self.searchController.view.bounds, style: .plain)
        self.searchController.view.addSubview(searchResultTableView)
        searchResultTableView.didSelectTip = { tip in
            self.searchController.isActive = false
            self.tips.append(tip)
            self.tableView.insertRows(at: [IndexPath(row: self.tips.count-1, section: 0)], with: .automatic)
        }
        return searchResultTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        self.navigationItem.rightBarButtonItem = self.editButtonItem
//        tableView.allowsSelection = false
        
        searchController.searchBar.placeholder = "input address"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        searchController.delegate = self
    }

    
    //MARK: - Action
    func searchTip(withKeyword keyword: String?) {
        
        if keyword?.count == 0 {
            return
        }

    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tips.count+100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if indexPath.row >= tips.count {
            return cell
        }

//        let tip = tips[indexPath.row]
    //
    //        cell.textLabel?.text = tip.name
    //        cell.detailTextLabel?.text = tip.address

        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return unsafeBitCast(3, to: UITableViewCell.EditingStyle.self)
//    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tips.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddLocationTableViewController: UISearchControllerDelegate,UISearchResultsUpdating {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.toolbar.isHidden = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.toolbar.isHidden = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTip(withKeyword: searchController.searchBar.text)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            searchController.searchBar.placeholder = searchController.searchBar.text
        }
    }
}
