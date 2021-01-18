//
//  ViewController.swift
//  Scotify
//
//  Created by Felipe Bastos on 11/01/21.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerViewController: UIViewController {
    
    var timer = Timer()
    var index: Int = 0
    var player: AVAudioPlayer!
    var isPlaying: Bool = false
    
    let controlCenter = MPRemoteCommandCenter.shared()
    
    var audios: Array<Audio> {
        get {
            let audio0 = Audio(url: Bundle.main.url(forResource: "Ocean", withExtension: "mp3")!,
                               cover: UIImage(named: "Ocean"),
                               title: "Ocean",
                               author: "Alok, Zeeba and IRO")
            
            let audio1 = Audio(url: Bundle.main.url(forResource: "Ilusão", withExtension: "mp3")!,
                               cover: UIImage(named: "Ilusão"),
                               title: "Ilusão (Cracolândia)",
                               author: " Alok, MC Hariel, MC Davi, MC Ryan SP, Salvador da Rima e Djay W (GR6 Explode)")
            
            return [audio0, audio1]
        }
    }
    
    @IBOutlet var lblCurrentTime: UILabel?
    @IBOutlet var sldTimeline: UISlider?
    @IBOutlet var lblDuration: UILabel?
    @IBOutlet var btnFoward: UIButton?
    @IBOutlet var btnBack: UIButton?
    @IBOutlet var btnControl: UIButton?
    @IBOutlet var imgCover: UIImageView?
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblAuthor: UILabel?
    
    //-----------------------------------------------------------------------
    //    MARK: UIViewController
    //-----------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configSong()
        
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
    //    MARK: Control Player
    //-----------------------------------------------------------------------
    
    @IBAction func play() {
        if player.isPlaying {
            timer.invalidate()
            btnControl?.setImage(UIImage(named: "Play"), for: .normal)
            player.pause()
        }else{
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            btnControl?.setImage(UIImage(named: "Pause"), for: .normal)
            player.play()
        }
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func stop() {
        player.stop()
        isPlaying = false
    }
    
    @IBAction func next() {
        if index < audios.count - 1 {
            index += 1
            
            configSong()
            self.stop()
            self.play()
        }
    }
    
    @IBAction func previous() {
        if index >= 1 {
            index -= 1
            
            configSong()
            self.stop()
            self.play()
        }
    }
    
    //-----------------------------------------------------------------------
    //    MARK: Custom methods
    //-----------------------------------------------------------------------
    
    func configUI() {
        self.view.applyGradient(colors: [UIColor(red: 0.10, green: 0.11, blue: 0.15, alpha: 1.00).cgColor,
                                         UIColor(red: 0.25, green: 0.55, blue: 0.51, alpha: 1.00).cgColor])
        
    }
    
    func loadUI() {}
    
    func configSong() {
        
        /// Configurar o layout da música que está tocando.
        
        imgCover?.image = audios[index].cover
        lblTitle?.text = audios[index].title
        lblAuthor?.text = audios[index].author
        
        /// Configurar o player.
        
        do {
            player = try AVAudioPlayer(contentsOf: audios[index].url)
            player.prepareToPlay()
            
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setCategory(AVAudioSession.Category.playback)
            }catch{
                
            }
            
        }catch{
            print(error)
        }
        
        /// Liberar ou não os botões de avançar / retroceder a música.
        // Config the UI
        
        if audios.count == index + 1 {
            btnFoward?.isEnabled = false
        }else{
            btnFoward?.isEnabled = true
        }
        
        if index == 0 {
            btnBack?.isEnabled = false
        }else{
            btnBack?.isEnabled = true
        }
        
        self.configControlCenter()
        self.setupNotificationView()
        
        lblDuration?.text = player.duration.stringFromTimeInterval()
        sldTimeline?.maximumValue = Float(player.duration)
        sldTimeline?.value = 0
    }
    
    @objc func updateTime(_ timer: Timer) {
        sldTimeline?.value = Float(player.currentTime)
        lblCurrentTime?.text = player.currentTime.stringFromTimeInterval()
        
        if Float(player.currentTime) == 0 {
            btnControl?.setImage(UIImage(named: "Play"), for: .normal)
        }
        
        if Float(player.currentTime) >= (sldTimeline?.maximumValue ?? 0) - 1 {
            self.next()
        }
    }
    
    @IBAction func slide(_ slider: UISlider) {
        player.currentTime = TimeInterval(slider.value)
        lblCurrentTime?.text = player.currentTime.stringFromTimeInterval()
        
        if Float(player.currentTime) == sldTimeline?.maximumValue {
            self.next()
        }
    }
    
    //-----------------------------------------------------------------------
    //    MARK: Control Center
    //-----------------------------------------------------------------------
    
    private func setupNotificationView() { /// Configurar na tela Bloqueada / Control Center as informações do que está tocando
        
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = audios[index].title
        nowPlayingInfo[MPMediaItemPropertyArtist] = audios[index].author
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Float(player.duration)
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: audios[index].cover?.size ?? CGSize.zero, requestHandler: { (size) -> UIImage in
            return self.audios[self.index].cover!
        })
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func configControlCenter() {

        /// Checar se o botão irá ficar disponível ou não (Dependendo da contagem / Índice do array)
        
        controlCenter.nextTrackCommand.isEnabled = audios.count > 1 && index < (audios.count - 1)
        controlCenter.previousTrackCommand.isEnabled = audios.count > 1 && index > 0
        
        controlCenter.playCommand.addTarget { [unowned self] event in /// Adicionar função ao botão de Play
            self.play()
            return self.isPlaying ? .success : .commandFailed
        }

        controlCenter.pauseCommand.addTarget { [unowned self] event in /// Adicionar função ao botão de Pause
            self.pause()
            return !self.isPlaying ? .success : .commandFailed
        }

        controlCenter.nextTrackCommand.addTarget { [unowned self] event in /// Adicionar função ao botão de Avançar
            self.next()
            return self.isPlaying ? .success : .commandFailed
        }

        controlCenter.previousTrackCommand.addTarget { [unowned self] event in /// Adicionar função ao botão de Retroceder
            self.previous()
            return self.isPlaying ? .success : .commandFailed
        }

        /// Receber o retorno do que o usuário selecionou no Control Center.
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}

