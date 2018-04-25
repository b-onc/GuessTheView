import Foundation

public class Parser {
    
    public static func parsePage(page: URL) -> [VideoItem] {
        var videoItems = [VideoItem]()
        do {
            let data = try Data(contentsOf: page)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
                if let items = json["items"] as? [[String : Any]] {
                    for item in items {
                        let videoItem = VideoItem(videoId: item["id"] as! String, title: item["title"] as! String, views: Int(item["view_count"] as! String)!)
                        videoItems.append(videoItem)
                    }
                }
            }
        } catch {
            print("Error occured while parsing \(page): \(error.localizedDescription)")
        }
        return videoItems
    }
    
}

