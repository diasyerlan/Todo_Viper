//
//  TodoListProtocols.swift
//  TodoApp
//
//  Created by Dias Yerlan on 20.11.2024.
//

import Foundation
import UIKit

protocol ViewToPresenterTodoListProtocol {
    var view: PresenterToViewTodoListProtocol? { get set }
    var interactor: PresenterToInteractorTodoListProtocol? { get set }
    var router: PresenterToRouterTodoListProtocol? { get set }
    func viewDidLoad()
    
    func updateSearchResults(for searchController: UISearchController)
    func willDismissSearchController(_ searchController: UISearchController)
    func numberOfRowsInSection() -> Int
    func configureCell(_ cell: TodoCell, at index: Int)
    func didSelectRowAt(index: Int)
    func didUpdateTodo(_ updatedTodo: Todo)
    func didDeleteTodoAt(index: Int)
    func updateToolbarLabel()
    func didTapAddButton()
    func updateSearchController(_ : UISearchController)

    
}

protocol PresenterToViewTodoListProtocol: AnyObject {
    func navigateToEditTodoScreen(with viewController: UIViewController)
    func showTodos()
    func updateToolbarLabel(with text: String)
    func onFetchTodoListFailure(error: String)
}

protocol PresenterToInteractorTodoListProtocol {
    var presenter: InteractorToPresenterTodoListProtocol? { get set }
    var todos: [Todo]? { get set }
    func fetchTodoList()
    
}

protocol InteractorToPresenterTodoListProtocol: AnyObject {
    func fetchTodoListSuccess(todos: [Todo])
    func fetchTodoListFailure(error: String)
}

protocol PresenterToRouterTodoListProtocol {
    static func createModule() -> UINavigationController?
    func navigateToTodoDetails(on view: PresenterToViewTodoListProtocol?, with todo: Todo)
}
