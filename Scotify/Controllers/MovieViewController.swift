//
//  MovieViewController.swift
//  Scotify
//
//  Created by Felipe Bastos on 12/01/21.
//

import UIKit
import AVKit

class MovieViewController: UIViewController {
    
    var player: AVPlayer = AVPlayer()
    var isPlaying: Bool = false
    
    @IBOutlet var vwURLView: UIView?
    @IBOutlet var btnControlURL: UIButton?
    
    //-----------------------------------------------------------------------
    //    MARK: UIViewController
    //-----------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    //-----------------------------------------------------------------------
    //    MARK: Custom methods
    //-----------------------------------------------------------------------
    
    func configUI() {
        self.view.applyGradient(colors: [UIColor(red: 0.10, green: 0.11, blue: 0.15, alpha: 1.00).cgColor,
                                         UIColor(red: 0.31, green: 0.01, blue: 0.00, alpha: 1.00).cgColor])
    }
    
    func loadUI() {}
    
    @IBAction func playURLVideo() {
        
        if isPlaying {
            
            player.pause()
            btnControlURL?.setImage(UIImage(named: "Play"), for: .normal)
            isPlaying = false
        }else{
            
            let videoURL = URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.m3u8")
            player = AVPlayer(url: videoURL!)
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.vwURLView!.bounds
            
            self.vwURLView?.layer.addSublayer(playerLayer)
            
            self.player.play()
            
            btnControlURL?.setImage(UIImage(named: "Pause"), for: .normal)
            isPlaying = true
        }
    }
    
    @IBAction func volume(_ slider: UISlider) {
        player.volume = Float(slider.value)
    }
    
    @IBAction func openNativePlayer() {
        
        /// Rodar player com um arquivo local.
        
//        guard let path = Bundle.main.path(forResource: "Ocean", ofType:"mp4") else {
//            debugPrint("video.mp4 not found")
//            return
//        }
//
//        let player = AVPlayer(url: URL(fileURLWithPath: path))
    
        /// Rodar player com uma URL.
        
        let videoURL = URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.m3u8")
        player = AVPlayer(url: videoURL!)
        
        if isPlaying {
            self.player.pause()
            isPlaying = false
            btnControlURL?.setImage(UIImage(named: "Play"), for: .normal)
        }
    
        let playerController = AVPlayerViewController()
        playerController.player = player
    
        present(playerController, animated: true) {
            self.player.play()
        }
    }
}
