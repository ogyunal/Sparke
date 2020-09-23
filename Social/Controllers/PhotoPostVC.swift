 //
//  PhotoPostVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PhotoPostVC: UIViewController  {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var commentCountLabel: UILabel!
    
    var userId: String!
    var mainImage: UIImage!
    var myPost: Bool!
    var fromProfile = false
    var post: Post!
    var liked: Bool!
    var likeCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCommentCount), name: .updateCommentCount, object: nil)
        
        userImageView.alpha = 0
        
        self.view.activityStartAnimating()
        
        navigationController?.navSetup()
        
        imageView.image = mainImage
        
        userImageView.roundedImage()
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.borderWidth = 2
        
        getUserName()
        
        if myPost {
            
            self.userImageView.image = Constants.myImage
            alphaAnimate()
            self.userNameLabel.text = String("\(Constants.fName) \(Constants.lName)")
            
        } else {
                   
            getUserName()
            
        }

        timeLabel.text = post.timestamp.dateFormat()
        likeCountLabel.text = String(post.likeCount)
        commentCountLabel.text = String(post.commentCount)
        likeCount = Int(post.likeCount)
        getCurrentUserLike()
        
    }
    
    @objc func updateCommentCount() {
        
        Constants.ref.child("posts").child(post.postId).child("comments").observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.exists() {
                
                self.commentCountLabel.text = String(snapshot.childrenCount)
                
            } else {
                
                self.commentCountLabel.text = "0"
            }
        })
    }
    
    func getCurrentUserLike() {
        
        Constants.ref.child("posts").child(post.postId).child("likes").child(Constants.userId).observeSingleEvent(of: .value, with: { snapshot in 
            
            if snapshot.exists() {
                
                self.liked = true
                self.configureLikeButton()
                
            } else {
                
                self.liked = false
                self.configureLikeButton()
                
            }
        })
    }
    
    func configureLikeButton() {
        
        if liked {
            
            self.likeButton.setImage(UIImage(named: "likedWhite"), for: .normal)
            self.likeCountLabel.text = String(likeCount)
            
        } else {
            
            self.likeButton.setImage(UIImage(named: "unLikedWhite"), for: .normal)
            self.likeCountLabel.text = String(likeCount)
            
        }
    }
    
    func alphaAnimate() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.userImageView.alpha = 1.0
            
        })
        
    }
    
    func getUserName() {
        
         GetUserInfo().getUserInfo(self.userId) { (userInfo, success) in
            if success {
                       
                self.userNameLabel.text = String("\(userInfo.firstName) \(userInfo.lastName)")
                self.getUserImage(imageUrl: userInfo.imageUrl)
                
            }
        }
    }
    
    func getUserImage(imageUrl: String) {

        guard imageUrl != "" else {
            self.userImageView.image = UIImage(named: "Logo")
            alphaAnimate()
            self.view.activityStopAnimating()
            return
        }
        
        userImageView.loadImageUsingCacheUrlString(urlString: imageUrl, scale: .scaleAspectFill, completion: {(result) -> () in
        
            DispatchQueue.main.async {
            
                if result {
                
                    self.view.activityStopAnimating()
                    self.alphaAnimate()
                } else {
                    
                    self.userImageView.image = UIImage(named: "Logo")
                    self.alphaAnimate()
                    self.view.activityStopAnimating()
                }
            
            }
        })
    }
    
    @IBAction func seeComments() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "comments") as! CommentsVC
        vc.postId = self.post.postId
        
        if myPost {
            
            vc.myPost = true
    
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func likeAction() {
        
        self.view.activityStartAnimating()
        
        if liked {
            
            removeLike()
            
        } else {
            
            addLike()
        }
    }
    
    func addLike() {
        
        AddLike().addLike(post.postId) { (success) in
            
            if success {
                
                self.liked = true
                self.likeCount += 1
                self.configureLikeButton()
                
                self.incrementLike(direction: "Like")
            } else {
                
                self.showErrorAlert()
                self.view.activityStopAnimating()
            }
        }
    }
    
    func removeLike() {
        
       RemoveLike().removeLike(post.postId) { (success) in
            
            if success {
                
                self.liked = false
                self.likeCount -= 1
                self.configureLikeButton()
                
                self.incrementLike(direction: "Dislike")
            } else {
                
                self.showErrorAlert()
                self.view.activityStopAnimating()
            }
        }
    }
    
    func refreshHome(type: String) {
        
        var textString = "un-liked"
        
        if type == "Like"  {
            
            textString  = "liked"
        }
        
        self.showCustomAlert(title: "Success", message: "You have \(textString) this post")
        NotificationCenter.default.post(name: .getPosts, object: nil)
        self.view.activityStopAnimating()
    }
    
    func incrementLike(direction: String) {
        
        let likeCountRef = Constants.ref.child("posts").child(post.postId).child("likeCount")
        
        likeCountRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
            
            var currentCount = currentData.value as? Int ?? 0
            
            if direction == "Like" {
                
                currentCount += 1
                
                DispatchQueue.main.async {
                    
                    self.refreshHome(type: direction)
                }
                
            } else {
                
                currentCount -= 1
            
                DispatchQueue.main.async {
                    
                    self.refreshHome(type: direction)
                }
                
            }
            
            currentData.value = currentCount
            return TransactionResult.success(withValue: currentData)
            
        })
    }
    
    @IBAction func profileAction() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileVC
        
        guard fromProfile == false else {
            self.navigationController?.popViewController(animated: true)
            return
        }
            
        if self.userId == Constants.userId {
                      
            tabBarController?.selectedIndex = 1
                      
        } else {
                      
            vc.myProfile = false
            vc.userId = self.userId!
                      
            self.navigationController?.pushViewController(vc, animated: true)
                  
        }
    }
    
    @IBAction func reportAction() {
        
        if myPost {
            
            self.oneActionSheet("Remove Post") { (result) in
                
                if result {
                    
                    self.removePost()
                }
            }
            
        } else {
          
            self.oneActionSheet("Report") { (result) in
                
                if result {
                    
                    self.uploadReport()
                }
            }
            
        }
        
    }
    
    func removePost() {
        
        self.view.activityStartAnimating()
        
        Constants.ref.child("posts").child(self.post.postId).removeValue(completionBlock: {(error,ref) in
        
        if error == nil {
                       
            NotificationCenter.default.post(name: .getPosts, object: nil)
            self.navigationController?.popViewController(animated: true)
            self.view.activityStopAnimating()
                  
        } else {
                       
            self.showErrorAlert()
            self.view.activityStopAnimating()
                  
        }
                   
    })
}
    
    func uploadReport() {
        
        self.view.activityStartAnimating()
        
        let reportId = Constants.ref.child("reports").child(self.post.postId).childByAutoId().key
        Constants.ref.child("reports").child(self.post.postId).updateChildValues([reportId : Constants.userId], withCompletionBlock: {(error, ref) in
            
            if error != nil {
                
                self.showCustomAlert(title: "", message: "Thank you for submitting your report of this post, one of our team will look into this")
                self.view.activityStopAnimating()
            } else {
                
                self.showErrorAlert()
                self.view.activityStopAnimating()
            }
            
        })
    }
}

