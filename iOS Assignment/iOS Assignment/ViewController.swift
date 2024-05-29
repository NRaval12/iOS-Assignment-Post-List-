//
//  ViewController.swift
//  iOS Assignment
//
//  Created by Nikita on 29/05/24.
//

import UIKit

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
}

class PostTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    func configure(with post: Post) {
        titleLabel.text = post.title.capitalized
        idLabel.text = "\(post.id)"
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblPostID : UILabel!
    @IBOutlet weak var lblPostTitle : UILabel!
    @IBOutlet weak var lblPostDetail : UILabel!
    
    var posts: [Post] = []
    var computationCache: [Int: String] = [:]
    var currentPage = 1
    var isFetching = false
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Post List"
        tableView.rowHeight = UITableView.automaticDimension
        fetchPosts(page: currentPage)
    }
    //MARK: Fetch the Post With Pagination Concept
    func fetchPosts(page: Int)
    {
        guard !isFetching else { return }
        isFetching = true
        let urlString = "https://jsonplaceholder.typicode.com/posts?_page=\(page)&_limit=20"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard let data = data else { return }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                self.posts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.isFetching = false
            } catch {
                print("Failed to decode JSON: \(error)")
                self.isFetching = false
            }
        }.resume()
    }
    
    //MARK: UITableview Delegate & Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.idLabel.layer.borderColor = UIColor.black.cgColor
        cell.idLabel.layer.masksToBounds = true

        let post = posts[indexPath.row]
        //This line is written here as mention in document that perform heavy computation.
        print("Heavy Computation Optimization",self.performHeavyComputation(for: post))
        cell.configure(with: post)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
    {
        let post = posts[indexPath.row]
        let detailVC : DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.modalPresentationStyle = .overFullScreen//.overCurrentContext
        detailVC.post = post
        self.present(detailVC, animated: true) {
            print("Call back")
        }

        //Another way to display detail in the same controller without any data passing.
        /*self.lblHeader.text = "Post Detail"
        self.lblPostID.text = "\(post.id)"
        self.lblPostTitle.text = post.title.capitalized
        self.lblPostDetail.text = post.body.capitalized
        
        self.animateTheDetailView(flag: false)*/
    }
    @IBAction func btnClose(sender : UIButton)
    {
        self.animateTheDetailView(flag: true)
    }
    func animateTheDetailView(flag : Bool)
    {
        UIView.transition(with: self.detailView, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations:
        {
            self.detailView.isHidden = flag
            self.shadowView.isHidden = flag
        })
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    //MARK: Pagination concept implementation
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 2 {
            if !isFetching {
                currentPage += 1
                fetchPosts(page: currentPage)
            }
        }
    }
    
    //MARK: Handle intensive computation
    func performHeavyComputation(for post: Post) -> String
    {
        //Use a cache or a dictionary to store results of heavy computations to avoid recomputation
        if let cachedResult = computationCache[post.id] {
            print("From cache")
            return cachedResult
        }
        
        // Simulate heavy computation And Logic for: Log the time taken for the heavy computation process. 
        /*let startTime = Date()
        Thread.sleep(forTimeInterval: 0.5) // Replace with actual computation
        let endTime = Date()
        let computationTime = endTime.timeIntervalSince(startTime)
        print("Heavy computation took \(computationTime) seconds")
        let result = "Computed details for post ID: \(post.id)"*/
        
        //Anothe computation
        let randomNumber1 = Int.random(in: 1...100)
        let randomNumber2 = Int.random(in: 1...100)
        let result = randomNumber1 + randomNumber2
        computationCache[post.id] = "\(result)"
        return "\(result)"
    }
}


class DetailViewController: UIViewController
{
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblPostID : UILabel!
    @IBOutlet weak var lblPostTitle : UILabel!
    @IBOutlet weak var lblPostDetail : UILabel!
    
    var post: Post?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setData()
    }
    func setData()
    {
        self.lblHeader.text = "Post Detail"
        self.lblPostID.text = "\(post?.id ?? 0)"
        self.lblPostTitle.text = post?.title.capitalized
        self.lblPostDetail.text = post?.body.capitalized
    }
    @IBAction func btnClose(sender : UIButton)
    {
        self.dismiss(animated: true)
    }
}
