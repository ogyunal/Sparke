//
//  HomeVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import Photos


class HomeVC: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyLabel: UILabel!
    @IBOutlet var publicButton: UIButton!
    @IBOutlet var followingButton: UIButton!
    
    //MARK: Variables
    var posts = [Post]()
    var selectedIndex = 0
    var imagePicker = UIImagePickerController()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.activityStartAnimating()
        
        publicButton.tag = 0
        followingButton.tag = 1
        
        navigationController?.navSetup()
        				
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.allowsEditing = true
        
        //Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName:"PostCell", bundle: nil), forCellWithReuseIdentifier:"cell")
        
        //Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        //Notification Center
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPosts), name: .getPosts, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: .scrollToTop, object: nil)
        
        getMyDetails()
        getPublicPosts()
        
        Constants.imageCache.removeAllObjects()
        
    }
    
    func getMyDetails() {
        
        GetUserInfo().getUserInfo(Constants.userId) { (userInfo, success) in
            if success {
                
                Constants.fName = userInfo.firstName
                Constants.lName = userInfo.lastName
                self.getProfileImage(imageUrl: userInfo.imageUrl)
            }
        }
    }
    
    func getProfileImage(imageUrl: String) {
        
        getStorageImage(imageUrl: imageUrl) {(image,success) in
            
            if success {
                
                Constants.myImage = image
            }
        }
    }
    
    //MARK: @objc Functions
    @objc func refreshPosts() {
        
        if selectedIndex == 0 {
            
            getPublicPosts()
            
        } else {
            
            getFollowingPosts()
        }
    }
    
    @objc func scrollToTop() {
        
        let indexPath = IndexPath(item: 0, section: 0)
    
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        
    }

    func getPublicPosts() {
        
        GetPublicPosts().getPublicPosts() { (posts, success) in
            if success {

                self.posts.removeAll()
                self.posts = posts
                self.emptyLabel.alpha = 0
                self.reloadCollectionView()
                
            } else {

                self.view.activityStopAnimating()
                self.reloadCollectionView()
                self.emptyLabel.alpha = 1
                self.emptyLabel.text = "No posts to display, check back later"
                
            }
        }
    }
    
    func getFollowingPosts() {
        
        GetFollowingPosts().getFollowingPosts() { (posts, success) in
            if success {
                self.posts.removeAll()
                self.posts = posts
                self.emptyLabel.alpha = 0
                self.reloadCollectionView()
            } else {
                self.view.activityStopAnimating()
                self.reloadCollectionView()
                self.emptyLabel.alpha = 1
                self.emptyLabel.text = "No posts to display, check back later"
                
            }
        }
    }
    
    func reloadCollectionView() {
        
        collectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        
            self.refreshControl.endRefreshing()
            
        }
    }
    
    func photoAction() {
           
           self.photoActionSheet {(mediaType) in
                      
               if mediaType == "camera" {
                          
                   self.testCameraAccess()
                          
               } else {
                          
                   self.testPhotoAccess()
                          
               }
           }
       }
    
    @IBAction func postAction() {
        
       photoAction()
        
    }
    
    func testPhotoAccess() {
           
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized:
                self.openCamera(UIImagePickerController.SourceType.photoLibrary)
            case .denied, .restricted :
                print("denied")
            case .notDetermined:
                // ask for permissions
            
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
                case .authorized:
                    self.openCamera(UIImagePickerController.SourceType.photoLibrary)
                case .denied, .restricted:
                    print("denied")
                case .notDetermined:
                    print("not determined")
                @unknown default:
                    print("default")
                }
            }
            @unknown default:
                print("default")
           }
       }
    
    func testCameraAccess() {
           
           if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
               
               self.openCamera(UIImagePickerController.SourceType.camera)
               
           } else {
               AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                   if granted {
                       
                       self.openCamera(UIImagePickerController.SourceType.camera)
                       
                   } else {
                       
                       //do nothing
                   }
               })
           }
       }
    
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
           
           DispatchQueue.main.async {
               
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                
                self.imagePicker.sourceType = sourceType
                self.present(self.imagePicker, animated: true, completion: nil)
                
            } else {
                
                self.showCustomAlert(title: "Error", message: "Your camera is not available")
            }
                
           }
       }
       
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentaction(_ sender: UIButton) {
        
        guard selectedIndex != sender.tag else {
            print("same segment selected")
            return
        }
        
        self.view.activityStartAnimating()
        
        if sender.tag == 0 {
            //Public
            selectedIndex = 0
            publicButton.setTitleColor(.black, for: .normal)
            followingButton.setTitleColor(#colorLiteral(red: 0.6079999804, green: 0.6079999804, blue: 0.6079999804, alpha: 1), for: .normal)
            getPublicPosts()
        } else {
            //Following
            selectedIndex = 1
            publicButton.setTitleColor(#colorLiteral(red: 0.6079999804, green: 0.6079999804, blue: 0.6079999804, alpha: 1), for: .normal)
            followingButton.setTitleColor(.black, for: .normal)
            getFollowingPosts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           
        return posts.count
    }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostCell
        configureCell(cell: cell, index: indexPath.row)
           
        return cell
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let spacing = CGFloat(flowayout!.minimumInteritemSpacing)
        let left = CGFloat((flowayout?.sectionInset.left)!)
        let right = CGFloat((flowayout?.sectionInset.right)!)
        let space: CGFloat = spacing + left + right
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        
        return CGSize(width: size, height: 180)
       
    }
       
    func configureCell(cell: PostCell, index: Int) {
          
        let post = posts[index]

        cell.contentView.layer.cornerRadius = 15
        cell.dropShadow()
        cell.likeCount.text = String(post.likeCount)    
        cell.commentCount.text = String(post.commentCount)
        
        cell.imageView.loadImageUsingCacheUrlString(urlString: post.thumbnailUrl, scale: .scaleAspectFill, completion: {(result) -> () in
            
            DispatchQueue.main.async {
            
                if result {
                    
                    self.view.activityStopAnimating()

                } else {
                    
                    self.view.activityStopAnimating()
                    
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
        let sb = UIStoryboard(name: "Main", bundle: nil)
           
        if let vc = sb.instantiateViewController(withIdentifier: "photoPost") as? PhotoPostVC {
               
            let cell = collectionView.cellForItem(at: indexPath) as! PostCell
               
            let post = posts[indexPath.row]
               
            if post.userId == Constants.userId {
                
                vc.myPost = true
                vc.userId = Constants.userId
                    
            } else {
                    
                vc.myPost = false
                vc.userId = post.userId
              
            }
            
                vc.post = post
                vc.mainImage = cell.imageView.image
                self.navigationController?.pushViewController(vc, animated: true)
           }
        }
    }

extension HomeVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        uploadImage(image: image!)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(image: UIImage) {
        
        self.view.activityStartAnimating()
        
        guard let imageData: Data = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let postId = Constants.ref.child("posts").childByAutoId().key
        
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(withPath: "postImages/\(postId!)")
        
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    
                    let createdAt = Date().timeIntervalSince1970
                    
                    let post: [String : Any] = [
                        "thumbnail_url" : url!.absoluteString,
                        "image_url" : url!.absoluteString,
                        "timestamp" : createdAt,
                        "userId" : Constants.userId,
                    ]
                    
                    self.savePost(post: post, postId: postId!)
            }
        }
    }
}
    
    func savePost(post: [String: Any], postId: String) {
        
        Constants.ref.child("posts").child(postId).updateChildValues(post) { (error, ref) in
            
            if error != nil {
                
                self.view.activityStopAnimating()
                self.showErrorAlert()
                
            } else {
                
                self.saveUserPost(post: post, postId: postId)
            }
        }
    }
    
    func saveUserPost(post: [String: Any], postId: String) {
        
        Constants.ref.child("userPosts").child(postId).updateChildValues(post) { (error, ref) in
                   
            if error != nil {
                       
                self.view.activityStopAnimating()
                self.showErrorAlert()
                       
            } else {

                self.view.activityStopAnimating()
                self.showCustomAlert(title: "Success", message: "Your post has been uploaded")
                self.refreshPosts()
            }
        }
    }
}

