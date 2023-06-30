//
//  ViewController.swift
//  SailsDayJournal
//
//  Created by joe on 2023/06/30.
//

import UIKit

class ViewController: UITableViewController {
    
    fileprivate func fetchPosts() {
        Service.shared.fetchPosts { res in
            switch res {
            case .failure(let err):
                print("Failed to fetch posts:", err)
            case .success(let posts):
//                print(posts)
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
    var posts = [Post]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create Post", style: .plain, target: self, action: #selector(handleCreatePost))
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete post")
            let post = self.posts[indexPath.row]
            Service.shared.deletePost(id: post.id) { err in
                if let err = err {
                    print("Failed to delete:", err)
                    return
                }
                
                print("Successfully deleted post from server")
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    @objc fileprivate func handleCreatePost() {
        print("Creating post")
        
        layoutAlertController()
    }
    
    func performAdding(title: String, body: String) {
        Service.shared.createPost(title: title, body: body) { err in
            if let err = err {
                print("Failed to create post object:", err)
                return
            }
            
            print("Finished creating post")
            self.fetchPosts()
        }
    }
    
    func layoutAlertController() {
        let alertController = UIAlertController(title: "Write a post", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter TITLE"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter BODY"
        }
        
        let confirmAction = UIAlertAction(title: "Add", style: .default) { [weak alertController, weak self] _ in
            guard let textFields = alertController?.textFields else { return }
            
            if let title = textFields[0].text,
               let body = textFields[1].text {
                print("Title: \(title)")
                print("Body: \(body)")
                self?.performAdding(title: title, body: body)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }

}

