//
//  ViewController.swift
//  HappyDays
//
//  Created by Thai Nguyen on 10/6/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var helpLabel: UILabel!
    
    @IBAction func requestPermission(_ sender: Any) {
        requestPhotosPermissions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func requestPhotosPermissions() {
        PHPhotoLibrary.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.requestRecordPermissions()
                } else {
                    self.helpLabel.text = "Photos permissions was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func requestRecordPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.requestTranscribePermissions()
                } else {
                    self.helpLabel.text = "Recording permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.authorizationComplete()
                } else {
                    self.helpLabel.text = "Transcription permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func authorizationComplete() {
        dismiss(animated: true)
    }


}

