//
//  SelectorView.swift
//  BabyMap
//
//  Created by DT Dat on 2017/06/19.
//  Copyright © 2017 Trim, Inc. All rights reserved.
//

import Foundation
import UIKit
public protocol SelectorViewDelegate{
    func movedTo(point:CGPoint)
    func endTouch(point:CGPoint)
}
public class SelectorView: UIView {
    var delegate:SelectorViewDelegate?
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.movedTo(point: (touches.first?.location(in: self))!)
    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.endTouch(point: (touches.first?.location(in: self))!)
    }
}
