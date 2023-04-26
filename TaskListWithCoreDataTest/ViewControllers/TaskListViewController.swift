//
//  TaskListViewController.swift
//  TaskListWithCoreDataTest
//
//  Created by Светлана Сенаторова on 25.04.2023.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private var tasks: [Task] = []
    private let cellID = "taskCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchTasks()
    }

// MARK: - Configure NavigationBar
    
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
        showAlert()
    }
    
// MARK: - Work with Storage Manager
    
    private func fetchTasks() {
        StorageManager.shared.fetch { [unowned self] result in
            switch result {
            case .success(let tasks):
                self.tasks = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
   
    private func saveTask(withTitle title: String) {
        StorageManager.shared.create(taskTitle: title) { [unowned self] task in
            tasks.append(task)
            let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
        }
    }
    
    private func deleteTask(at index: Int) {
        let task = tasks.remove(at: index)
        StorageManager.shared.delete(task: task)
    }
    
}

// MARK: - UIAlertController

extension TaskListViewController {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        let alert = UIAlertController.createAlertController(witTitle: title)
        
        alert.action(task: task) { [weak self] newText in
            if let task = task, let completion = completion {
                StorageManager.shared.update(task: task, with: newText)
                completion()
            } else {
                self?.saveTask(withTitle: newText)
            }
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
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        showAlert(with: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}


