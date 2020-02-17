//
//  ContentView.swift
//  DiffableContacts
//
//  Created by Felix Lin on 2/17/20.
//  Copyright © 2020 Felix Lin. All rights reserved.
//

import SwiftUI

enum SectionType {
    case ceo, peasents
}

struct Contact: Hashable {
    let name: String
}

class DiffableTableViewController: UITableViewController {
    
    // UITableViewDiffableDataSource
    lazy var source: UITableViewDiffableDataSource<SectionType, Contact> = .init(tableView: self.tableView) { (_, indexPath, contact) -> UITableViewCell? in
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = contact.name
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupSource()
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
