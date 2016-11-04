//
//  LatestPostTableViewController.swift
//  
//
//  Created by test on 2016-11-03.
//
//

import UIKit
import Alamofire
import SwiftyJSON


class LatestPostTableViewController: UITableViewController {
    
    
    
    // let url = "https://wlcdesigns.com/wp-json/wp/v2/posts/"
    
   // let latestPosts = "http://kasasalanbeya.esy.es/api/?json=get_posts&post_type=chapters"
    
     let latestPosts = "http://prophets.esy.es/wp-json/wp/v2/chapters"
    
   // let latestPosts : String = "https://wlcdesigns.com/wp-json/wp/v2/posts/"
    
    let parameters : [String:AnyObject] = [
        "filter[post_type]" : "chapters" as AnyObject,
        "filter[posts_per_page]" : 5 as AnyObject
    ]
    
    var json : JSON = JSON.null
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPosts(latestPosts)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LatestPostTableViewController.newNews), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        
        
        
    }
    
    func newNews()
    {
        getPosts(latestPosts)
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    
    func getPosts(_ getposts : String)
    {
        
      //  let url = "http://kasasalanbeya.esy.es/api/?json=get_posts&post_type=chapters"
        
        
          let url = "http://prophets.esy.es/wp-json/wp/v2/chapters"
        
        Alamofire.request(url, method: .get, parameters:parameters,  encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            guard let data = response.result.value else{
                print("Request failed with error")
                return
            }
            
            self.json = JSON(data)
            self.tableView.reloadData()
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch self.json.type
        {
        case Type.array:
            return self.json.count
        default:
            return 1
        }
    }
    
    func populateFields(_ cell: LatestPostTableViewCell, index: Int){
        
        //Make sure post title is a string
        guard let title = self.json[index]["title"]["rendered"].string else{
            cell.postTitle!.text = "Loading..."
            return
        }
        
        // An action must always proceed the guard conditional
        cell.postTitle!.text = title
        
        //Make sure post date is a string
        guard let date = self.json[index]["date"].string else{
            cell.postDate!.text = "--"
            return
        }
        
        cell.postDate!.text = date
        
        /*
         * Set up Featured Image
         * Using guard, there's no need for nested if statements
         * to unwrap and check optionals
         */
        
        guard let image = self.json[index]["featured_image"].string ,
            image != "null"
            else{
                
                print("Image didn't load")
                return
        }
        
        ImageLoader.sharedLoader.imageForUrl(urlString: image, completionHandler:{(image: UIImage?, url: String) in
            cell.postImage.image = image!
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> LatestPostTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! LatestPostTableViewCell
        
        // Get row index
        let row = indexPath.row
        
        //Make sure post title is a string
        if let title = self.json[row]["title"]["rendered"].string{
            cell.postTitle!.text = title
        }
        
        //Make sure post date is a string
        if let date = self.json[row]["date"].string{
            cell.postDate!.text = date
        }
        
        if let image = self.json[row]["featured_image"].string{
            
            if image != "null"{
                
                ImageLoader.sharedLoader.imageForUrl(urlString: image, completionHandler:{(image: UIImage?, url: String) in
                    cell.postImage.image = image!
                })
            }
        }
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return NO if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return NO if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let singlePostVC : PostViewController = storyboard!.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        singlePostVC.json = self.json[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(singlePostVC, animated: true)
        
    }
    
    
    
    /*/////Second Method to view detail view
     ////WebView Code for WebViwController.swift storyboard
     func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
     //Which view controller are we sending this to?
     let postScene = segue.destination as! WebViewController;
     
     //pass the selected JSON to the "viewPost variable of the WebViewController Class
     if let indexPath = self.tableView.indexPathForSelectedRow{
     let selected = self.json[indexPath.row]
     postScene.viewPost = selected
     }
     
     }
     */
    
    public class ImageLoader {
        
        var cache = NSCache<NSString, NSData>()
        
        public class var sharedLoader : ImageLoader {
            struct Static {
                static let instance : ImageLoader = ImageLoader()
            }
            return Static.instance
        }
        
        public func imageForUrl(urlString: String, completionHandler: @escaping(_ image: UIImage?, _ url: String) -> ()) {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                var data: NSData?
                
                if let dataCache = self.cache.object(forKey: urlString as NSString){
                    data = (dataCache) as NSData
                    
                }else{
                    if (URL(string: urlString) != nil)
                    {
                        data = NSData(contentsOf: URL(string: urlString)!)
                        if data != nil {
                            self.cache.setObject(data!, forKey: urlString as NSString)
                        }
                    }else{
                        return
                    }
                }
                
                if let goodData = data {
                    let image = UIImage(data: goodData as Data)
                    DispatchQueue.main.async(execute: {() in
                        completionHandler(image, urlString)
                    })
                    return
                }
                
                let downloadTask: URLSessionDataTask = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                    
                    if (error != nil) {
                        completionHandler(nil, urlString)
                        return
                    }
                    
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.cache.setObject(data! as NSData, forKey: urlString as NSString)
                        DispatchQueue.main.async(execute: {() in
                            completionHandler(image, urlString)
                        })
                        return
                    }
                })
                downloadTask.resume()
                
            }
            
        }
    }
}
