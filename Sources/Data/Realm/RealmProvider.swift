import Foundation
import RealmSwift

final class RealmProvider {

    private var _realm: Realm?

    func realm() -> Realm? {
        if self._realm == nil {
            self._realm = try? Realm()
        }

        return self._realm
    }
}
