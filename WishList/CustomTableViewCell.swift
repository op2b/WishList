
import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageOfWish: UIImageView! {
        didSet {
            //округление картинок
            imageOfWish?.layer.cornerRadius = imageOfWish.frame.size.height/2
            //обрезание по границам имиджВБю изображение
            imageOfWish?.clipsToBounds = true
        }
    }
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}
