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

struct Contact: Hashable {
    let name: String
}

class ContactViewModel: ObservableObject {
    @Published var name = ""
}

struct ContactRowView: View {
    
    @ObservedObject var viewModel: ContactViewModel

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
            Text(viewModel.name)
            Spacer()
            Image(systemName: "star")
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
class DiffableTableViewContrller: UITableViewController {
    
    lazy var source: UITableViewDiffableDataSource<SectionType, Contact> =
        .init(tableView: self.tableView) { (_
            , indexPath, contact) -> UITableViewCell? in
//            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let cell = ContactCell(style: .default, reuseIdentifier: nil)
//            cell.textLabel?.text = contact.name
            cell.viewModel.name = contact.name
            return cell
    }
    
    private func setupSource(){
        var snapshot = source.snapshot()
        snapshot.appendSections([.CEO])
        snapshot.appendItems([
            .init(name: "Ali"),
            .init(name: "Farhad")], toSection: .CEO)
        snapshot.appendSections([.Peassants])
        snapshot.appendItems([.init(name: "Farshad")], toSection: .Peassants)
//        snapshot.appendItems([.init(name: "Farshad")], toSection: .Peassants)
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
        setupSource()
    }
}

struct DiffableContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<DiffableContainer>) -> UIViewController {
        UINavigationController(rootViewController: DiffableTableViewContrller(style: .insetGrouped))
//        DiffableTableViewContrller()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DiffableContainer>) {
    }
//    typealias UIViewControllerType = UIViewController

}

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiffableContainer()
    }
}
