//
//  TableViewCell.swift
//  Final Project
//
//  Created by Ryan Lewis on 12/12/18.
//  Copyright © 2018 Ryan Lewis. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var moveUpButton: UIButton!
    @IBOutlet weak var moveDownButton: UIButton!
    var cellItem: Task? {
        didSet {
            titleLabel.text = cellItem?.text
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            dueDateLabel?.text = "Due \(dateFormatter.string(from: (cellItem?.due_date) ?? Date.init()))"
            
            if cellItem?.status == 0 {
                moveUpButton.isHidden = true
                moveDownButton.isHidden = false
            } else if cellItem?.status == 1{
                moveUpButton.isHidden = false
                moveDownButton.isHidden = false
            } else if cellItem?.status == 2 {
                moveUpButton.isHidden = false
                moveDownButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func moveUp(_ sender: UIButton) {
        if cellItem?.status == 1 {
            cellItem?.status = 0
            moveUpButton.isHidden = true
        } else if cellItem?.status == 2 {
            cellItem?.status = 1
            moveDownButton.isHidden = false
        }
    }
    
    @IBAction func moveDown(_ sender: UIButton) {
        if cellItem?.status == 0 {
            cellItem?.status = 1
            moveUpButton.isHidden = false
        } else if cellItem?.status == 1 {
            cellItem?.status = 2
            moveDownButton.isHidden = true
        }
    }
}
