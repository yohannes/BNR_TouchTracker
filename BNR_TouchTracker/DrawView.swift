//
//  DrawView.swift
//  BNR_TouchTracker
//
//  Created by Yohannes Wijaya on 4/5/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    // MARK: - Stored Properties
    
    var currentLines = [NSValue: Line]()
    var finishedLines = Array<Line>()
    var selectedLineIndex: Int?
    
    // MARK: - IBInspectable properties
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.redColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var selectedLineColor: UIColor = UIColor.greenColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Local Methods
    
    func strokeLine(line: Line) {
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = self.lineThickness
        bezierPath.lineCapStyle = CGLineCap.Round
        
        bezierPath.moveToPoint(line.begin)
        bezierPath.addLineToPoint(line.end)
        bezierPath.stroke()
    }
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer) {
        print("Gesture recognized as a double tap")
        
        self.selectedLineIndex = nil
        self.currentLines.removeAll(keepCapacity: false)
        self.finishedLines.removeAll(keepCapacity: false)
        self.setNeedsDisplay()
    }
    
    func singleTap(gestureRecognizer: UIGestureRecognizer) {
        print("Gesure recognized as a single tap")
        
        let tapLocationPoint = gestureRecognizer.locationInView(self)
        self.selectedLineIndex = self.indexOfLineAtPoint(tapLocationPoint)
        self.setNeedsDisplay()
    }
    
    func indexOfLineAtPoint(point: CGPoint) -> Int? {
        // Find a line close to point
        for (index, line) in self.finishedLines.enumerate() {
            let begin = line.begin
            let end = line.end
            
            // Check a few points on the line
            for t in CGFloat(0).stride(to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0 { return index }
            }
            
        }
        
        // If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
    // MARK: NSCoder Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delaysTouchesBegan = true
        self.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTap:")
        singleTapGestureRecognizer.delaysTouchesBegan = true
        singleTapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        self.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    // MARK: - UIView Methods
    
    override func drawRect(rect: CGRect) {
        self.finishedLineColor.setStroke()
        for line in self.finishedLines {
            self.strokeLine(line)
        }
        self.currentLineColor.setStroke()
        for (_, line) in self.currentLines {
            self.strokeLine(line)
        }
        if let validIndex = self.selectedLineIndex {
            self.selectedLineColor.setStroke()
            let selectedLine = self.finishedLines[validIndex]
            self.strokeLine(selectedLine)
        }
    }
    
    // MARK: - UIResponder Methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(__FUNCTION__)
        for touch in touches {
            let validTouchLocation = touch.locationInView(self)
            let newLine = Line(begin: validTouchLocation, end: validTouchLocation)
            // Will return the memory address of the argument
            let key = NSValue(nonretainedObject: touch)
            self.currentLines[key] = newLine
        }
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(__FUNCTION__)
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            self.currentLines[key]?.end = touch.locationInView(self)
        }
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(__FUNCTION__)
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if var validLine = self.currentLines[key] {
                validLine.end = touch.locationInView(self)
                self.finishedLines.append(validLine)
                self.currentLines.removeValueForKey(key)
            }
        }
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(__FUNCTION__)
        self.currentLines.removeAll()
        self.setNeedsDisplay()
    }
}
