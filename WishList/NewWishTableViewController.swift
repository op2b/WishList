
import UIKit
import Cosmos

class NewWishTableViewController: UITableViewController, UIImagePickerControllerDelegate {
    
    
    var imageIsChoose: Bool = false
    var currentRating = 0.0

    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var raitingControll: RaitingControll!
    @IBOutlet weak var wishImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var wishName: UITextField!
    @IBOutlet weak var wishLocation: UITextField!
    @IBOutlet weak var wishCost: UITextField!
    var currentWish: Wish!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //избавляемся от ненужной раскадровки
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        //кнопка сохранить отк по дефолту
        saveButton.isEnabled = false
        wishName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEdingScreen()
        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }

    //MARK: TabelViewDelegate(метод для сокрытия клавы)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //если ясейка 0 вызываем меню (choose image)если нет скрываем клавиатуру
        if indexPath.row == 0 {
            
            let camerItem  = #imageLiteral(resourceName: "camera")
            let photoItem = #imageLiteral(resourceName: "phoneImage")
            
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera  = UIAlertAction(title: "Camera", style: .default) { _ in
                self.choseImagePicker(source: .camera)
            }
            camera.setValue(camerItem, forKey: "image")
            //смещаем текст камеры вправо к иконке
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default, handler: { _ in
                self.choseImagePicker(source: .photoLibrary)
                })
            photo.setValue(photoItem, forKey: "image")
            //смещаем текст фотоТелефона вправо к иконке
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
          
            alertController.addAction(camera)
            alertController.addAction(photo)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
            
            
        } else {
            view.endEditing(true)
        }
    }
    
    
    //MARK: Navigtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifire = segue.identifier,
            let mapVC = segue.destination as? MapViewController else {return}
            mapVC.incomSegueID = identifire
            mapVC.mapViewControllerDelegate = self
        
        if identifire == "showMap" {
            mapVC.wish.name = wishName.text!
            mapVC.wish.location = wishLocation.text!
            mapVC.wish.cost = wishCost.text!
            mapVC.wish.wishImageData = wishImage.image?.pngData()

        }
    }
    
    //реаализация метода сохранения виша
    func saveWish () {
       
        let image : UIImage?
        
        if imageIsChoose == true {
            image = wishImage.image
        } else {
            image = #imageLiteral(resourceName: "metalGear")
        }
        
        let imageData = image?.pngData()
        let newWIsh = Wish(name: wishName.text!, location: wishLocation.text, cost: wishCost.text, image: imageData, rating: currentRating)
        
        if currentWish != nil {
            try! realm.write {
                currentWish?.name = newWIsh.name
                currentWish?.location = newWIsh.location
                currentWish?.cost = newWIsh.cost
                currentWish?.wishImageData = newWIsh.wishImageData
                currentWish?.rating = newWIsh.rating
            }
        } else {
            StorageManager.saveObj(newWIsh)
        }
      
 
    }
    
    private func setupEdingScreen() {
        
        if currentWish != nil {
            
            setupNavogationBar()
            imageIsChoose = true
            guard let data = currentWish?.wishImageData, let image = UIImage(data: data) else {return}
            wishImage.image = image
            wishImage.contentMode = .scaleAspectFill
            wishName.text = currentWish?.name
            wishLocation.text = currentWish?.location
            wishCost.text = currentWish?.cost
            cosmosView.rating = currentWish.rating
        }
    }
    //меняем название открываем кнопку сейв для идита вишов
    private func setupNavogationBar () {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItems = nil
        title = currentWish?.name
        saveButton.isEnabled  = true
    }
   

  
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

    //MARK: Textfield delegate (для клавиатуры)

extension NewWishTableViewController: UITextFieldDelegate, UINavigationControllerDelegate{
    //Скрываем клавуатуру по кнопки
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //функция для скрыва/появления кнопки save
    @objc private func textFieldChanged() {
        if wishName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

    //MARK: Work with image (работа с изображением)

extension NewWishTableViewController {
    func choseImagePicker(source: UIImagePickerController.SourceType){
        //доступность источника выбора изображения
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            //позвлиь пользователю масштбаировать изображние
            imagePicker.allowsEditing = true
            //тип источника для изображения
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //позволяет использовать изоброжения отред.юзер
        wishImage.image = info[.editedImage] as? UIImage
        //масштабируем изображение по UIImage
        wishImage.contentMode = .scaleAspectFill
        //обрезаем по границы
        wishImage.clipsToBounds = true
        //не меняем фоновую картинку
        imageIsChoose = true
        dismiss(animated: true, completion: nil)
        
    }
    
}
extension NewWishTableViewController: MapViewControllerDelegate {
    
    func getAdress(_ adress: String?) {
        wishLocation.text = adress
    }
    
    
}
