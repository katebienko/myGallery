import Foundation

class Post: Codable {
    var imageName: String
    var comment: [String]
    var description: String
    var like: Bool
    var commentDate: [String]
    var imageDate: String
    
    init(imageName: String, comment: [String], description: String, like: Bool, commentDate: [String], imageDate: String) {
        self.imageName = imageName
        self.comment = comment
        self.description = description
        self.like = like
        self.commentDate = commentDate
        self.imageDate = imageDate
    }
}
