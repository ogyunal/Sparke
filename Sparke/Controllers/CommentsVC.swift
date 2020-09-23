//
//  CommentsVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import Photos

class CommentsVC: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var emptyLabel: UILabel!
    
    //MARK: Variables
    var comments = [Comment]()
    var postId: String!
    var myPost = false
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
       
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.activityStartAnimating()
        
        navigationController?.navSetup()
        
        //Collection View
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        textView.delegate = self
        textView.layer.cornerRadius = 15
        textView.layer.borderColor = #colorLiteral(red: 0.6079999804, green: 0.6079999804, blue: 0.6079999804, alpha: 1)
        textView.layer.borderWidth = 1
        
        //Refresh Control
        refreshControl.addTarget(self, action: #selector(getComments), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        getComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getComments), name: .refreshComments, object: nil)
        
        adjustRowHeight()
        
    }

    func adjustRowHeight() {
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        
    }
    
    @objc func getComments() {
        
        GetComments().getComments(self.postId) { (comments, success) in
            if success {
                self.comments.removeAll()
                self.comments = comments
                self.view.activityStopAnimating()
                self.reloadTableView()
                self.emptyLabel.alpha = 0
                self.tableView.separatorStyle = .singleLine
                self.adjustRowHeight()
            } else {
                self.view.activityStopAnimating()
                self.reloadTableView()
                self.emptyLabel.alpha = 1
                self.tableView.separatorStyle = .none
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let comment = comments[indexPath.row]
        
        if comment.userId == Constants.userId || myPost == true {
            
            return true
            
        } else {
            
            return false
        }
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let comment = comments[indexPath.row]
            
            removeComment(commentId: comment.commentId)
        }
    }
    
    func removeComment(commentId: String) {
    
        Constants.ref.child("comments").child(commentId).removeValue(completionBlock: {(error, ref) in
            
            if error != nil {
                
                self.showCustomAlert(title: "Error", message: error!.localizedDescription)
                
            } else {
                
                DispatchQueue.main.async {
                    
                    self.removeCommentFromPost(commentId: commentId)
                    
                }
            }
        })
    }
    
    func removeCommentFromPost(commentId: String) {
        
        Constants.ref.child("posts").child(postId).child("comments").child(commentId).removeValue(completionBlock: {(error, ref) in
                   
            if error != nil {
                       
                self.showCustomAlert(title: "Error", message: error!.localizedDescription)
                       
            } else {
                       
                DispatchQueue.main.async {
                           
                    self.getComments()
                    self.incrementComment(type:"Remove")
                           
                }
            }
        })
    }
    
    func reloadTableView() {
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        
            self.refreshControl.endRefreshing()
            
        }
    }
    
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CommentCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CommentCell
        
        configureCell(cell: cell, index: indexPath)
       
        return cell

    }
    
       
    func configureCell(cell: CommentCell, index: IndexPath) {
          
        let comment = comments[index.row]
        
        GetUserInfo().getUserInfo(comment.userId) { (userInfo, success) in
            if success {
                
                cell.nameLabel.text = String("\(userInfo.firstName) \(userInfo.lastName) • \(comment.timestamp.dateFormat())")
                cell.commentText.text = comment.content

                if  userInfo.imageUrl == "" {
                    
                    self.view.activityStopAnimating()
                    cell.userImage.image = UIImage(named: "Logo")
                    
                } else {
                    
                    self.userImage(cell: cell, imageUrl: userInfo.imageUrl)
                    
                }
            }
        }
    }
    
    func userImage(cell: CommentCell, imageUrl: String) {
        
        cell.userImage.loadImageUsingCacheUrlString(urlString: imageUrl, scale: .scaleAspectFill, completion: {(result) -> () in
                
            DispatchQueue.main.async {

                if result {
                    self.view.activityStopAnimating()
                    cell.userImage.roundedImage()
                    
                } else {
                    
                    self.view.activityStopAnimating()
                    cell.userImage.image = UIImage(named: "Logo")
                    cell.userImage.roundedImage()
                    
                }
            }
        })
    }
    
    @IBAction func postComment() {
        
        if textView.text.count ==  0 || textView.text.count > 140 {
            
            self.showCustomAlert(title: "", message: "Your comment must contain between 1 and 140 characters")
            
        } else {
            
            self.view.activityStartAnimating()
            let commentId =  Constants.ref.child("comments").child(postId).childByAutoId().key
            let timestamp = Date().timeIntervalSince1970
            
            let commentJson: [String: Any]  = [
                "userId" : Constants.userId,
                "content": textView.text!,
                "timestamp" : timestamp,
                "postId" : postId!
            ]
            
            saveComment(commentId: commentId!, content: commentJson)
           
        }
    }
    
    func saveComment(commentId: String, content: [String:Any]) {
        
        Constants.ref.child("comments").child(commentId).updateChildValues(content, withCompletionBlock: {(error,ref) in
                       
            if error != nil {
                           
                self.showCustomAlert(title: "Error", message: String(error!.localizedDescription))
                self.view.activityStopAnimating()
                           
            } else {
                           
                self.saveCommentInPost(commentId: commentId)
            }
        })
    }
    
    func saveCommentInPost(commentId: String) {
        
        Constants.ref.child("posts").child(postId).child("comments").updateChildValues([commentId: true], withCompletionBlock: {(error,ref) in
                                  
            if error != nil {
                                      
                self.showCustomAlert(title: "Error", message: String(error!.localizedDescription))
                                      
            } else {
                                      
                self.incrementComment(type: "Add")
                self.getComments()
            }
        })
    }
    
    func incrementComment(type: String) {
           
        let commentsRef = Constants.ref.child("posts").child(self.postId).child("commentCount")
           
           commentsRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
               
            var currentCount = currentData.value as? Int ?? 0
                   
            if type == "Add" {
                
                currentCount += 1
                
                DispatchQueue.main.async {
                    
                    self.showCustomAlert(title: "", message: "Your comment has been posted")
                    NotificationCenter.default.post(name: .getPosts, object: nil)
                    self.view.activityStopAnimating()
                    NotificationCenter.default.post(name: .updateCommentCount, object: nil)
                }
                
            } else {
                
                currentCount -= 1
                
                DispatchQueue.main.async {
                    
                    self.showCustomAlert(title: "", message: "You have removed this comment")
                    NotificationCenter.default.post(name: .getPosts, object: nil)
                    self.view.activityStopAnimating()
                    NotificationCenter.default.post(name: .updateCommentCount, object: nil)
                
            }
        }
               
               currentData.value = currentCount
               return TransactionResult.success(withValue: currentData)
               
           })
       }
    }
