//
//  MasterViewController.swift
//  iOS_Final_Project_Redux
//
//  Created by Ryan Lewis on 12/12/18.
//  Copyright © 2018 Ryan Lewis. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var datePicker:UIDatePicker = UIDatePicker()
    var statusPicker:UIPickerView = UIPickerView()
    var dateField:UITextField?
    var statusField:UITextField?
    var statuses = ["Todo", "In Progress", "Done"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // Mark - Add Tasks
    
    @objc
    func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title: "Add a Task", message: "You can set when it's due and the bin to put it in.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Create", style: .default) {
            [unowned self] action in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            
            guard let textField1 =  alert.textFields?.first, let text = textField1.text else {return}
            guard let textField2 = alert.textFields?[1], let date = dateFormatter.date(from: textField2.text ?? "Jan 1, 2019") else {return}
            guard let textField3 = alert.textFields?[2], let status = textField3.text else {return}
            self.save(text: text, status: status, due_date: date)
        }
        alert.addTextField() { (textField) in
            textField.placeholder = "Title"
        }
        alert.addTextField { (textField) in
            self.configureDatePicker()
            textField.inputView = self.datePicker
            textField.placeholder = "Due Date"
        }
        alert.addTextField { (textField) in
            self.configureStatusPicker()
            textField.inputView = self.statusPicker
            textField.text = "Todo"
        }
        dateField = alert.textFields?[1]
        statusField = alert.textFields?[2]
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func save(text: String, status: String, due_date: Date) {
        let context = self.fetchedResultsController.managedObjectContext
        let newTask = Task(context: context)
        newTask.text = text
        if status == "Todo" {
            newTask.status = 0
        } else if status == "In Progress" {
            newTask.status = 1
        } else if status == "Done" {
            newTask.status = 2
        } else {newTask.status = 0}
        newTask.due_date = due_date
        newTask.created_date = Date.init()
        
        // Save the context.
        do {
            try context.save()
        } catch {
            let saveAlert = UIAlertController(title: "Error", message: "There was a problem saving your tasks", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "OK", style: .default)
            saveAlert.addAction(acceptAction)
            present(saveAlert, animated: true)
        }
    }
    
    func configureDatePicker(){
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: self.view.frame.size.height - 220, width:self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(MasterViewController.datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    func configureStatusPicker() {
        self.statusPicker = UIPickerView(frame:CGRect(x: 0, y: self.view.frame.size.height - 220, width:self.view.frame.size.width, height: 216))
        self.statusPicker.backgroundColor = UIColor.white
        statusPicker.dataSource = self
        statusPicker.delegate = self
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateField!.text = dateFormatter.string(from: sender.date)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName = fetchedResultsController.sections![section].name
        if sectionName == "0" {
            return "Todo"
        } else if sectionName == "1" {
            return "In Progress"
        } else if sectionName == "2" {
            return "Done"
        } else {return "Undefined"}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let task = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withTask: task)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: TableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                let saveAlert = UIAlertController(title: "Error", message: "There was a problem saving your tasks", preferredStyle: .alert)
                let acceptAction = UIAlertAction(title: "OK", style: .default)
                saveAlert.addAction(acceptAction)
                present(saveAlert, animated: true)
            }
        }
    }

    func configureCell(_ cell: TableViewCell, withTask task: Task) {
        cell.cellItem = task
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "status", ascending: true), NSSortDescriptor(key: "due_date", ascending: true)]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "status", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let saveAlert = UIAlertController(title: "Error", message: "There was a problem getting your tasks.", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "OK", style: .default)
            saveAlert.addAction(acceptAction)
            present(saveAlert, animated: true)
        }
        
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)! as! TableViewCell, withTask: anObject as! Task)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! TableViewCell, withTask: anObject as! Task)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    // MARK - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(row == 0)
        {
            statusField!.text = "Todo"
        }
        else if(row == 1)
        {
            statusField!.text = "In Progress"
        }
        else if(row == 2)
        {
            statusField!.text = "Done"
        }
    }
}
