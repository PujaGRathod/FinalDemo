//
//  OfficeProfileImageAdapter.swift
//  remone
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol OfficeProfileImageAdapterDelegate {
    func updateIndexTitle(_ title: String)
}

class OfficeProfileImageAdapter: NSObject {

    private let colImages: UICollectionView
    let delegate: OfficeProfileImageAdapterDelegate
    private let images: [URL]

    init(with collectionView: UICollectionView, delegate: OfficeProfileImageAdapterDelegate, with images: [URL]) {
        self.colImages = collectionView
        self.delegate = delegate
        self.images = images
        super.init()
        self.setupCollectionView()
    }

    func setupCollectionView() {
        self.colImages.delegate = self
        self.colImages.dataSource = self
        self.colImages.register(UINib.init(nibName: "OfficeProfileImageClnCell", bundle: nil), forCellWithReuseIdentifier: "OfficeProfileImageClnCell")
        self.colImages.reloadData()
        if self.images.count == 0 {
            self.delegate.updateIndexTitle(" 0 ")
        } else {
            self.delegate.updateIndexTitle("\(1) / \(self.colImages.numberOfItems(inSection: 0))")
        }

    }

}

extension OfficeProfileImageAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfficeProfileImageClnCell",
                                                         for: indexPath) as? OfficeProfileImageClnCell {
            let imageURL = self.images[indexPath.row]
            cell.imageViewOfficeProfile.sd_setImage(with: imageURL, completed: { (image, _, _, _) in
                cell.imageViewOfficeProfile.image = image
            })
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        var height = collectionView.frame.height
        height -= 2
        return CGSize.init(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        var visibleRect = CGRect()
        visibleRect.origin = self.colImages.contentOffset
        visibleRect.size = self.colImages.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = self.colImages.indexPathForItem(at: visiblePoint) {
            self.delegate.updateIndexTitle("\(indexPath.item + 1) \\ \(self.colImages.numberOfItems(inSection: 0))")
        }
    }

}
