//
//  VoiceListenViewController.swift
//  hakaton_main
//
//  Created by Pavel Bibichenko on 27/10/2018.
//  Copyright © 2018 Pavel Bibichenko. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceListenViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    public var audio = Data()
    var isPlaying = false
    var picName = ""
    
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var picView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picView.image = UIImage(named: picName)
    }

    @IBAction func playButtonClick(_ sender: Any) {
        if(isPlaying) {
            audioPlayer?.stop()
            playButton.setTitle("Проиграть", for: .normal)
            isPlaying = false
        } else {
            playButton.setTitle("Пауза", for: .normal)
            do {
                audioPlayer = try AVAudioPlayer(data: audio)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error")
            }
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
}
