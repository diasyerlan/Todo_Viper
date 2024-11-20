//
//  TodoListInteractor.swift
//  TodoApp
//
//  Created by Dias Yerlan on 20.11.2024.
//

import Foundation

class TodoListInteractor: PresenterToInteractorTodoListProtocol {
    
    var presenter: (any InteractorToPresenterTodoListProtocol)?
    
    var todos: [Todo]?
    
    func fetchTodoList() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard let url = URL(string: "https://dummyjson.com/todos") else {
                DispatchQueue.main.async {
                    self.presenter?.fetchTodoListFailure(error: "Invalid URL")
                }
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        
                        self.presenter?.fetchTodoListFailure(error: error.localizedDescription)
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.presenter?.fetchTodoListFailure(error: "No data received")
                    }
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.presenter?.fetchTodoListSuccess(todos: decodedResponse.todos ?? [])
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.presenter?.fetchTodoListFailure(error: error.localizedDescription)
                    }
                }
            }.resume() 
        }
    }

}
