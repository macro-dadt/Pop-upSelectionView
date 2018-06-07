//
//  EmojiableButton.swift
//  BabyMap
//
//  Created by DT Dat on 2017/06/19.
//  Copyright © 2017 Trim, Inc. All rights reserved.
//

import Foundation
import UIKit
public struct EmojiableConfig{
    var spacing:CGFloat
    var size:CGFloat
    var minSize:CGFloat
    var maxSize:CGFloat
    var s_options_selector:CGFloat
    
    public init(spacing:CGFloat,size:CGFloat,minSize:CGFloat,maxSize:CGFloat,s_options_selector:CGFloat){
        self.spacing            = spacing
        self.size               = size
        self.minSize            = minSize
        self.maxSize            = maxSize
        self.s_options_selector = s_options_selector
    }
}
/**
 *  TODO: use name value to create Option's labels
 */
public struct EmojiableOption{
    var image:String
    var name:String
    
    public init(image:String,name:String){
        self.image = image
        self.name  = name
    }
}

public protocol EmojiableDelegate{
    func selectedOption(sender:EmojiableView,index:Int)
    func singleTap(sender:EmojiableView)
    func sameTimeTouches(number:Int)
    func longTap(sender:EmojiableView)
    func canceledAction(sender:EmojiableView)
    func getSlectorView() -> SelectorView
    func optionTap(index: Int)
}

public class EmojiableView: UIView {
    public var delegate:EmojiableDelegate!
    public var dataset:[EmojiableOption]!
    
    var longTap:UILongPressGestureRecognizer!
    var singleTap:UITapGestureRecognizer!
    
    var drag:UIPanGestureRecognizer!
    
    var active:Bool!
    var selectedItem:Int!
    var bgClear:SelectorView!
    var options:UIView!
    var origin:CGPoint!
    var information:InformationView!
    
    let spacing:CGFloat
    let size:CGFloat
    let minSize:CGFloat
    let maxSize:CGFloat
    let s_options_selector:CGFloat
    let frameSV = UIScreen.main.bounds
    var touchPoint:CGPoint!
    

    
    /**
     Initialization with parameters as default (Facebook reactions iOS App)
     
     - parameter frame: Frame of the button will open the selector
     
     */
    
    public override init(frame: CGRect) {
        self.spacing            = 6
        self.size               = 40
        self.minSize            = 34
        self.maxSize            = 80
        self.s_options_selector = 30
        super.init(frame: frame)
        self.initialize()
    }
    
    /**
         - parameter frame: Frame of the button will open the selector
     - parameter config: EmojiableConfig value with custom sizes
     */
    
    public init(frame: CGRect, config:EmojiableConfig){
        self.spacing            = config.spacing
        self.size               = config.size
        self.minSize            = config.minSize
        self.maxSize            = config.maxSize
        self.s_options_selector = config.s_options_selector
        super.init(frame: frame)
        self.initialize()
    }
    required public init?(coder aDecoder: NSCoder) {
        self.spacing            = 6
        self.size               = 40
        self.minSize            = 34
        self.maxSize            = 80
        self.s_options_selector = 30
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    
    private func initialize(){
        longTap = UILongPressGestureRecognizer(target: self, action: #selector(EmojiableView.longTapEvent))
        singleTap = UITapGestureRecognizer(target: self, action: #selector(EmojiableView.singleTapEvent))
        self.addGestureRecognizer(longTap)
        self.addGestureRecognizer(singleTap)
        self.layer.masksToBounds = false
        active = false
    }
    private var isLongPressMoved = false
    @objc func longTapEvent(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            isLongPressMoved = false
        
            touchPoint = gestureRecognizer.location(in: self.superview)
            print("began",gestureRecognizer.location(in: self.superview).y)
             print("began",gestureRecognizer.location(in: self).y)
            
        }
        if gestureRecognizer.state == .changed {
             isLongPressMoved = true
                movedTo(point: gestureRecognizer.location(in: bgClear))
        }
        else if gestureRecognizer.state == .ended {
            
            if isLongPressMoved {
                endTouch(point: gestureRecognizer.location(in: bgClear))
            }
            else{
                deActivate(optionIdx: -1)
            }
        }
        activate()
        delegate.longTap(sender: self)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate.sameTimeTouches(number: (event?.allTouches?.count)!)
    }
    func singleTapEvent(){
        print("singleTapEvent: ")
        delegate.singleTap(sender: self)
    }
     func optionTapEvent(_ gesture: CustomUITapGestureRecognize) {
        delegate.optionTap(index: gesture.any as! Int)
        print("option: ")
    }
    
    
    /**
     Function that open the Options Selector
     */
     func activate(){
        if !active {
            if dataset != nil {
                
                selectedItem = -1
                active = true
                bgClear = SelectorView(frame: frameSV)
                bgClear.delegate = self
                bgClear.backgroundColor = UIColor.clear
                
                //origin of button
                origin = self.superview?.convert(self.frame.origin, to: nil)
                 let sizeBtn:CGSize = CGSize(width: ((CGFloat(dataset.count+1)*spacing)+(size*CGFloat(dataset.count))), height: size+(2*spacing))
                if origin != self.frame.origin {
//                    if (origin.x > frameSV.width/2){
//                         bgClear.frame.origin.x -= sizeBtn.width
//                    }
               
                    //bgClear.frame.origin.y = 10
                    bgClear.frame.origin.y -= origin.y
                }
                
                self.superview?.addSubview(bgClear)
             
                options = UIView(frame: CGRect(x:touchPoint.x - sizeBtn.width/2,y:100 - (sizeBtn.height) ,width:sizeBtn.width,height:sizeBtn.height)).build({
                    $0.layer.cornerRadius  = sizeBtn.height/2
                    $0.backgroundColor     = UIColor.white
                    $0.layer.shadowColor   = UIColor.lightGray.cgColor
                    $0.layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)
                    $0.layer.shadowOpacity = 0.5
                    $0.alpha               = 0.3
                })
               
                bgClear.addSubview(options)
                
                
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.options.frame.origin.y = self.touchPoint.y - (self.s_options_selector+sizeBtn.height)
                    self.options.alpha          = 1
                })
                for i in
                    0 ..< dataset.count {
                        let option = UIImageView(frame: CGRect(x:(CGFloat(i+1)*spacing)+(size*CGFloat(i)),y:sizeBtn.height*1.2,width:10,height:10))
                        option.image = UIImage(named: dataset[i].image)
                        option.alpha = 0.6
                        let optionTap = CustomUITapGestureRecognize(target: self, action: #selector(EmojiableView.optionTapEvent))
                        option.isUserInteractionEnabled = true
                        option.addGestureRecognizer(optionTap)
                       
                        
                        options.addSubview(option)
                        UIView.animate(withDuration: 0.2, delay: 0.05*Double(i), options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
                            option.frame.origin.y       = self.spacing
                            option.alpha                = 1
                            option.frame.size           = CGSize(width: self.size, height: self.size)
                            option.center               = CGPoint(x: (CGFloat(i+1)*self.spacing)+(self.size*CGFloat(i))+self.size/2, y: self.spacing+self.size/2)
                        }, completion: nil)
                }
                information = InformationView(frame: CGRect(x:0,y:origin.y,width:frameSV.width,height:self.frame.height))
                information.backgroundColor = UIColor.clear
                //bgClear.addSubview(information)
            }
            else{
                print("Please, initialize the dataset.")
            }
        }
    }
    
    /**
     Function that close the Options Selector
     */
    fileprivate func deActivate(optionIdx:Int){
        for (i,option) in self.options.subviews.enumerated(){
            UIView.animate(withDuration: 0.2, delay: 0.05*Double(i), options: UIViewAnimationOptions.curveEaseInOut, animations: { () -> Void in
                self.information.alpha = 0
                option.alpha      = 0.3
                option.frame.size = CGSize(width: 10, height: 10)
                if(optionIdx == i){
                    option.center     = CGPoint(x: (CGFloat(i+1)*self.spacing)+(self.size*CGFloat(i))+self.size/2, y: -self.options.frame.height+self.size/2)
                }else{
                    option.center     = CGPoint(x: (CGFloat(i+1)*self.spacing)+(self.size*CGFloat(i))+self.size/2, y: self.options.frame.height+self.size/2)
                }
            }, completion:  { (finished) -> Void in
                if finished && i == (self.dataset.count/2){
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.options.alpha          = 0
                        self.options.frame.origin.y = self.touchPoint.y - (self.size+(2*self.spacing))
                    },completion:  { (finished) -> Void in
                        self.active = false
                        self.bgClear.removeFromSuperview()
                        if (optionIdx < 0){
                            self.delegate.canceledAction(sender: self)
                        }else{
                            self.delegate.selectedOption(sender: self, index: self.selectedItem)
                        }
                    })
                }
            })
        }
    }
    
    fileprivate func loseFocus(){
        selectedItem = -1
        information.activateInfo(active: true)
        UIView.animate(withDuration: 0.3) { () -> Void in
            
            let sizeBtn:CGSize = CGSize(width: ((CGFloat(self.dataset.count+1)*self.spacing)+(self.size*CGFloat(self.dataset.count))), height: self.size+(2*self.spacing))
            self.options.frame = CGRect(x: (self.touchPoint.x - sizeBtn.width/2), y: self.touchPoint.y - (self.s_options_selector+sizeBtn.height),width: sizeBtn.width,height: sizeBtn.height)
            self.options.layer.cornerRadius = sizeBtn.height/2
            for (idx,view) in self.options.subviews.enumerated(){
                view.frame = CGRect(x:(CGFloat(idx+1)*self.spacing)+(self.size*CGFloat(idx)),y:self.spacing,width:self.size,height:self.size)
            }
        }
    }
    
    func selectIndex(index:Int){
        print("index", index)
        if index >= 0 && index < dataset.count{
            selectedItem = index
            information.activateInfo(active: false)
            //pop up three icons
            UIView.animate(withDuration: 0.3) { () -> Void in
                let sizeBtn:CGSize = CGSize(width: ((CGFloat(self.dataset.count-1)*self.spacing)+(self.minSize*CGFloat(self.dataset.count-1))+self.maxSize), height: self.minSize+(2*self.spacing))
                self.options.frame = CGRect(x: self.touchPoint.x - sizeBtn.width/2,y: self.touchPoint.y - (self.s_options_selector+sizeBtn.height),width: sizeBtn.width,height: sizeBtn.height)
                self.options.layer.cornerRadius = sizeBtn.height/2
                var last:CGFloat = index != 0 ? self.spacing : 0
                for (idx,view) in self.options.subviews.enumerated(){
                    switch(idx){
                    case (index-1):
                        view.frame    = CGRect(x:last,y: self.spacing,width: self.minSize,height: self.minSize)
                        view.center.y = (self.minSize/2) + self.spacing
                        last          += self.minSize
                    case (index):
                        view.frame    = CGRect(x:last,y: -(self.maxSize/2),width: self.maxSize,height: self.maxSize)
                        last          += self.maxSize
                    default:
                        view.frame    = CGRect(x:last,y:self.spacing,width:self.minSize,height:self.minSize)
                        view.center.y = (self.minSize/2) + self.spacing
                        last          += self.minSize + self.spacing
                    }
                }
            }
        }
    }
    
  
    
}

extension EmojiableView:SelectorViewDelegate {
    public func movedTo(point:CGPoint){
        let sizeBtn:CGSize = CGSize(width: ((CGFloat(dataset.count+1)*spacing)+(size*CGFloat(dataset.count))), height: size+(2*spacing))
        let t = options.frame.width/CGFloat(dataset.count)
        if (point.x-(touchPoint.x - sizeBtn.width/2) > 0 && point.x < options.frame.maxX){
            selectIndex(index: Int(round((point.x-(touchPoint.x - sizeBtn.width/2))/t)))
        }
        else{
            loseFocus()
        }
    }
    public func endTouch(point:CGPoint){
        if (point.x > 0 && point.x < options.frame.maxX){
            self.deActivate(optionIdx: selectedItem)
        }else{
            self.deActivate(optionIdx: -1)
        }
    }

    
}

public class InformationView :UIView{
    private var textInformation:UILabel!
    public override func draw(_ rect: CGRect) {
        let dots = UIBezierPath()
        dots.move(to: CGPoint(x: 18.5,y: (rect.height/2)))
        dots.addLine(to: CGPoint(x: rect.width,y: (rect.height/2)))
        dots.lineCapStyle = CGLineCap.round
        UIColor(red:0.8, green:0.81, blue:0.82, alpha:1).setStroke()
        dots.lineWidth = 3
        let dashes: [CGFloat] = [dots.lineWidth * 0, 37]
        dots.setLineDash(dashes, count: dashes.count, phase: 0)
        dots.stroke()
        
        let lineSuperior = UIBezierPath()
        lineSuperior.move(to: CGPoint(x: 0,y: 0))
        lineSuperior.addLine(to: CGPoint(x: rect.width,y: 0))
        UIColor(red:0.8, green:0.81, blue:0.82, alpha:1).setStroke()
        lineSuperior.lineWidth = 1
        lineSuperior.stroke()
        
        let lineInferior = UIBezierPath()
        lineInferior.move(to: CGPoint(x:0,y:rect.height))
        lineInferior.addLine(to: CGPoint(x:rect.width,y:rect.height))
        UIColor(red:0.8, green:0.81, blue:0.82, alpha:1).setStroke()
        lineInferior.lineWidth = 1
        lineInferior.stroke()
        
        textInformation                 = UILabel(frame: CGRect(x:0,y:1,width: rect.width,height: rect.height-2))
        textInformation.backgroundColor = UIColor.white
        textInformation.textColor       = UIColor(red:0.57, green:0.59, blue:0.64, alpha:1)
        textInformation.text            = "離してキャンセル"
        textInformation.textAlignment   = .center
        textInformation.font            = UIFont.boldSystemFont(ofSize: 12)
        textInformation.alpha           = 0
        self.addSubview(textInformation)
    }
    
    func activateInfo(active:Bool){
       // textInformation.alpha = active ? 1 : 0
    }
}
