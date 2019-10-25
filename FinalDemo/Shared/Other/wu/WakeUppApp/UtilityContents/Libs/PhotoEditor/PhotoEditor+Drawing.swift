//
//  PhotoEditor+Drawing.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

extension PhotoEditorViewController {
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if isDrawing {
            swiped = false
            if let touch = touches.first {
                //lastPoint = touch.location(in: self.canvasImageView)
                
                //PV
                let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                lastPoint = touch.location(in: cell.canvasImageView)
            }
        }
            //Hide stickersVC if clicked outside it
        else if stickersVCIsVisible == true {
            if let touch = touches.first {
                let location = touch.location(in: self.view)
                if !stickersViewController.view.frame.contains(location) {
                    removeStickersView()
                }
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawing {
            // 6
            swiped = true
            if let touch = touches.first {
                //let currentPoint = touch.location(in: canvasImageView)
                //drawLineFrom(lastPoint, toPoint: currentPoint)
                
                //PV
                let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                let currentPoint = touch.location(in: cell.canvasImageView)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                
                // 7
                lastPoint = currentPoint
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        if isDrawing {
            if !swiped {
                // draw a single point
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        /*
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        // 1
        UIGraphicsBeginImageContext(canvasImageView.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasImageView.frame.size.width, height: canvasImageView.frame.size.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            if isErasing {
                context.setBlendMode(.clear)
                context.setLineWidth(8-.0)
                self.btneraser.backgroundColor = themeWakeUppColor
            } else {
                context.setBlendMode(CGBlendMode.normal)
                context.setLineWidth(currentBrushSize)
                self.btneraser.backgroundColor = UIColor.clear
            }
            context.setLineCap( CGLineCap.round)
            context.setStrokeColor(drawColor.cgColor)
            context.setAlpha(currentColorOpacity)
            
            // 4
            context.strokePath()
            // 5
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }*/
        
        //-----> Suggested. Info
        /*
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        
        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext((cell.canvasImageView.frame.size))
        
        // Draw the starting image in the current context as background
        cell.canvasImageView.image?.draw(at: CGPoint.zero)
        
        // Get the current context
        //let context = UIGraphicsGetCurrentContext()!
        if let context = UIGraphicsGetCurrentContext() {
        context.setLineWidth(currentBrushSize)
        context.setStrokeColor(drawColor.cgColor)
        context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        if isErasing {
            context.setBlendMode(.clear)
            context.setLineWidth(8 - 0.0) //PV
            self.btneraser.backgroundColor = themeWakeUppColor //PV
        } else {
            context.setStrokeColor(drawColor.cgColor)
            context.setAlpha(currentColorOpacity)
            context.setBlendMode(CGBlendMode.normal)
        }
        context.strokePath()
        
        // Draw a transparent green Circle
        context.setStrokeColor(drawColor.cgColor)
        context.setAlpha(currentColorOpacity)
        context.setLineWidth(currentBrushSize)
        
        context.drawPath(using: .stroke) // or .fillStroke if need filling
        
        cell.canvasImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Save the context as a new UIImage
        }*/
        
        //PV
        //------------------------>
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        // 1
        UIGraphicsBeginImageContext(cell.canvasImageView.frame.size)
        
        cell.canvasImageView.image?.draw(at: CGPoint.zero)
        
        if let context = UIGraphicsGetCurrentContext() {
        //let context = UIGraphicsGetCurrentContext()!
            //canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: cell.canvasImageView.frame.size.width, height: cell.canvasImageView.frame.size.height))
            
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            if isErasing {
                context.setBlendMode(.clear)
                
                context.setLineWidth(8 - 0.0)
                //self.btneraser.backgroundColor = themeWakeUppColor
            } else {
                context.setBlendMode(CGBlendMode.normal)
                context.setLineWidth(currentBrushSize)
                self.btneraser.backgroundColor = UIColor.clear
                
                context.setStrokeColor(drawColor.cgColor)
                context.setAlpha(currentColorOpacity)
                context.setBlendMode(CGBlendMode.normal)
            }
            // 4
            context.strokePath()
            
            // Draw a transparent green Circle
            context.setLineCap( CGLineCap.round)
            context.setStrokeColor(drawColor.cgColor)
            context.setAlpha(currentColorOpacity)
            context.setLineWidth(currentBrushSize)
            
            context.drawPath(using: .stroke) // or .fillStroke if need filling
            
            // 5
            cell.canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        //------------------------>
    }
}

class ScaledHeightImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        return CGSize(width: -1.0, height: -1.0)
    }
}

