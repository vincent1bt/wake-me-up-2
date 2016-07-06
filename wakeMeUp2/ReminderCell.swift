//
//  ReminderCell.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/4/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit

protocol RemindersCellProtocol {
    func completeReminderFromCell(id: Int)
    func deleteReminderFromCell(id: Int)
}

class ReminderCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    var createCell = false
    var delegate: RemindersCellProtocol?
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var completeOnDragRelease = false
    var completeView: UIView!
    var textCellLabel: UILabel!
    var cellHeight: Int!
    var cellWidth: Int!
    var id: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configGesture()
        self.configCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.id = self.textField.tag
        self.cellWidth = Int(self.superview!.frame.width)
        self.cellHeight = Int(self.frame.height)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configGesture() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    func configCell() {
        self.completeView = UIView()
        self.textCellLabel = UILabel()
        self.textCellLabel.font = UIFont.systemFontOfSize(18)
        self.textCellLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 0.98)
    }
    
    func modifyView(completeView completeView: Bool = false) {
        var color: UIColor = UIColor.init(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0)
        var frame = CGRect(x: cellWidth - 90, y: 30, width: self.cellWidth, height: 60)
        if completeView {
            frame = CGRect(x: 20, y: 30, width: self.cellWidth, height: 60)
            color = UIColor.init(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
        }
        self.textCellLabel.text = completeView ? "Completar" : "Eliminar"
        self.completeView.backgroundColor = color
        self.textCellLabel.frame = frame
    }
    
    func addView() {
        self.superview?.addSubview(completeView)
        self.superview?.sendSubviewToBack(completeView)
        let y = (self.cellHeight * self.id) + 35
        let x = 0
        self.completeView.frame = CGRect(x: x, y: y, width: self.cellWidth, height: self.cellHeight)
        self.completeView.addSubview(self.textCellLabel)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            self.originalCenter = center
            addView()
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            translation.x > 0 ? modifyView(completeView: true) : modifyView()
            center = CGPointMake(self.originalCenter.x + translation.x, self.originalCenter.y)
            self.deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            self.completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
        }
        
        if recognizer.state == .Ended {
            let originalFrame = CGRect(x: 0, y: self.frame.origin.y, width: self.bounds.size.width, height: self.bounds.size.height)
            if self.deleteOnDragRelease {
                self.delegate?.deleteReminderFromCell(self.id)
                self.completeView.removeFromSuperview()
                return
            } else if self.completeOnDragRelease {
                self.delegate?.completeReminderFromCell(self.id)
            }
            
            UIView.animateWithDuration(0.2, animations: { 
                self.frame = originalFrame
                }, completion: { (_) in
                self.completeView.removeFromSuperview()
            })
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.createCell {
            return false
        }
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }

}
