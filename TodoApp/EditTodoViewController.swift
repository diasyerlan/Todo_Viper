//
//  EditTodoViewController.swift
//  TodoApp
//
//  Created by Dias Yerlan on 19.11.2024.
//

import UIKit

protocol EditTodoViewControllerDelegate: AnyObject {
    func didUpdateTodo(_ updatedTodo: Todo)
}

class EditTodoViewController: UIViewController {
    
    var todo: Todo?
    weak var delegate: EditTodoViewControllerDelegate?
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.placeholder = "Enter title"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let bodyTextField: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Enter todo description"
        textView.textColor = .systemGray2
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    } ()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyTextField.delegate = self
        navigationController?.navigationBar.tintColor = .customYellow
        setupUI()
//        setupSaveButton()
        populateDataIfNeeded()
        
    }
    
//    private func setupSaveButton() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
//                                                            style: .done,
//                                                            target: self,
//                                                            action: #selector(saveChanges))
//        navigationItem.rightBarButtonItem?.isEnabled = todo?.todo != ""
//        titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
//
//    }
    private func populateDataIfNeeded() {
        if let todo = todo {
            titleTextField.text = todo.todo
            if todo.body != "" {
                bodyTextField.text = todo.body
                bodyTextField.textColor = .label
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d/M/yyyy"
            let formattedDate = dateFormatter.string(from: todo.date ?? Date())
            
            dateLabel.text = formattedDate
        }
    }
    
//    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
//        // Enable the Save button if the titleTextField is not empty
//        navigationItem.rightBarButtonItem?.isEnabled = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
//    }

    
    @objc private func saveChanges() {
        guard var todo = todo else { return }
        
        todo.todo = titleTextField.text ?? ""
        todo.body = (bodyTextField.textColor == .systemGray2) ? "" : bodyTextField.text
        todo.date = Date()
        
        delegate?.didUpdateTodo(todo)
        
        navigationController?.popViewController(animated: true)
    }
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(titleTextField)
        view.addSubview(bodyTextField)
        view.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            
            bodyTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            bodyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            bodyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bodyTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let updatedTitle = titleTextField.text, !updatedTitle.isEmpty else { return }
        
        let updatedBody = bodyTextField.textColor == .systemGray2 ? "" : bodyTextField.text
        todo?.todo = updatedTitle
        todo?.body = updatedBody!
        
        delegate?.didUpdateTodo(todo!)
    }
    
    
}

extension EditTodoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if bodyTextField.textColor == .systemGray2 {
            bodyTextField.text = nil
            bodyTextField.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if bodyTextField.text.isEmpty {
            bodyTextField.text = "Введите детали задачи"
            bodyTextField.textColor = .systemGray2
        }
    }
}

