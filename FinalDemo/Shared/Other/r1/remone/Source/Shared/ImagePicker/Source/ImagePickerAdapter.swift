//
//  ImagePickerAdapter.swift
//  ImagePicker
//
//  Created by Arjav Lad on 23/12/17.
//  Copyright © 2017 Arjav Lad. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import SDWebImage

struct ImageObject {
    var url: URL?
    var image: UIImage?

    init(withURL: URL) {
        self.url = withURL
        self.image = nil
    }

    init(withImage: UIImage) {
        self.url = nil
        self.image = withImage
    }
}

fileprivate let preferedImagesCount = 10

protocol ImagePickerAdapterDelegate {
    func showBackgraoundView(show: Bool)
}

class ImagePickerAdapter: NSObject, ImageOptionsViewDelegate {

    private let viewController: UIViewController
    private let collectionView: UICollectionView
    var backgroundView: UIView?
    private var images: [ImageObject] = [ImageObject]() {
        didSet {
            if self.images.count == 0 {
                self.backgroundView?.isHidden = false
            } else {
                self.backgroundView?.isHidden = true
            }
            //            self.collectionView.reloadData()
        }
    }
    private var remainingImages: Int {
        get {
            let remaining = preferedImagesCount - self.images.count
            if remaining > 0 {
                return remaining
            }
            return 0

        }
    }

    var allImages: [UIImage] {
        var tmp = [UIImage]()
        for image in self.images {
            if let img = image.image {
                tmp.append(img)
            }
        }
        return tmp
    }

    init(with vc: UIViewController, col: UICollectionView, backgroundView: UIView? = nil, images: [ImageObject]? = nil) {
        self.viewController = vc
        self.collectionView = col
        self.backgroundView = backgroundView
        if let images = images {
            self.images = images
        } else {
            self.images = []
        }
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib.init(nibName: "ImageClnViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageClnViewCell")
        self.backgroundView?.isHidden = false
        self.reloadImages()
    }

    private func showAddImageAlert() {
        let alert = UIAlertController.init(title: "Add Images".localized,
                                           message: "Please upload 10 photos.".localized,
                                           preferredStyle: .actionSheet)
//        if self.remainingImages == 0 {
//            alert.addAction(UIAlertAction.init(title: "Instagram".localized,
//                                               style: .default,
//                                               handler: { (action) in
//                                                self.chooseInstagram()
//            }))
//
//            alert.addAction(UIAlertAction.init(title: "Facebook".localized,
//                                               style: .default,
//                                               handler: { (action) in
//                                                self.choosefacebook()
//            }))
//        }

        alert.addAction(UIAlertAction.init(title: "Device photo library".localized,
                                           style: .default,
                                           handler: { (action) in
                                            self.chooseDevicePhotoLibrary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: { (action) in
        }))

        self.viewController.present(alert, animated: true, completion: nil)
    }

    private func showImages(_ images: [ImageObject], with error: Error?, replace: Bool = true, index: Int? = nil) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            self.showAlert(withError: error)
        } else {
            if let index = index,
                self.images.count > index,
                images.count > 0 {
                self.images[index] = images[0]
            } else {
                if replace {
                    self.images = images
                } else {
                    self.images.append(contentsOf: images)
                }
            }
        }
        self.reloadImages()
    }

    private func reloadImages() {
        if self.images.count == 0 {
            self.backgroundView?.isHidden = false
        } else {
            self.backgroundView?.isHidden = true
        }
        self.collectionView.reloadData()
    }

    private func showImagePicker(index: Int? = nil) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch  status {
        case .authorized,
             .notDetermined:
            break
        case .denied,
             .restricted:
            self.viewController.showAlert("Access denied".localized, message: "Please allow Remone to access photo library from settings->Remone.".localized, actionTitles: [("Open Settings".localized, .default)], cancelTitle: "Cancel".localized, actionHandler: { (action, index) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (success) in

                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
                }
            }, cancelActionHandler: nil)
            return
        }

        let vc = BSImagePickerViewController()
        if let _ = index {
            vc.maxNumberOfSelections = 1
        } else {
            vc.maxNumberOfSelections = self.remainingImages
        }
        vc.takePhotos = false
        self.viewController.bs_presentImagePickerController(vc, animated: true,
                                                            select: { (asset: PHAsset) -> Void in
                                                                // User selected an asset.
                                                                // Do something with it, start upload perhaps?
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselect")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel")
        }, finish: { (assets: [PHAsset]) -> Void in
            print("Finished")
            let imgs = self.getImages(from: assets)
            DispatchQueue.main.async {
                self.viewController.showLoader()
                self.showImages(imgs, with: nil, replace: false, index: index)
                self.viewController.hideLoader()
            }
        }, completion: {
            print("complete")
        })
    }

    private func getImages(from assets: [PHAsset]) -> [ImageObject] {
        var images = [ImageObject]()
        for asset in assets {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.version = .original
            options.isSynchronous = true
            manager.requestImageData(for: asset, options: options) { data, _, _, _ in
                if let data = data {
                    if let img = UIImage(data: data) {
                        let image = ImageObject.init(withImage: img)
                        images.append(image)
                    }
                }
            }
        }
        return images
    }

    private func showAlert(withError error: Error) {
        let alert = UIAlertController.init(title: "Error".localized,
                                           message: error.localizedDescription,
                                           preferredStyle: .alert)

        alert.addAction(UIAlertAction.init(title: "ok".localized,
                                           style: .default,
                                           handler: { (action) in

        }))

        self.viewController.present(alert, animated: true, completion: nil)
    }

    private func updateImage(_ image: UIImage, index: IndexPath) {
        if self.images.count > index.item {
            var imageObj = self.images[index.item]
            imageObj.image = image
            self.images[index.item] = imageObj
        }
    }

    func choosefacebook() {
        FBImageFetcher.shared.login(from: self.viewController, limit: self.remainingImages) { (error, loadedImages) in
            self.showImages(loadedImages, with: error)
        }
    }

    func chooseInstagram() {
        InstagramVC.loadImages(on: self.viewController, limit: self.remainingImages, completion: { (error, loadedImages) in
            self.showImages(loadedImages, with: error, replace: true)
        })
    }

    func chooseDevicePhotoLibrary() {
        self.showImagePicker()
    }

    @objc func onHeadertap(_ sender: UIButton) {
        self.showAddImageAlert()
    }

    func showImageChangeAlert(for index: Int) {
        var actualIndex = index
        if self.remainingImages > 0 {
            actualIndex = index - 1
            if actualIndex == -1 {
                actualIndex = index
            }
        } else {
            actualIndex = index
        }

        let alert = UIAlertController.init(title: "Choose option".localized,
                                           message: "",
                                           preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction.init(title: "replace".localized,
                                           style: .default,
                                           handler: { (action) in
                                            self.showImagePicker(index: actualIndex)
        }))

        alert.addAction(UIAlertAction.init(title: "delete".localized,
                                           style: .destructive,
                                           handler: { (action) in
                                            self.images.remove(at: actualIndex)
                                            self.reloadImages()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: { (action) in
        }))
        self.viewController.present(alert, animated: true, completion: nil)
    }

}

extension ImagePickerAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.images.count == preferedImagesCount {
            return self.images.count
        } else {
            return self.images.count + 1
        }
        //        if section == 0 {
        //            return self.images.count
        //        } else {
        //            if self.remainingImages == 0 ||
        //                self.remainingImages == preferedImagesCount {
        //                return 0
        //            } else {
        //                return 1
        //            }
        //        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageClnViewCell", for: indexPath) as! ImageClnViewCell
        cell.imgViewPhoto.layer.cornerRadius = 12
        cell.imgViewPhoto.clipsToBounds = true
        if self.images.count < preferedImagesCount &&
            indexPath.item ==  0 {
            let headertext = "Please upload more images to complete your profiling".localized
            cell.lblText.text = headertext + ": \(self.self.remainingImages)"
            cell.lblText.numberOfLines = 0
            cell.imgViewPhoto.image = nil
            cell.imgViewPhoto.layer.borderWidth = 0.5
            cell.imgViewAdd.isHidden = false
            cell.lblText.isHidden = false
            cell.imgViewPhoto.layer.borderColor = UIColor.black.cgColor
        } else {
            var index: Int = 0
            cell.lblText.isHidden = true
            cell.imgViewPhoto.layer.borderWidth = 0.5
            cell.imgViewPhoto.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.3472161092)
            cell.imgViewAdd.isHidden = true
            if self.images.count < preferedImagesCount {
                index = indexPath.item - 1
            } else {
                index = indexPath.item
            }
            let photo = self.images[index]
            cell.imgViewPhoto.contentMode = .scaleAspectFill
            cell.imgViewPhoto.sd_cancelCurrentImageLoad()
            cell.imgViewPhoto.image = nil
            cell.lblText.text = ""
            if let url = photo.url {
                cell.imgViewPhoto.sd_setImage(with: url,
                                              placeholderImage: nil,
                                              options: [.allowInvalidSSLCertificates, .continueInBackground, .highPriority, .refreshCached, .retryFailed],
                                              completed: { (image, error, cache, ur) in
                                                if let image = image {
                                                    cell.imgViewPhoto.image = image
                                                    DispatchQueue.main.async {
                                                        self.updateImage(image, index: indexPath)
                                                    }
                                                } else {
                                                    if let error = error {
                                                        print("Error downloading image: \(error.localizedDescription)")
                                                    }
                                                    self.updateImage(#imageLiteral(resourceName: "iconBrokenImage"), index: indexPath)
                                                    cell.imgViewPhoto.image = #imageLiteral(resourceName: "iconBrokenImage")
                                                }
                })
            } else {
                cell.imgViewPhoto.image = photo.image
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.images.count < preferedImagesCount &&
            indexPath.item ==  0 {
            self.showAddImageAlert()
        } else {
            self.showImageChangeAlert(for: indexPath.item)
        }
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize.init(width: collectionView.frame.width - 2, height: 45)
//    }
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
//        let headertext = "Click here to add remaining images".localized
//        let button = UIButton.init(type: .system)
//        button.tintColor = APP_COLOR_THEME
//        button.setTitle( headertext + ": \(self.remainingImages)", for: .normal)
//        button.addTarget(self, action: #selector(self.onHeadertap(_:)), for: .touchUpInside)
//        header.addSubview(button)
//        header.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": button]))
//        header.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": button]))
//        header.layoutIfNeeded()
//        return header
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnWidth = (collectionView.frame.width - 60) / 2
        return CGSize.init(width: columnWidth, height: columnWidth / 1.33)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 20, 10, 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

}
