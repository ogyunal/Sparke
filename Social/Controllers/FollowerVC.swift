//
//  FollowerVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import Photos

class FollowerVC: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var receivedButton: UIButton!
    @IBOutlet var takenButton: UIButton!
    
    //MARK: Variables
    var users = [User]()
    var selectedIndex = 0
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.activityStartAnimating()
        
        receivedButton.tag = 0
        takenButton.tag = 1
        
        navigationController?.navSetup()
        
        //Collection View
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        getUsers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getUsers), name: .refreshFollowing, object: nil)
        
    }

    @objc func getUsers() {
        
        var type = ""
        
        if selectedIndex == 0 {
            
            type = "following"
            
        } else {
            
            type = "followers"
        }
        
        GetUsers().getUsers(type) { (users, success) in
            if success {
                self.users.removeAll()
                self.users = users
                self.view.activityStopAnimating()
                self.tableView.reloadData()
            } else {
                self.view.activityStopAnimating()
                self.tableView.reloadData()
                
            }
        }
    }
    
    @IBAction func segmentaction(_ sender: UIButton) {
        
        guard selectedIndex != sender.tag else {
            print("same segment selected")
            return
        }
        
        self.view.activityStartAnimating()
        
        if sender.tag == 0 {
            //Following
            selectedIndex = 0
            receivedButton.setTitleColor(.black, for: .normal)
            takenButton.setTitleColor(#colorLiteral(red: 0.6079999804, green: 0.6079999804, blue: 0.6079999804, alpha: 1), for: .normal)
            getUsers()
            title = "Following"
        } else {
            //Followers
            selectedIndex = 1
            receivedButton.setTitleColor(#colorLiteral(red: 0.6079999804, green: 0.6079999804, blue: 0.6079999804, alpha: 1), for: .normal)
            takenButton.setTitleColor(.black, for: .normal)
            getUsers()
            title = "Followers"
        }
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UserCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UserCell
        
        configureCell(cell: cell, index: indexPath)
       
        return cell

    }
    
       
    func configureCell(cell: UserCell, index: IndexPath) {
          
        let user = users[index.row]
        
        cell.nameLabel.text = String("\(user.first_name!) \(user.last_name!)")
        cell.userImage.roundedImage()
        
        if user.imageUrl != "" {
            
            cell.userImage.loadImageUsingCacheUrlString(urlString: user.imageUrl!, scale: .scaleAspectFill, completion: {(result) -> () in
                
                DispatchQueue.main.async {

                    if result {
                        self.view.activityStopAnimating()
                    
                    } else {
                        self.view.activityStopAnimating()
                        cell.userImage.image = UIImage(named: "Logo")
                    
                    }
                }
            })
            
        }  else {
            
            self.view.activityStopAnimating()
            cell.userImage.image = UIImage(named: "Logo")
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileVC
        
        let user = users[indexPath.row]
        
        vc.myProfile = false
        vc.userId = user.id!
                            
        self.navigationController?.pushViewController(vc, animated: true)
                    
    }
}
