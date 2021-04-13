//
//  VoiceRecordViewController.swift
//  hakaton_main
//
//  Created by Pavel Bibichenko on 27/10/2018.
//  Copyright © 2018 Pavel Bibichenko. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceRecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    public var characterId=0
    public var characters = Characters()
    
    @IBOutlet weak var characterName: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = characters.people[characterId].name {
            characterName.text = name
        }
        checkRecordPermission()
    }

    func checkRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.isMeteringEnabled = true
                audioRecorder?.prepareToRecord()
            }
            catch let error {
                debugPrint(error)
            }
        }
    }
    
    @IBAction func recordButtonClick(_ sender: Any) {
        if(isRecording) {
            finishAudioRecording(success: true)
            recordButton.setTitle("Запись", for: .normal)
            playButton.isEnabled = true
            sendButton.isEnabled = true
            isRecording = false
        } else {
            setupRecorder()
            audioRecorder?.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            recordButton.setTitle("Стоп", for: .normal)
            playButton.isEnabled = false
            sendButton.isEnabled = false
            isRecording = true
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        if audioRecorder?.isRecording ?? false {
            let min = Int((audioRecorder?.currentTime)! / 60)
            let sec = Int((audioRecorder?.currentTime.truncatingRemainder(dividingBy: 60))!)
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            timeLabel.text = totalTimeString
            audioRecorder?.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool) {
        if success {
            audioRecorder?.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
        }
    }
    
    func prepare_play() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error")
        }
    }

    
    @IBAction func listenButtonClick(_ sender: Any) {
        if(isPlaying) {
            audioPlayer?.stop()
            recordButton.isEnabled = true
            sendButton.isEnabled = true
            playButton.setTitle("Проиграть", for: .normal)
            isPlaying = false
        } else {
            if FileManager.default.fileExists(atPath: getFileUrl().path) {
                recordButton.isEnabled = false
                sendButton.isEnabled = false
                playButton.setTitle("Пауза", for: .normal)
                prepare_play()
                audioPlayer?.play()
                isPlaying = true
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishAudioRecording(success: false)
        }
        playButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
    func createPost() -> URLRequest {
        var audioData = Data()
        do {
            audioData = try Data(contentsOf: getFileUrl())
        } catch {
            
        }
        var r: URLRequest
        if (characterId == 0) {
            r  = URLRequest(url: URL(string: "http://94.130.19.98:5000/api/maga")!)
        } else if (characterId == 1) {
            r  = URLRequest(url: URL(string: "http://94.130.19.98:5000/api/upload")!)
        } else if (characterId == 2) {
            r  = URLRequest(url: URL(string: "http://94.130.19.98:5000/api/upload_kate")!)
        } else {
            r  = URLRequest(url: URL(string: "http://94.130.19.98:5000/api/upload_girl")!)
        }
        
        
        r.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        r.httpBody = createBody(parameters: ["type":String(characterId)],
                                boundary: boundary,
                                data: audioData,
                                mimeType: "audio/m4a",
                                filename: "audio.m4a")
        debugPrint(r.httpBody)
        return r
    }
    
    func sendPost (completionHandler: @escaping (Data) -> Void) -> String {
        debugPrint("Sending post...")
        var back = "";
        var request = createPost()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let decodedAudio = data, error == nil else {                                                 // check for fundamental networking error
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                debugPrint("POST Error \(httpStatus.statusCode)")
            }
            
            
            //completionHandler(data2)

            DispatchQueue.main.async {
                debugPrint("recieved data: ", decodedAudio)
                self.warningText.isHidden = true
                self.activityIndicator.isHidden = true
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let voiceListenViewController = storyBoard.instantiateViewController(withIdentifier: "voiceListenViewController") as! VoiceListenViewController
                
                voiceListenViewController.audio = decodedAudio
                voiceListenViewController.picName = self.characters.people[self.characterId].imageLink!
                
                self.present(voiceListenViewController, animated:true, completion:nil)
            }

            
            
        }
        task.resume()
        return back
    }
    
    @IBAction func sendButtonClick(_ sender: Any) {
        var decodedAudio: Data = Data()
        
        warningText.isHidden = false
        activityIndicator.isHidden = false
        sendButton.isEnabled = false
        playButton.isEnabled = false
        recordButton.isEnabled = false
        sendPost()
        {(completionHandler:Data) in
            decodedAudio = completionHandler
            debugPrint("temp:", completionHandler)
        }

        
    }
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
