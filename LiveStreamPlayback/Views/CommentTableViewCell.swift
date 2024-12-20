//
//  CommentTableViewCell.swift
//  LiveStreamPlayback
//
//  Created by rudra misra on 20/12/24.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    static let identifier = "CommentCell"

    // UI Elements for the custom cell
    let userImageView = UIImageView()
    let userNameLabel = UILabel()
    let commentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Set up the cell's UI components
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        
        self.backgroundColor = .clear
        
        // User Image View setup
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        contentView.addSubview(userImageView)
        userImageView.image = UIImage(systemName: "person.crop.circle.fill")
        
        // User Name Label setup
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        userNameLabel.textColor = .lightGray
        contentView.addSubview(userNameLabel)
        
        // Comment Label setup
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.font = UIFont.systemFont(ofSize: 14)
        commentLabel.numberOfLines = 0 // Allow multiple lines
        commentLabel.textColor = .white
        contentView.addSubview(commentLabel)
        
        // Constraints for UI elements
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            userImageView.widthAnchor.constraint(equalToConstant: 40),
            userImageView.heightAnchor.constraint(equalToConstant: 40),
            
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8),
            userNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            
            commentLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            commentLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8),
            commentLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            commentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    // Configure the cell with comment data
    func configure(with comment: Comment) {
        getImageAndShow(urlString: comment.picURL ?? "")
        userNameLabel.text = comment.username
        commentLabel.text = comment.comment
    }
    
    func getImageAndShow(urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.userImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}
