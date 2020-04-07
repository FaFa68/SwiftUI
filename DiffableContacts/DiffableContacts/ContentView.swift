//
//  ContentView.swift
//  DiffableContacts
//
//  Created by Farshad Faradji on 31.03.20.
//  Copyright © 2020 Farshad Faradji. All rights reserved.
//

import SwiftUI
import LBTATools

enum SectionType {
    case CEO
    case Peassants
}
// This changed to class, object type of contact.
// related fo favorite action
//struct Contact: Hashable {
//    let name: String
//    var isFavorite = false
//}

class Contact: NSObject {
    let name: String
    var isFavorite = false
    
    init(name: String) {
        self.name = name
    }
}
class ContactViewModel: ObservableObject {
    @Published var name = ""
    @Published var isFavorite = false
}

struct ContactRowView: View {
    
    @ObservedObject var viewModel: ContactViewModel

    var body: some View {
        HStack (spacing: 15){
            Image(systemName: "person.fill")
                .font(.system(size: 34))
            Text(viewModel.name)
            Spacer()
            Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                .font(.system(size: 20))
        }.padding(20)
    }
}

class ContactCell: UITableViewCell {
    
    let viewModel = ContactViewModel()
    lazy var row = ContactRowView(viewModel: viewModel)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //Setup SwifUI View
        let hostingController = UIHostingController(rootView: row)
        addSubview(hostingController.view)
        hostingController.view.fillSuperview()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ContactsSource: UITableViewDiffableDataSource<SectionType, Contact> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
}
class DiffableTableViewContrller: UITableViewController {
    
    lazy var source: ContactsSource =
        .init(tableView: self.tableView) { (_
            , indexPath, contact) -> UITableViewCell? in
//            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let cell = ContactCell(style: .default, reuseIdentifier: nil)
//            cell.textLabel?.text = contact.name
            cell.viewModel.name = contact.name
            cell.viewModel.isFavorite = contact.isFavorite
            return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
            var snapshot =  self.source.snapshot()
            guard let contact = self.source.itemIdentifier(for: indexPath)
                else { return }
            snapshot.deleteItems([contact])
            self.source.apply(snapshot)
        }
        
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { (_, _, completion) in
            completion(true)
            var snapshot = self.source.snapshot()
            guard let contact = self.source.itemIdentifier(for: indexPath)  else { return }
            contact.isFavorite.toggle()
            snapshot.reloadItems([contact])
            self.source.apply(snapshot)
        }

        
        return .init(actions: [deleteAction, favoriteAction])
    }
    
    private func setupSource(){
        var snapshot = source.snapshot()
        snapshot.appendSections([.CEO])
        snapshot.appendItems([
            .init(name: "Ali"),
            .init(name: "Farhad")], toSection: .CEO)
        snapshot.appendSections([.Peassants])
        snapshot.appendItems([.init(name: "Farshad")], toSection: .Peassants)
        source.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text =  section == 0 ? "CEO" : "Peasant"
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = .init(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
        
        setupSource()
    }
    
    @objc private func handleAdd() {
        
        let formView = ContactFormView { (name, sectionType)  in
            self.dismiss(animated: true)
            var snapshot = self.source.snapshot()
            snapshot.appendItems([.init(name: name)], toSection: sectionType)
            self.source.apply(snapshot)
        }
        let hostingControler = UIHostingController(rootView: formView)
        present(hostingControler, animated: true)
    }
}

struct DiffableContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<DiffableContainer>) -> UIViewController {
        UINavigationController(rootViewController: DiffableTableViewContrller(style: .insetGrouped))
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DiffableContainer>) {
    }

}

struct ContactFormView: View {
    
    var didAddContact: (String, SectionType) -> () = { _,_ in }
    @State private var name = ""
    @State private var sectionType = SectionType.CEO
    
    var body: some View {
        VStack (spacing: 20){
            TextField("Name", text: $name)
            Picker(selection: $sectionType, label: Text("DOES NOT MATTER")) {
                Text("CEO").tag(SectionType.CEO)
                Text("Peassants").tag(SectionType.Peassants)
            }.pickerStyle(SegmentedPickerStyle())
            Button(action: {
                self.didAddContact(self.name, self.sectionType)
            }, label: {
                HStack{
                    Spacer()
                    Text("Add").foregroundColor(Color.white)
                    Spacer()
                    }
            }).padding().background(Color.blue).cornerRadius(5)
            Spacer()
        }.padding()
    }
}

struct ContentView: View {
    var body: some View {
        DiffableContainer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        DiffableContainer()
        ContentView()
    }
}
