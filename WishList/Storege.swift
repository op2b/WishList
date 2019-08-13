
import RealmSwift
//создаем объект типа реалм
let realm = try! Realm()


class StorageManager {
    static func saveObj(_ wish: Wish) {
        try! realm.write {
            realm.add(wish)
        }
    }
    static func deleteObject(_ wish: Wish) {
        try! realm.write {
            realm.delete(wish)
        }
    }
}
