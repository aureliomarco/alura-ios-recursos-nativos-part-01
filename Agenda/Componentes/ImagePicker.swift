//
//  ImagePicker.swift
//  Agenda
//
//  Created by Marco Aurelio on 20/04/20.
//  Copyright © 2020 Alura. All rights reserved.
//

import UIKit

enum MenuOpcoes {
    case camera
    case biblioteca
}

protocol ImagePickerFotoSelecionada {
    func imagePickerFotoSelecionada(_ foto: UIImage)
}

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Atributos
    var delegate: ImagePickerFotoSelecionada?
    
    // MARK: - Métodos
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // É necessário extrair a foto do dicionário info UIImagePickerControllerOriginalImage
        // Após é necessário converter para UIImage para ser usado na tela
        let foto = info[UIImagePickerControllerOriginalImage] as! UIImage
        delegate?.imagePickerFotoSelecionada(foto)
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Menu ActionSheet 💩💩💩💩💩
    func menuDeOpcoes(completion:@escaping(_ opcao: MenuOpcoes) -> Void) -> UIAlertController {
        let menu = UIAlertController(title: "Atenção", message: "Escolha uma das opções abaixo", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Tirar foto", style: .default) { (acao) in
            completion(.camera)
        }
        menu.addAction(camera)
        
        let biblioteca = UIAlertAction(title: "Biblioteca", style: .default) { (acao) in
            completion(.biblioteca)
        }
        menu.addAction(biblioteca)
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        menu.addAction(cancelar)
        
        return menu
    }
}
