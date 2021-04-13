//
//  VoiceChooseViewController.swift
//  hakaton_main
//
//  Created by Pavel Bibichenko on 27/10/2018.
//  Copyright © 2018 Pavel Bibichenko. All rights reserved.
//

import UIKit


class VoiceChooseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var characters = Characters()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
    }


    
}


extension VoiceChooseViewController: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.people.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let characterCell = self.tableView.dequeueReusableCell(withIdentifier: "characterCell") as! CharacterCell
        let character = characters.people[indexPath.row]
        
        
        if let name = character.name, let id = character.id, let imageLink = character.imageLink, let descr = character.descr {
            characterCell.nameLabel.text = name
            characterCell.characterId = id
            characterCell.characterImageView.image = UIImage(named: imageLink)
            characterCell.descrLabel.text = descr
        }
        
        
        return characterCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let selectedCell = tableView.cellForRow(at: indexPath!) as! CharacterCell?
        
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        
        let voiceRecordViewController = storyBoard.instantiateViewController(withIdentifier: "voiceRecordViewController") as! VoiceRecordViewController
        
        voiceRecordViewController.characterId = selectedCell?.characterId ?? 0
        
        self.present(voiceRecordViewController, animated:true, completion:nil)
    }
}
