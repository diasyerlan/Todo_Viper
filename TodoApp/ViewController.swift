//
//  ViewController.swift
//  TodoApp
//
//  Created by Dias Yerlan on 15.11.2024.
//

import UIKit

class ViewController: UIViewController{
    
    let searchController = UISearchController(searchResultsController: nil)
    var tableView = UITableView()
    let toolbar = UIToolbar()
    var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    var todos: [Todo] = [] {
        didSet {
            updateToolBarLabel()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var filteredTodos: [Todo] = []

    
    let toolbarLabel: UILabel = {
        let label = UILabel()
        label.text = "Загружаем..."
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        return label
    } ()
    
    struct Cells {
        static let todoCell = "TodoCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Задачи"
        
        configureSearchBar()
        configureTableView()
        configureToolBar()
        
        fetchAndLoadTodos()
        
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        setTableViewDelegates()
        setTableViewConstraints()
        tableView.register(TodoCell.self, forCellReuseIdentifier: Cells.todoCell)
        
    }
    
    private func fetchAndLoadTodos() {
        fetchTodos {[weak self] fetchedTodos in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let fetchedTodos = fetchedTodos {
                    self.todos = fetchedTodos
                    self.tableView.reloadData()
                } else {
                    print("Failed to fetch todos")
                }
            }
        }
    }
    
    private func configureToolBar() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        
        let labelItem = UIBarButtonItem(customView: toolbarLabel)
        
        let addButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            button.tintColor = .customYellow
            button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            return button
        } ()
        
        let addButtonItem = UIBarButtonItem(customView: addButton)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, labelItem, flexSpace, addButtonItem]
        
        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
                ])
    }
    
    private func setTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureSearchBar() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    private func fetchTodos (completion: @escaping([Todo]?) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching todos - \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                completion(decodedResponse.todos)
            } catch {
                print("Error decoding JSON = \(error.localizedDescription)")
                completion(nil)
            }
        }
        .resume()
    }
    
    private func updateToolBarLabel() {
        toolbarLabel.text = "\(todos.count) задач"
    }
    
    @objc private func addButtonTapped() {
        let newTodo = Todo(todo: "", completed: false, body: "", date: Date())
        let editVC = EditTodoViewController()
        editVC.todo = newTodo
        editVC.delegate = self

        navigationController?.pushViewController(editVC, animated: true)
    }
    
}

extension ViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredTodos = []
            tableView.reloadData()
            return
        }
        filteredTodos = todos.filter { $0.todo.lowercased().contains(searchText) || $0.body.lowercased().contains(searchText) }
        tableView.reloadData()
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        filteredTodos = []
        tableView.reloadData()
    }

    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTodos.count : todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cells.todoCell) as? TodoCell else {
            return UITableViewCell()
        }
        let todo = isSearching ? filteredTodos[indexPath.row] : todos[indexPath.row]

        cell.configure(with: todo)
        
        cell.onCheckmarkTapped  = { [weak self] in
            guard let self = self else { return }
            self.todos[indexPath.row].completed.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = todos[indexPath.row]
        let editVC = EditTodoViewController()
        editVC.todo = todo
        editVC.delegate = self

        navigationController?.pushViewController(editVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}

extension ViewController: EditTodoViewControllerDelegate {
    func didUpdateTodo(_ updatedTodo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == updatedTodo.id }) {
            todos[index] = updatedTodo
        } else {
            todos.insert(updatedTodo, at: 0)
        }
        tableView.reloadData()
    }
}
