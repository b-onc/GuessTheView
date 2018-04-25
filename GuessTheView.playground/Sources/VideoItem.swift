import Foundation
import UIKit

public class VideoItem {
    
    public let videoId: String
    public let title: String
    public let views: Int
    private(set) var thumbnailImage: UIImage?
    
    public var itemUsed = false
    
    public init(videoId: String, title: String, views: Int) {
        self.videoId = videoId
        self.title = title
        self.views = views
        if let imageURL = Bundle.main.url(forResource: videoId, withExtension: "png", subdirectory: "Thumbnails") {
            do {
                let imageData = try Data(contentsOf: imageURL)
                thumbnailImage = UIImage(data: imageData)
            } catch {
                print("Could not load image for title: \(title), id: \(videoId)")
            }
        } else {
            print("Can't locate image file for title: \(title), id: \(videoId)")
        }
    }

}
