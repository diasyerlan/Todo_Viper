//
//  Todo.swift
//  TodoApp
//
//  Created by Dias Yerlan on 17.11.2024.
//

import Foundation

struct Todo: Codable {
    let id: Int
    var todo: String
    var body: String
    var date: Date
    var completed: Bool
    let userId: Int
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.todo = try container.decode(String.self, forKey: .todo)
        self.body = (try? container.decode(String.self, forKey: .body)) ?? ""
        self.date = (try? container.decode(Date.self, forKey: .date)) ?? Date()
        self.completed = try container.decode(Bool.self, forKey: .completed)
        self.userId = try container.decode(Int.self, forKey: .userId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, todo, body, date, completed, userId
    }
    
    init(todo: String, completed: Bool = false, userId: Int = 101, body: String = "", date: Date = Date()) {
        self.id = Int.random(in: 1...1000)
        self.todo = todo
        self.completed = completed
        self.userId = userId
        self.body = body
        self.date = date
    }
}

struct TodoResponse: Codable {
    let todos: [Todo]
}
