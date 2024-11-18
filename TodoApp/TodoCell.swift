//
//  TodoCell.swift
//  TodoApp
//
//  Created by Dias Yerlan on 17.11.2024.
//

import UIKit

class TodoCell: UITableViewCell {
    
    let checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentMode = .scaleAspectFit
        return button
       
    }()
    
    let todoTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let todoBody: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()
    
    var onCheckmarkTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(checkButton)
        contentView.addSubview(todoTitle)
        contentView.addSubview(todoBody)
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        todoTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 32),
            checkButton.heightAnchor.constraint(equalToConstant: 32),
            
            todoTitle.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 16),
            todoTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            todoTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
//            todoBody.leadingAnchor.constraint(equalTo: todoTitle.leadingAnchor),
            
        ])
        
        checkButton.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
    }
    
    @objc private func didTapCheckButton() {
        onCheckmarkTapped?()
    }
    
    func configure(with todo: Todo) {
        todoTitle.text = todo.todo
        todoBody.text = todo.body
        updateUI(isCompleted: todo.completed)
    }
    
    private func updateUI(isCompleted: Bool) {
        let icon = isCompleted ? "checkmark.circle" : "circle"
        let color: UIColor = isCompleted ? .customYellow : .systemGray
        checkButton.setImage(UIImage(systemName: icon), for: .normal)
        
        let attributes: [NSAttributedString.Key: Any] = isCompleted ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.gray] : [.strikethroughStyle: 0, .foregroundColor: UIColor.label]
        todoTitle.attributedText = NSAttributedString(string: todoTitle.text ?? "", attributes: attributes)
        checkButton.tintColor = color
        
    }
    
}
