//
//  TodoListPresenter.swift
//  TodoApp
//
//  Created by Dias Yerlan on 20.11.2024.
//

import Foundation
import UIKit

class TodoListPresenter: ViewToPresenterTodoListProtocol, EditTodoViewControllerDelegate {
    
    private var searchController: UISearchController?

    private var searchText: String = ""
    private var isSearchActive: Bool {
            return searchController?.isActive ?? false && !(searchController?.searchBar.text?.isEmpty ?? true)
        }
    var todos: [Todo] = [] {
            didSet {
                updateToolbarLabel()
                DispatchQueue.global(qos: .background).async {
//                                for todo in self.todos {
//                                    CoreDataManager.shared.saveTodoToCoreData(todo: todo)
//                                }
                            }
                            DispatchQueue.main.async {
                                self.view?.showTodos()
                            }
            }
        }
     var filteredTodos: [Todo] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    weak var view: (any PresenterToViewTodoListProtocol)?
    var interactor: (any PresenterToInteractorTodoListProtocol)?
    var router: (any PresenterToRouterTodoListProtocol)?
    
    func viewDidLoad() {
        
        isFirstLaunch() ? interactor?.fetchTodoList() : fetchTodosFromCoreData()
    }
    
    func fetchTodosFromCoreData() {
//        let todosFromDatabase = CoreDataManager.shared.fetchTodos()
//        self.todos = todosFromDatabase
        view?.showTodos()
    }
    
    private func isFirstLaunch() -> Bool {
        let key = "isFirstLaunch"
        let isFirst = !UserDefaults.standard.bool(forKey: key)
        
        if isFirst {
            UserDefaults.standard.set(true, forKey: key)
        }
        print(isFirst)
        
        return true    }

    func updateSearchController(_ searchController: UISearchController) {
            self.searchController = searchController
        }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredTodos = todos
            view?.showTodos()
            return
        }

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            let filtered = self.todos.filter {
                $0.todo.lowercased().contains(searchText) ||
                $0.body.lowercased().contains(searchText)
            }
            
            DispatchQueue.main.async {
                self.filteredTodos = filtered
                self.view?.showTodos()
            }
        }
    }

    func didDeleteTodoAt(index: Int) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            todos.remove(at: index)
            DispatchQueue.main.async {
                self.view?.showTodos()
            }
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        filteredTodos = []
        view?.showTodos()
    }
    
    func numberOfRowsInSection() -> Int {
        return isSearchActive ? filteredTodos.count : todos.count

    }
    
    func configureCell(_ cell: TodoCell, at index: Int) {
        let todo = isSearchActive ? filteredTodos[index] : todos[index]
            
            cell.configure(with: todo)
            
            cell.onCheckmarkTapped = { [weak self] in
                guard let self = self else { return }
                if self.isSearchActive{
                    self.filteredTodos[index].completed.toggle()
                    if let todoIndex = self.todos.firstIndex(where: { $0.id == self.filteredTodos[index].id }) {
                                    self.todos[todoIndex].completed = self.filteredTodos[index].completed
                                }
                } else {
                    self.todos[index].completed.toggle()
                }
                self.view?.showTodos()
            }
        }
    
    func didSelectRowAt(index: Int) {
        let todo = isSearchActive ? filteredTodos[index] : todos[index]
        let editVC = EditTodoViewController()
        editVC.todo = todo
        editVC.delegate = self

        router?.navigateToTodoDetails(on: view, with: todo)

        
    }
    
    func didUpdateTodo(_ updatedTodo: Todo) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
               guard let self = self else { return }
               
               if let index = self.todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                   self.todos[index] = updatedTodo
               } else {
                   self.todos.insert(updatedTodo, at: 0)
               }
            
               DispatchQueue.main.async {
                   self.view?.showTodos()
               }
           }
    }
    
    func updateToolbarLabel() {
        DispatchQueue.main.async {
            self.view?.updateToolbarLabel(with: "\(self.todos.count) задач")
        }
    }
    
    func didTapAddButton() {
        DispatchQueue.global(qos: .userInitiated).async {
            let newTodo = Todo(todo: "", completed: false, body: "", date: Date())
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let editVC = EditTodoViewController()
                editVC.todo = newTodo
                editVC.delegate = self
                self.view?.navigateToEditTodoScreen(with: editVC)
            }
        }
    }
}


extension TodoListPresenter: InteractorToPresenterTodoListProtocol {
    func fetchTodoListSuccess(todos: [Todo]) {
        self.todos = todos
        view?.showTodos()
    }
    
    func fetchTodoListFailure(error: String) {
        view?.onFetchTodoListFailure(error: "Error in fetching todos - \(error)")
    }
    
    
}
