//
//  ViewController.swift
//  SampleFeed
//
//  Created by Prasad on 16/05/19.
//  Copyright © 2019 Prasad. All rights reserved.
//

import UIKit
import PCDownloader


class ViewController: UIViewController {
    
     var collectionViewCtrl:InfinityCollectionViewController?
    
    var flowLayout: Layout! = Layout()

    
    private var pcDownloader = PCDownloader(cacheTime: 24, memorySpace: 250)
    
    private var model:Model!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.model = Model(downloader: self.pcDownloader)
        
        self.collectionViewCtrl?.modelDelegate = self;
        
        self.flowLayout.delegate = self;
        
        self.collectionViewCtrl?.collectionView.collectionViewLayout = flowLayout;

       model.makeApiCall { (data, state) in
            if(state == true){
                DispatchQueue.main.async
                {
                        self.loadCells(items: self.model.items! as! [Item]);
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "embeded-collection"
        {
            self.collectionViewCtrl = segue.destination as? InfinityCollectionViewController
        }
    }
    
    
    
    func loadCells(items:[Item]) -> Void {
        
        DispatchQueue.main.async
        {
            self.collectionViewCtrl?.insertNewCells(count:items.count)
        }
        
    }
    
    func cellSize(indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 120, height: 300)
    }
}


extension ViewController:InfinityCollectionViewDelegate
{
    func cellForItem(indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PCollectionCell
        
        let item = model.items?[indexPath.row]
        
        guard let url = item?.urls.regular else { return cell }
        
        let bgColor = UIColor(hex: (item?.color)!) ?? UIColor.clear
        
        cell.configureCell(URL(string: url)!,state:item!.enableDownloading, backgroundColor: bgColor, imageAccess: pcDownloader)
        
        return cell
    }
    
    func loadToDatasource( collectionView: UICollectionView) {
        
        // delegate to add data to the queue
        // block unnecessary , implemented since the datasource was static
        guard let items = model.items else { return }
        
        if items.count != 0 {
            
            let counter1 = Int.random(in: 0 ..< 10)
            
            var counter2 = 10
            
            repeat
            {
              counter2 = Int.random(in: 0 ..< 10)
            }
            while(counter2 < counter1);
            
            let slice = items[counter1...counter2]
            
            let newArray = Array(slice)
            
            for var item in newArray
            {
                item?.enableDownloading = true;
            }
            
            model.items?.append(contentsOf: newArray)
            
            self.loadCells(items: newArray as! [Item])
        
        }
        else
        {
            model.items?.append(contentsOf: items)
            self.loadCells(items: items as! [Item])
        }
        
        
    }
    
    func didTapCell(indexPath: IndexPath, collectionView: UICollectionView)
    {
        // block to stop/ redownload asset - by taping the item
        let cell = collectionView.cellForItem(at: indexPath) as! PCollectionCell
        
        var item = model.items?[indexPath.row]
        
        if item?.enableDownloading == true
        {
            cell.stopDownloading()
            item?.enableDownloading = false;
        }
        else
        {
            item?.enableDownloading = true;
            collectionView.reloadItems(at: [indexPath]);
        }
    }
    
    func refreshData()
    {
        model.makeApiCall { (data, state) in
            if  (state == true)
            {
                DispatchQueue.main.async
                {
                    self.flowLayout = nil
                
                    self.flowLayout = Layout()
                    
                    self.flowLayout.delegate = self
                    
                    self.collectionViewCtrl?.reloadDataWithInputs(count:self.model.items?.count ?? 0, layout:self.flowLayout)
                }
            }
        }
        
    }
    
}

extension ViewController: LayoutDelegate
{
    func collectionView(_ collectionView: UICollectionView, cellWidth: CGFloat, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let item = model.items?[indexPath.item]
        
        let originalSize = CGSize(width: item?.width ?? 0, height: item?.height ?? 0)
        
        return estimateHeightForImageRatio(originalSize: originalSize, width: cellWidth)
    }
    
    func estimateHeightForImageRatio(originalSize:CGSize, width:CGFloat) ->CGFloat
    {
        return (width * originalSize.height / originalSize.width)
        
    }
    
}
