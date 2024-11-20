//
//  TodoListViewController.swift
//  TodoApp
//
//  Created by Dias Yerlan on 20.11.2024.
//

import UIKit

class TodoListViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var tableView = UITableView()
    let toolbar = UIToolbar()
    var presenter: (ViewToPresenterTodoListProtocol & InteractorToPresenterTodoListProtocol)?
    
    
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
        setupUI()
        
        presenter?.viewDidLoad()
        
    }
    
    func setupUI() {
        title = "Задачи"
        configureSearchBar()
        configureTableView()
        configureToolBar()
        
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        setTableViewDelegates()
        setTableViewConstraints()
        tableView.register(TodoCell.self, forCellReuseIdentifier: Cells.todoCell)
        
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
        presenter?.updateSearchController(searchController)

    }
    
    @objc private func addButtonTapped() {
        presenter?.didTapAddButton()
    }
}

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRowsInSection() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cells.todoCell) as? TodoCell else {
            return UITableViewCell()
        }
        presenter?.configureCell(cell, at: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                    presenter?.didDeleteTodoAt(index: indexPath.row)
                }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectRowAt(index: indexPath.row)
        
    }
}

extension TodoListViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.updateSearchResults(for: searchController)
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        presenter?.willDismissSearchController(searchController)
    }
}

extension TodoListViewController: EditTodoViewControllerDelegate {
    func didUpdateTodo(_ updatedTodo: Todo) {
        presenter?.didUpdateTodo(updatedTodo)
    }
}


extension TodoListViewController: PresenterToViewTodoListProtocol {
    
    func navigateToEditTodoScreen(with viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showTodos() {
        tableView.reloadData()
    }
    
    func updateToolbarLabel(with text: String) {
        toolbarLabel.text = text
    }
    
    
    func onFetchTodoListFailure(error: String) {
        print(error)
    }
}
