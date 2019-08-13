import RealmSwift
import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var wishes: Results<Wish>!
    private var ascendingSorted = true
    private var filtredWishes: Results<Wish>!
    private var searchBarisEmpty: Bool {
        guard let text  = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarisEmpty
    }

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reversedSortButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wishes = realm.objects(Wish.self)
        
        //производим настройку searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        

    }

    // MARK: - Table view data source
    //кол-во отображаемых секций в представлении
     func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    //кол-во строк в секции
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filtredWishes.count
        }
        //учитываем что в нашем хранилище нет данных
        return   wishes.isEmpty ? 0 : wishes.count
    }

    //конфигурация ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var wish  = Wish()
        
        if isFiltering {
            wish = filtredWishes[indexPath.row]
        } else  {
            wish = wishes[indexPath.row]
        }
        
        cell.nameLabel?.text = wish.name
        cell.locationLabel.text = wish.location
        cell.typeLabel.text = wish.cost
        cell.imageOfWish.image = UIImage(data: wish.wishImageData!)
        
        cell.cosmosView.rating = wish.rating

        return cell
    }
   
    //MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //удаление виша из записис
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let wish = wishes[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "delete", handler: {(_,_) in
            StorageManager.deleteObject(wish)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        return [deleteAction]
    }
    

    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let wish: Wish
            //передаем тот или иной роьхект в завимиости поиск или нет
            if isFiltering {
                wish = filtredWishes[indexPath.row]
            } else  {
                wish = wishes[indexPath.row]
            }
            
            let newWishVc = segue.destination as! NewWishTableViewController
            newWishVc.currentWish = wish
        }
    }
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorted.toggle()
        if ascendingSorted == true {
            reversedSortButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorted()
    }
    
    private func sorted() {
        if segmentedControll.selectedSegmentIndex == 0 {
            wishes = wishes.sorted(byKeyPath: "date", ascending: ascendingSorted)
        } else {
            wishes = wishes.sorted(byKeyPath: "cost", ascending: ascendingSorted)
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorted()
    }
    //объявим метод выхода
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newWishVC = segue.source as? NewWishTableViewController else {return}
        newWishVC.saveWish()
        
        tableView.reloadData()
    }
    

}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filtredSearchForText(searchController.searchBar.text!)
    }
    
    private func filtredSearchForText(_ searchText: String) {
        filtredWishes = wishes.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR cost CONTAINS[c] %@", searchText, searchText, searchText)
        tableView.reloadData()
    }
    
}
