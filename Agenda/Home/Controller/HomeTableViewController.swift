//
//  HomeTableViewController.swift
//  Agenda
//
//  Created by Ândriu Coelho on 24/11/17.
//  Copyright © 2017 Alura. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: - Variáveis
    var contexto: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    let searchController = UISearchController(searchResultsController: nil)
    var gerenciadorDeResultados: NSFetchedResultsController<Aluno>?
    var alunoViewController: AlunoViewController?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuraSearch()
        recuperaAluno()
    }
    
    // MARK: - Métodos
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editar" {
            alunoViewController = segue.destination as? AlunoViewController
        }
    }
    
    func configuraSearch() {
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            self.navigationItem.titleView = searchController.searchBar
        }
    }
    
    func recuperaAluno() {
        let pesquisaAluno: NSFetchRequest<Aluno> = Aluno.fetchRequest()
        // NSSortDescriptor classe para realizar a ordenação
        // key: "nome" é o atribuito do model que se deseja realizar a ordenação
        let ordenaPorNome = NSSortDescriptor(key: "nome", ascending: true)
        pesquisaAluno.sortDescriptors = [ordenaPorNome]
        
        gerenciadorDeResultados = NSFetchedResultsController(fetchRequest: pesquisaAluno, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        gerenciadorDeResultados?.delegate = self
        
        do {
            try gerenciadorDeResultados?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func abrirActionSheet(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            let menu = MenuOpcoesAlunos().configuraMenuDeOpcoesDoAluno { (opcao) in
                switch opcao {
                case .sms:
                    print("SMS")
                }
            }
            
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let contadorListaDeAlunos = gerenciadorDeResultados?.fetchedObjects?.count else { return 0 }
        return contadorListaDeAlunos
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula-aluno", for: indexPath) as! HomeTableViewCell
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(abrirActionSheet(_:)))
        
        guard let aluno = gerenciadorDeResultados?.fetchedObjects?[indexPath.row] else { return cell }
        cell.configuraCelula(aluno)
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let alunoSelecionado = gerenciadorDeResultados?.fetchedObjects?[indexPath.row] else { return }
            contexto.delete(alunoSelecionado)
            
            do {
                try contexto.save()
            } catch {
                print(error.localizedDescription)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let alunoSelecionado = gerenciadorDeResultados?.fetchedObjects?[indexPath.row] else { return }
        alunoViewController?.aluno = alunoSelecionado
    }
    
    // MARK: - Fetched Results Controller Delegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
            break
        default:
            tableView.reloadData()
        }
    }
    
}
