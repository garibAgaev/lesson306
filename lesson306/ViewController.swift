//
//  ViewController.swift
//  lesson306
//
//  Created by Garib Agaev on 11.09.2023.
//

import UIKit

//struct Task {
//    let title: String
//}

class ViewController: UITableViewController {
    // MARK: - Private property
    private let cellId = "task"
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    private var taskList: [Task] = []
    
    // MARK: - Live Cycle View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupController()
        fetcData()
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Task", titleAction: "Save") { [unowned self] tasName in
            save(tasName)
        }
    }
}

// MARK: - Setting View
private extension ViewController {
    
    func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func setupController() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemBlue
        
        let titleTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        
        navigationBarAppearance.titleTextAttributes = titleTextAttributes
        navigationBarAppearance.largeTitleTextAttributes = titleTextAttributes
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewTask))
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    private func fetcData() {
        let fetchRequest = Task.fetchRequest()
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Setting
private extension ViewController {
    private func showAlert(title: String, titleAction: String, action: @escaping(String) -> Void) {
        let alert = UIAlertController(title: title, message: "What do you want to do", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: titleAction, style: .default) { _ in
            guard let task = alert.textFields?.first?.text, task != "" else { return }
            action(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        [saveAction, cancelAction].forEach { alert.addAction($0) }
        alert.addTextField() { textField in
            textField.placeholder = title
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let task = Task(context: viewContext)
        task.title = taskName
        taskList.append(task)

        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        saveChanfe()
    }
    
    private func update(at indexPath: IndexPath, afterName: String) {
        taskList[indexPath.row].title = afterName
        var content = tableView.cellForRow(at: indexPath)?.defaultContentConfiguration()
        content?.text = afterName
        tableView.cellForRow(at: indexPath)?.contentConfiguration = content
        
        saveChanfe()
    }
    
    private func remove(at indexPath: IndexPath) {
        viewContext.delete(taskList[indexPath.row])
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveChanfe()
    }
    
    private func saveChanfe() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(title: "Update Task", titleAction: "save") { [unowned self] taskName in
            update(at: indexPath, afterName: taskName)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        remove(at: indexPath)
    }
}
