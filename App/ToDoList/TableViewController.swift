//
//  TableViewController.swift
//  ToDoList
//
//  Created by Phan Nguyen on 6/25/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class TableViewController: UITableViewController {

    
    @IBAction func logoutButtonPress(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "todosDictionary")
        
        self.navigationController!.performSegue(withIdentifier: "showLoginViewController", sender: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 68.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let todoIds = User.todoIds {
            return todoIds.count
        } else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseidentifier", for: indexPath) as! TableViewCell
        
        if let todoData = User.todosDictionary, let todoIds = User.todoIds {
            let id = todoIds[indexPath.row]
            if let todoDictionary = todoData[id]  {
                cell.label.text = todoDictionary["text"]
                if let url = todoDictionary["imageURL"]  {
                    //should cache image for better performance
                    if let url = NSURL(string: url), let data = NSData(contentsOf: url as URL), let image = UIImage(data: data as Data) {
                        cell.todoImageView.image = image
                    }
                }
            }
        }
        
        return cell

    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        User.refreshTodos { (success) in
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            handleDeleteTodo(indexPath: indexPath as NSIndexPath)
        }

    }
    
    
    func handleDeleteTodo(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let loader = SwiftLoading()
        loader.showLoading()
        
        if let todoIds = User.todoIds {
            let todoId = todoIds[indexPath.row]
            User.deleteTodo(id: todoId, completionHandler: { (success) in
                
                if (success) {
                    self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                } else {
                    print("Couldn't delete todo")
                }
                
                loader.hideLoading()
                self.tableView.endUpdates()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250;
    }
    }
