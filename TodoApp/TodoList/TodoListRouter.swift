//
//  TodoListRouter.swift
//  TodoApp
//
//  Created by Dias Yerlan on 20.11.2024.
//

import UIKit

class TodoListRouter: PresenterToRouterTodoListProtocol {
 
    
    
    static func createModule() -> UINavigationController? {
        let viewController = TodoListViewController()
        
        let navigationController = UINavigationController(rootViewController: viewController)
        let presenter: ViewToPresenterTodoListProtocol & InteractorToPresenterTodoListProtocol = TodoListPresenter()
        
        viewController.presenter = presenter
        viewController.presenter?.router = TodoListRouter()
        viewController.presenter?.view = viewController
        viewController.presenter?.interactor  = TodoListInteractor()
        viewController.presenter?.interactor?.presenter = presenter
        
        return navigationController
        
    }
    
    func navigateToTodoDetails(on view: (any PresenterToViewTodoListProtocol)?, with todo: Todo) {
        guard let viewController = view as? UIViewController else {
                    return
                }
        let editTodoVC = EditTodoViewController()
        editTodoVC.todo = todo
        editTodoVC.delegate = viewController as? any EditTodoViewControllerDelegate
        
        viewController.navigationController?.pushViewController(editTodoVC, animated: true)

    }

}
