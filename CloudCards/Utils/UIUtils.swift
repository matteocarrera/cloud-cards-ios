import UIKit

/*
    Большой NavigationBar для контроллера
 */

public func setLargeNavigationBar(for controller: UIViewController) {
    controller.navigationController!.navigationBar.prefersLargeTitles = true
    controller.navigationController?.view.backgroundColor = UIColor(named: "NavigationBarColor")
    
    let appearance = UINavigationBarAppearance()
    appearance.backgroundColor = UIColor(named: "NavigationBarColor")
    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

    controller.navigationController!.navigationBar.compactAppearance = appearance
    controller.navigationController!.navigationBar.standardAppearance = appearance
    controller.navigationController!.navigationBar.scrollEdgeAppearance = appearance
}


/*
    Добавляет строку поиска в NavBar
    Используется только в ContactsController
 */

public func setSearchBar(for controller: UIViewController) {
    let search = UISearchController(searchResultsController: nil)
    search.searchBar.delegate = controller as? UISearchBarDelegate
    search.searchBar.placeholder = "Поиск"
    search.searchBar.setValue("Отмена", forKey: "cancelButtonText")
    search.dimsBackgroundDuringPresentation = false
    search.searchBar.scopeButtonTitles = ["Имя", "Фамилия", "Компания"]
    controller.definesPresentationContext = true
    controller.navigationItem.searchController = search
}

/*
    Нижний тулбар, появляется при множественном выборе визиток
    Используется только в ContactsController
 */

public func setToolbar(for controller: UIViewController) {
    guard let controller = controller as? ContactsController else {
        return
    }
    let trashButton = UIBarButtonItem(
        barButtonSystemItem: .trash,
        target: controller,
        action: #selector(controller.onDeleteContactsButtonTap(_:))
    )
    trashButton.tintColor = UIColor(named: "Primary")
    
    let space = UIBarButtonItem(
        barButtonSystemItem: .flexibleSpace,
        target: controller,
        action: nil
    )
    
    let shareButton = UIBarButtonItem(
        barButtonSystemItem: .action,
        target: controller,
        action: #selector(controller.onShareContactsButtonTap(_:))
    )
    shareButton.tintColor = UIColor(named: "Primary")
    
    controller.navigationController?.toolbar.setItems([trashButton, space, shareButton], animated: true)
    controller.navigationController?.toolbar.barTintColor = UIColor(named: "NavigationBarColor")
    controller.navigationController?.toolbar.isTranslucent = false
}
