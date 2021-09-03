//
//  PostManager.swift
//  Reddit
//
//  Created by Zachary Buffington on 9/3/21.
//

import Foundation

protocol PostManagerDelegate {
    func didFetchPosts(posts: [Post])
    func didFail(error: Error?)
}

struct PostManager {
    
    var delegate: PostManagerDelegate?
    
    func fetchPost(for subreddit: String) {
        // url - https://www.reddit.com/r/{subreddit}.json
        guard var url = URL(string: "https://www.reddit.com/r/") else {
        delegate?.didFail(error: nil)
        return
        }
        
        url.appendPathComponent(subreddit)
        url.appendPathExtension("json")
        print(url)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                delegate?.didFail(error: error)
                return
            }
            
            guard let data = data else {
                delegate?.didFail(error: nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(RedditResponse.self, from: data)
                let posts = response.data.children.map { $0.data }
                delegate?.didFetchPosts(posts: posts)
                
            } catch {
                delegate?.didFail(error: error)
                return
            }
            
            
        }.resume()
      
        
        
    }
    
}
