//
//  Extension UIAlertController.swift
//  TaskListWithCoreDataTest
//
//  Created by Светлана Сенаторова on 26.04.2023.
//

import UIKit

extension UIAlertController {
    
    static func createAlertController(witTitle title: String) -> UIAlertController {
        UIAlertController(title: title, message: "What do you want to do?", preferredStyle: .alert)
    }
    
    func action(task: Task?, completion: @escaping(String) -> Void) {
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newText = self?.textFields?.first?.text, !newText.isEmpty else { return }
            completion(newText)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField() { textField in
            textField.placeholder = "Task"
            textField.text = task?.title
        }
    }
    
}
