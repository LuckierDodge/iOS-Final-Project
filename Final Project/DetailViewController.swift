//
//  DetailViewController.swift
//  iOS_Final_Project_Redux
//
//  Created by Ryan Lewis on 12/12/18.
//  Copyright © 2018 Ryan Lewis. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var createdDateTextField: UITextView!
    @IBOutlet weak var statusPickerView: UIPickerView!
    let statuses = ["Todo", "In Progress", "Done"]
    var managedObjectContext: NSManagedObjectContext? = nil

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            
            if let label = taskTextField {
                label.text = detail.text
            }
            if let label = dueDatePicker {
                label.date = detail.due_date!
            }
            if let label = createdDateTextField {
                label.text = "Date Created: \(dateFormatter.string(from: (detail.created_date)!))"
            }
            if let label = statusPickerView {
                label.selectRow(Int(detail.status), inComponent: 0, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statusPickerView.dataSource = self
        statusPickerView.delegate = self
        configureView()
    }
    

    var detailItem: Task? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    //MARK - Actions
    
    @IBAction func changedDueDate(_ sender: UIDatePicker) {
        detailItem?.due_date = sender.date
    }
    
    @IBAction func changedTitle(_ sender: UITextField) {
        detailItem?.text = sender.text
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        detailItem?.status = Int16(row)
    }
    
    //MARK - Picker View Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
    
    // MARK: - Fetched results controller
    
//    var fetchedResultsController: NSFetchedResultsController<Task> {
//        if _fetchedResultsController != nil {
//            return _fetchedResultsController!
//        }
//        
//        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//        
//        // Set the batch size to a suitable number.
//        fetchRequest.fetchBatchSize = 20
//
//        // Edit the sort key as appropriate.
//        let sortDescriptor = NSSortDescriptor(key: "status", ascending: true)
//        let predicate = NSPredicate(format: "created_date == %@", argumentArray: [detailItem?.created_date! as Any])
//
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        fetchRequest.predicate = predicate
//
//        // Edit the section name key path and cache name if appropriate.
//        // nil for section name key path means "no sections".
//        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
//        aFetchedResultsController.delegate = self
//        _fetchedResultsController = aFetchedResultsController
//        
//        do {
//            try _fetchedResultsController!.performFetch()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//
//
//        return _fetchedResultsController!
//    }
//    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil

}
