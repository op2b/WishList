
import RealmSwift

class Wish: Object {
    @objc dynamic  var name: String = ""
    @objc dynamic  var location: String?
    @objc dynamic  var cost: String?
    @objc dynamic  var wishImageData: Data?
    @objc dynamic  var date = Date()
    @objc dynamic  var rating = 0.0
    
    convenience init(name: String, location: String?, cost: String?, image: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.cost = cost
        self.wishImageData = image
        self.rating = rating
        
    }
}

