//
//  TaskListViewController.swift
//  TaskListWithCoreDataTest
//
//  Created by Светлана Сенаторова on 25.04.2023.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var tasks: [Task] = []
    private let cellID = "taskCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchTasks()
    }

    private func setUpNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .systemPink
        navBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }

    @objc private func addTask() {
        showAlert(with: "New task", and: "What do you want to do?", action: "Save")
    }
    
// MARK: - CoreData
    
    private func fetchTasks() {
        let fetchRequest = Task.fetchRequest()
        do {
            try tasks = viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
   
    private func saveTask(withTitle title: String) {
        let task = Task(context: viewContext)
        task.title = title
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func deleteTask(at index: Int) {
        let task = tasks.remove(at: index)
        viewContext.delete(task)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func editTasks(at indexPath: IndexPath, withNewTitle title: String) {
        let task = tasks[indexPath.row]
        task.title = title
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UIAlertController

extension TaskListViewController {
    
    private func showAlert(with title: String, and message: String, action: String, index: Int? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            saveTask(withTitle: text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [unowned self] _ in
            let cellIndex = IndexPath(row: index ?? 0, section: 0)
            guard let text = alert.textFields?.first?.text else { return }
            editTasks(at: cellIndex, withNewTitle: text)
        }
        
        action == "Save" ? alert.addAction(saveAction) : alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField() { [unowned self] textField in
            textField.placeholder = action == "Save" ? "New Task" : "Edit task"
            textField.text = action == "Save" ? "" : tasks[index ?? 0].title
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = tasks[indexPath.row].title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(with: "Edit Task", and: "What do you wand to change?", action: "Edit", index: indexPath.row)
    }
}


