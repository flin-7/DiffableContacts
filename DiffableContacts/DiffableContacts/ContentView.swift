//
//  ContentView.swift
//  DiffableContacts
//
//  Created by Felix Lin on 2/17/20.
//  Copyright © 2020 Felix Lin. All rights reserved.
//

import SwiftUI
import LBTATools

enum SectionType {
    case ceo, peasents
}

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
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34))
            Text(viewModel.name)
            Spacer()
            Image(systemName: viewModel.isFavorite ?  "star.fill" : "star")
                .font(.system(size: 24))
        }.padding(20)
    }
}

struct ContactFormView: View {
    @State private var name = ""
    @State private var sectionType = SectionType.ceo
    
    var didAddContact: (String, SectionType) -> () = { _, _ in }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $name)
            
            Picker(selection: $sectionType, label: Text("Doesn't metter")) {
                Text("CEO").tag(SectionType.ceo)
                Text("Peasants").tag(SectionType.peasents)
            }.pickerStyle(SegmentedPickerStyle())
            
            Button(action: {
                self.didAddContact(self.name, self.sectionType)
            }) {
                Spacer()
                Text("Add").foregroundColor(.white)
                Spacer()
            }.padding().background(Color.blue)
                .cornerRadius(5)
            
            Button(action: {
                
            }) {
                Spacer()
                Text("Cancel").foregroundColor(.white)
                Spacer()
            }.padding().background(Color.red)
                .cornerRadius(5)
            
            Spacer()
        }.padding()
    }
}

class ContactCell: UITableViewCell {
    let viewModel = ContactViewModel()
    lazy var row = ContactRowView(viewModel: viewModel)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let hostingController = UIHostingController(rootView: row)
        addSubview(hostingController.view)
        hostingController.view.fillSuperview()
        
        viewModel.name = "My Contact"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ContactsSource: UITableViewDiffableDataSource<SectionType, Contact> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

class DiffableTableViewController: UITableViewController {
    
    // UITableViewDiffableDataSource
    lazy var source: ContactsSource = .init(tableView: self.tableView) { (_, indexPath, contact) -> UITableViewCell? in
        let cell = ContactCell(style: .default, reuseIdentifier: nil)
        cell.viewModel.name = contact.name
        cell.viewModel.isFavorite = contact.isFavorite
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = .init(title: "Add Contact", style: .plain, target: self, action: #selector(handleAdd))
        setupSource()
    }
    
    @objc private func handleAdd() {
        let formView = ContactFormView { (name, sectionType) in
            self.dismiss(animated: true)
            var snapshot = self.source.snapshot()
            snapshot.appendItems([.init(name: name)], toSection: sectionType)
            self.source.apply(snapshot)
        }
        let hostingController = UIHostingController(rootView: formView)
        present(hostingController, animated: true)
    }
    
    private func setupSource() {
        var snapshot = source.snapshot()
        snapshot.appendSections([.ceo, .peasents])
        snapshot.appendItems([
            .init(name: "Elon Musk"),
            .init(name: "Tim Cook"),
            .init(name: "Bill Gates")
        ], toSection: .ceo)
        snapshot.appendItems([
            .init(name: "Felix")
        ], toSection: .peasents)
        source.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "CEO" : "Peasants"
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            completion(true)
            guard let self = self else { return }
            
            var snapshot = self.source.snapshot()
            guard let contact = self.source.itemIdentifier(for: indexPath) else { return }
            snapshot.deleteItems([contact])
            self.source.apply(snapshot)
        }
        
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] (_, _, completion) in
            completion(true)
            guard let self = self else { return }
            
            var snapshot = self.source.snapshot()
            guard let contact = self.source.itemIdentifier(for: indexPath) else { return }
            contact.isFavorite.toggle()
            snapshot.reloadItems([contact])
            self.source.apply(snapshot)
        }
        
        return .init(actions: [deleteAction, favoriteAction])
    }
}

struct ContactFormPreview: PreviewProvider {
    static var previews: some View {
        ContactFormView()
    }
}

struct DiffableContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<DiffableContainer>) -> UIViewController {
        UINavigationController(rootViewController: DiffableTableViewController(style: .insetGrouped))
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DiffableContainer>) {
        
    }
    
    typealias UIViewControllerType = UIViewController
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiffableContainer()
    }
}

struct ContentView: View {
    var body: some View {
        Text("123123")
    }
}
