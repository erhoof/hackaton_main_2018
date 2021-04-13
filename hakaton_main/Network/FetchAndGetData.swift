//
//  FetchAndGetData.swift
//  hakaton_main
//
//  Created by Pavel Bibichenko on 27/10/2018.
//  Copyright © 2018 Pavel Bibichenko. All rights reserved.
//

import Foundation
import UIKit



class Characters {
    var people = [Character]()
    
    func addCharacter (name: String, photo: String, descr: String) {
        let newOne = Character()
        newOne.name = name
        newOne.id = people.count
        newOne.imageLink = photo
        newOne.descr = descr
        people.append(newOne)
    }
    
    init() {
        addCharacter(name: "Трамп", photo: "Pic5", descr: "Мейк Америка Грейт Эгейн!")
        addCharacter(name: "Робот", photo: "Pic7", descr: "Роботизированное существо")
        addCharacter(name: "Кейт Винстон", photo: "Pic6", descr: "Актёр некоторых ролей")
        addCharacter(name: "Девушка", photo: "Pic4", descr: "Обычный человек.")
    }
}
