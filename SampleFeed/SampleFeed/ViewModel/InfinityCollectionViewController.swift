//
//  InfinityCollectionViewController.swift
//  SampleFeed
//
//  Created by Prasad on 16/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import UIKit
import PCDownloader

private let reuseIdentifier = "cell"

protocol InfinityCollectionViewDelegate
{
    func cellForItem(indexPath:IndexPath, collectionView:UICollectionView) -> UICollectionViewCell
    
    func loadToDatasource(collectionView:UICollectionView) -> Void
    
    func didTapCell(indexPath:IndexPath, collectionView:UICollectionView) -> Void
    
    func refreshData()

}


class PCollectionCell: UICollectionViewCell
{
    @IBOutlet var imageView:UIImageView?
    
    fileprivate var imageBackgroundColor: UIColor?
    
    fileprivate var stopDownloader:CancelImageLoading?
    
    var prepareForReuseBlock: (() -> Void)?
    
    func configureCell(_ url: URL, state:Bool ,backgroundColor:UIColor, imageAccess: PCDownloader)
    {
        
        imageBackgroundColor = backgroundColor
        
        self.imageView?.backgroundColor = imageBackgroundColor
        
        if state == true
        {
            let stopImageLoading = imageAccess.imageWithURL(url) { [weak self] (image) in
                
                    UIView.animate(withDuration: 1.0, animations: {
                        
                        self?.imageView?.backgroundColor = UIColor.clear
                        
                        self?.imageView?.image = (image != nil) ? image : UIImage(named: "ImageNotFound")
                        
                    });
            }
            
            self.stopDownloader = stopImageLoading
            
            prepareForReuseBlock = { [weak self] in
                
                self?.imageView?.backgroundColor = self?.imageBackgroundColor
                
                self?.imageView?.image = nil
                
                stopImageLoading()
            }
        }

    }
    
     func stopDownloading()
    {
        self.stopDownloader?()
    }
    
    func configureCell(_ image:UIImage!)
    {
        self.imageView?.image = nil;
        self.imageView?.image = image;
    }
    
}

class InfinityCollectionView: UICollectionView
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        if (!__CGSizeEqualToSize(bounds.size,self.intrinsicContentSize)){
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize
    {
        return contentSize
    }

}

class InfinityCollectionViewController: UICollectionViewController
{

    fileprivate var preloadOffSet:Int = 1
    
    fileprivate var itemsCount:Int = 0
    
    private let refreshControl = UIRefreshControl()
    
    public var modelDelegate: InfinityCollectionViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addTarget(self, action: #selector(forceRefresh), for: .valueChanged)
        
        self.refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)]
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: attributes)
        
        if #available(iOS 10.0, *) {
            self.collectionView?.refreshControl = refreshControl
        } else {
            self.collectionView?.addSubview(refreshControl)
        }
        
    }
    
    @objc public func forceRefresh()
    {
        self.modelDelegate?.refreshData()
    }
    
    public func reloadDataWithInputs(count:Int, layout:UICollectionViewLayout)
    {
        self.refreshControl.endRefreshing()
        
        itemsCount = count
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        self.collectionView.collectionViewLayout = layout;
        
        self.collectionView.reloadData()

        
    }
    
    public func insertNewCells(count:Int)
    {
        self.refreshControl.endRefreshing()
        
        var currentCount = self.collectionView.numberOfItems(inSection: 0);

        if  (currentCount > itemsCount + count)
        {
            currentCount = 0;
        }
        self.collectionView?.performBatchUpdates({
            
            itemsCount += count
            
            var newIndexPaths:[IndexPath] = []
            
            for index in currentCount..<itemsCount
            {
                newIndexPaths.append(IndexPath(item: index, section: 0))
            }
            
            self.collectionView?.insertItems(at: newIndexPaths)
            
        }, completion: nil)
    }

    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.itemsCount
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return modelDelegate?.cellForItem(indexPath: indexPath, collectionView: collectionView) ?? UICollectionViewCell()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.modelDelegate?.didTapCell(indexPath: indexPath, collectionView: collectionView);
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let scrollViewHeight = self.collectionView.frame.size.height
        
        let scrollContentSizeHeight = self.collectionView.contentSize.height
        
        let scrollOffset = self.collectionView.contentOffset.y
        
        if (scrollOffset >= (scrollContentSizeHeight - scrollViewHeight)) {
            //reach bottom
            self.modelDelegate?.loadToDatasource(collectionView: self.collectionView)
            
        }
        
    }
}

