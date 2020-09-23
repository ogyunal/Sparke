//
//  ProfileVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import Photos

class ProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    //IBOutlets
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var photoCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var addPostButton: UIButton!
    @IBOutlet var profileImageButton: UIButton!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var buttonHeight: NSLayoutConstraint!
    
    var posts = [Post]()
    var myProfile = true
    var imagePicker = UIImagePickerController()
    var photoUploadType: String?
    var userId = Constants.userId
    
    var following = false
    
    var followingCount: Int!
    var followerCount: Int!
    var photoCount: Int!
    
    var fromCard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.activityStartAnimating()
        navigationController?.navSetup()
        
        mainImage.roundedImage()
        mainImage.layer.borderColor = #colorLiteral(red: 0.6079999804, green: 0.6079999804, blue: 0.6079999804, alpha: 1)
        mainImage.layer.borderWidth = 1
        
        scrollView.delegate = self
        
        //Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName:"PostCell", bundle: nil), forCellWithReuseIdentifier:"cell")
        
        if myProfile {
            
            buttonHeight.constant = 0
            mainImage.image = Constants.myImage
            setupMyProfile()
            setupStackView()
            profileImageButton.isEnabled = true
            
        } else {
            
            profileImageButton.isEnabled = false
            checkFollowing()
            setupUserProfile()
            addPostButton.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPosts), name: .getPosts, object: nil)
        
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.allowsEditing = true
        
        getPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getFollowing()
        getFollowers()
        
        
    }
    
    func checkFollowing() {
        
        Constants.ref.child("users").child(Constants.userId).child("following").child(self.userId).observeSingleEvent(of: .value, with: { snapshot in
                
            if snapshot.exists() {
                    
                self.following = true
                self.setupStackView()
                    
            } else {
                
                DispatchQueue.main.async {
                    
                    self.following = false
                    self.setupStackView()
                    
                }
            }
        })
    }
    
    func setupUserProfile() {
        
        GetUserInfo().getUserInfo(self.userId) { (userInfo, success) in
            if success {
                
                self.nameLabel.text = String("\(userInfo.firstName) \(userInfo.lastName)")
                self.getUserImage(imageUrl: userInfo.imageUrl)
            } else {
                
                self.nameLabel.text = ""
                self.titleLabel.text = ""
                
            }
        }
    }
    
   func getUserImage(imageUrl: String) {
        
        guard imageUrl != "" else {
            self.mainImage.image = UIImage(named: "Logo")
            self.view.activityStopAnimating()
            return
        }
        
        mainImage.loadImageUsingCacheUrlString(urlString: imageUrl, scale: .scaleAspectFill, completion: {(result) -> () in
        
            DispatchQueue.main.async {
            
                if result {
                
                    self.view.activityStopAnimating()
                    
                } else {
                    
                    self.mainImage.image = UIImage(named: "Logo")
                    self.view.activityStopAnimating()
                }
            
            }
        })
    }
    
    func setupMyProfile() {
        
        nameLabel.text = String("\(Constants.fName) \(Constants.lName)")
        
    }
    
    func refreshCount(type: String, count: Int) {
        
        switch type {
        case "photo":
            self.photoCountLabel.text =  String(count)
        case "following":
            self.followingCountLabel.text =  String(count)
        default:
            self.followerCountLabel.text =  String(count)
        }
    }
    
     func getFollowing() {
            
        Constants.ref.child("users").child(self.userId).child("following").observeSingleEvent(of: .value, with: { snapshot in
                
            if ( snapshot.value is NSNull ) {
                    
                self.refreshCount(type: "following", count: 0)
                self.followingCount = 0
                
            } else {
                
                DispatchQueue.main.async {
                    
                    let count = Int(snapshot.childrenCount)
                    self.refreshCount(type: "following", count: count)
                    self.followingCount = count
                }
            }
        })
    }
    
    func getFollowers() {
            
        Constants.ref.child("users").child(self.userId).child("followers").observeSingleEvent(of: .value, with: { snapshot in
                
            if ( snapshot.value is NSNull ) {
                    
                self.refreshCount(type: "followers", count: 0)
                self.followerCount = 0
                
            } else {
                
                DispatchQueue.main.async {
                    
                    let count = Int(snapshot.childrenCount)
                    self.refreshCount(type: "followers", count: count)
                    self.followerCount = count
                }
            }
        })
    }
    
    func adjustCollecHeight() {
        
        let height = self.collectionView.contentSize.height + (self.headerView.frame.size.height * 1.5)
        self.collectionViewHeight.constant = height
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width,  height: height)
        self.view.layoutIfNeeded()
    }
    
    func setupStackView() {
        
        guard myProfile == false else {
            return
        }
        
        var buttonTitles = [String]()
        
        if following {
                
            buttonTitles = ["Unfollow"]
                
        } else {
                
            buttonTitles = ["Follow"]
        }
            
        for (index,title) in buttonTitles.enumerated() {
            
            let button = UIButton()
            button.tag = index
            button.layer.cornerRadius = 15
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            
            if following {

                button.backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1607843137, blue: 0.4156862745, alpha: 1)
                button.setTitleColor(.white, for: .normal)
                
            } else {

                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
                button.layer.borderColor = #colorLiteral(red: 0.1647058824, green: 0.1607843137, blue: 0.4156862745, alpha: 1)
                button.layer.borderWidth = 1
            }
            
            stackView.addArrangedSubview(button)
            stackView.distribution = .fillEqually
            stackView.spacing = 15
        }
    }
    
    @IBAction func seeFollowers() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "follower") as! FollowerVC
        vc.userId = self.userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        
        let title = sender.titleLabel?.text
        
        switch title {
        case "Follow":
            NotificationCenter.default.post(name: .refreshFollowing, object: nil)
            followAction()
        case "Unfollow":
            NotificationCenter.default.post(name: .refreshFollowing, object: nil)
            unFollowAction()
        default :
            print("default")
        }
    }
    
    func unFollowAction() {
        
        self.view.activityStartAnimating()
        
        Constants.ref.child("users").child(self.userId).child("followers").child(Constants.userId).removeValue()
        
        Constants.ref.child("users").child(Constants.userId).child("following").child(self.userId).removeValue(completionBlock: {(error,ref) in
            
            if error == nil {
                
                DispatchQueue.main.async {
                
                    self.following = false
                
                    self.stackView.subviews.forEach({ $0.removeFromSuperview() })
                
                    self.setupStackView()
                    self.view.activityStopAnimating()
                    
                    let count = self.followerCount - 1
                    self.followerCount -= 1
                    self.refreshCount(type: "followers", count: count)
                }
                
            } else {
                
                self.following = true
                self.stackView.subviews.forEach({ $0.removeFromSuperview() })
                self.setupStackView()
                self.view.activityStopAnimating()
                self.showCustomAlert(title: "", message: "Error: \(error!)")
                
            }
        })
    }
    
    func followAction() {
        
        self.view.activityStartAnimating()
        
        Constants.ref.child("users").child(self.userId).child("followers").updateChildValues([Constants.userId : true])
        
        Constants.ref.child("users").child(Constants.userId).child("following").updateChildValues([self.userId : true],withCompletionBlock: {(error,ref) in
            
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    self.following = true
                    self.stackView.subviews.forEach({ $0.removeFromSuperview() })
                    
                    self.setupStackView()
                    self.view.activityStopAnimating()
                    
                    let count = self.followerCount + 1
                    self.followerCount += 1
                    print("increment")
                    self.refreshCount(type: "followers", count: count)
                    
                }
                
            } else {
                
                self.following = false
                self.stackView.subviews.forEach({ $0.removeFromSuperview() })
                self.setupStackView()
                self.view.activityStopAnimating()
                self.showCustomAlert(title: "", message: "Error: \(error!)")
            }
        })
    }
    
    @objc func getPosts() {
        
        GetMyPosts().getMyPosts(self.userId) { (posts, success) in
            if success {
                self.posts.removeAll()
                self.posts = posts
                self.collectionView.reloadData()
                self.refreshCount(type: "photo", count: posts.count)
                self.photoCount = posts.count
            } else {
                self.refreshCount(type: "photo", count: 0)
                self.photoCount = 0
                self.view.activityStopAnimating()
                self.collectionView.reloadData()
            
            }
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
               
        return posts.count
    }
           
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostCell
        configureCell(cell: cell, index: indexPath)
        
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
           
    func configureCell(cell: PostCell, index: IndexPath) {
              
        let post = posts[index.row]
            
        cell.contentView.layer.cornerRadius = 15
        cell.dropShadow()
        cell.likeCount.text = String(post.likeCount)
        cell.commentCount.text = String(post.commentCount)
        
        cell.imageView.loadImageUsingCacheUrlString(urlString: post.thumbnailUrl, scale: .scaleAspectFill, completion: {(result) -> () in
                
            DispatchQueue.main.async {
                    
                if result == true {
                    
                    self.adjustCollecHeight()
                    self.view.activityStopAnimating()
                    
                } else {
                    self.adjustCollecHeight()
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
                  
            if myProfile {
                
                vc.myPost = true
                vc.userId = Constants.userId
                
            } else {
                
                vc.myPost = false
                vc.userId = post.userId
                
            }
                vc.post = post
                vc.fromProfile = true
                vc.mainImage = cell.imageView.image
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    
    @IBAction func settingsAction() {
        
        self.oneActionSheet("Logout") { (result) in
            
            if result {
                
                self.logout()
                
            }
        }
    }
    
    func logout() {
        
         let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
               
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                   
                try! Auth.auth().signOut()
                self.clearConstants()
                
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let navController = UINavigationController.init(rootViewController: sb.instantiateViewController(withIdentifier: "onboard"))
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: {})
                   
            }))
               
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
               
            self.present(alert, animated: true, completion: nil)
        
    }
    
    func clearConstants() {
        
        Constants.myImage = nil
        
    }
    
    @IBAction func profilePhoto() {
        
        photoAction()
        photoUploadType = "profile"
        
    }
    
    @IBAction func postAction() {
        
        photoAction()
        photoUploadType = "post"
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
       
    func testPhotoAccess() {
              
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized:
                print("Auth")
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
                   
                self.showCustomAlert(title: "Error", message: "Your camera or library is not available")
               
            }
        }
    }
          
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
       
        dismiss(animated: true, completion: nil)
       
    }
    
}

extension ProfileVC: UIImagePickerControllerDelegate {
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage

        if photoUploadType == "profile" {
            
            self.mainImage.image = image
            Constants.myImage = image
            uploadImage(image: image!, type: "profile")
            
        } else {
            
            uploadImage(image: image!, type: "post")
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    
        
    }
    
    func uploadImage(image: UIImage, type: String) {

        self.view.activityStartAnimating()
        
        guard let imageData: Data = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        var storageRef = Storage.storage().reference()
        
        if type == "post" {

            storageRef = Storage.storage().reference(withPath: "postImages/\(self.userId)/")
            
        } else {

            storageRef = Storage.storage().reference(withPath: "profileImages/\(self.userId)")
            
        }
        
        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    
                    let createdAt = Date().timeIntervalSince1970
                    let postId = Constants.ref.child("posts").childByAutoId().key
                    
                    var json: [String: Any]
                    var dbRef = Database.database().reference()
                    
                    if type == "profile" {
                        
                        dbRef = Constants.ref.child("users").child(self.userId)
                        
                        json = [
                            "imageUrl" : url!.absoluteString
                        ]
                    
                    } else {
                        
                        dbRef = Constants.ref.child("posts").child(postId!)
                     
                        json = [
                            "thumbnail_url" : url!.absoluteString,
                            "image_url" : url!.absoluteString,
                            "timestamp" : createdAt,
                            "userId" : self.userId
                        ]
                    }
                    
                    
                dbRef.updateChildValues(json) { (error, ref) in
                    
                    if error != nil {
                        
                        self.view.activityStopAnimating()
                        self.showErrorAlert()
                        
                    } else {
                        
                        self.view.activityStopAnimating()
                        
                        var string = ""
                        
                        if type == "profile" {
                            
                            string = "profile photo"
                            
                        } else {
                            
                            string = "post"
                            let count = self.photoCount + 1
                            self.photoCount += 1
                            self.refreshCount(type: "photo", count: count)
                            self.getPosts()
                        }
                        
                        NotificationCenter.default.post(name: .getPosts, object: nil)
                        self.showCustomAlert(title: "Success", message: ("Your \(string) has been uploaded"))
                        
                    }
                }
            }
        }
    }
}
}


