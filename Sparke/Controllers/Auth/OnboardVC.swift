//
//  OnboardVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit

class OnboardVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    //MARK: - @IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    
    //MARK: - Variables
    var titles = ["Title 1", "Title 2", "Title 3", "Title 4"]
    var subTitles = ["SubTitle 1", "SubTitle 2", "SubTitle 3", "SubTitle 4"]
    var images = [UIImage(named: "Logo"),UIImage(named: "Logo"),UIImage(named: "Logo"),UIImage(named: "Logo")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName:"OnboardCell", bundle: nil), forCellWithReuseIdentifier:"cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(registered), name: .registered, object: nil)
    }
    
    @objc func registered() {
        
        self.showCustomAlert(title: "Registered", message: "You can now Sign In")
    }
    
    @IBAction func registerAction() {
        
        self.pushVC(vcString: "register", storyboard: "Auth")
    }
    
    @IBAction func loginAction() {
        
        self.pushVC(vcString: "login", storyboard: "Auth")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OnboardCell
        configureCell(cell: cell, index: indexPath)
        
        return cell
    }
    
    func configureCell(cell: OnboardCell, index: IndexPath) {
       
        cell.titleLabel.text = titles[index.row]
        cell.subtitleLabel.text = subTitles[index.row]
        cell.imageView.image = images[index.row]
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = collectionView.bounds.width
        let itemHeight = collectionView.bounds.height
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func centerCell () {
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.frame.midX, y: 100)
        if let path = collectionView.indexPathForItem(at: centerPoint) {
            collectionView.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
            
            self.pageControl.currentPage = path.row
        }
    }

    //Set collectionView.delegate = self then add below funcs
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       centerCell()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        centerCell()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCell()
        }
    }
}

