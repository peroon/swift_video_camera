import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    private var myVideoOutput: AVCaptureMovieFileOutput!
    private var myButtonStart: UIButton!
    private var myButtonStop: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セッションの作成.
        let mySession = AVCaptureSession()
        
        // デバイス.
        let myDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        //let myDevice : AVCaptureDevice!
        
        // 出力先を生成.
        let myImageOutput = AVCapturePhotoOutput()
        
        // マイクを取得.
        let audioCaptureDevice = AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio)
        
        // マイクをセッションのInputに追加.
        let audioInput = try! AVCaptureDeviceInput.init(device: audioCaptureDevice?.first as! AVCaptureDevice)
        
        // バックライトをmyDeviceに格納.
//        for device in devices! {
//            if(device.position == AVCaptureDevicePosition.back){
//                myDevice = device as? AVCaptureDevice
//            }
//        }
 
        // バックカメラを取得.
        let videoInput = try! AVCaptureDeviceInput.init(device: myDevice)
        
        // ビデオをセッションのInputに追加.
        mySession.addInput(videoInput)
        
        // オーディオをセッションに追加.
        mySession.addInput(audioInput)
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 動画の保存.
        myVideoOutput = AVCaptureMovieFileOutput()
        
        // ビデオ出力をOutputに追加.
        mySession.addOutput(myVideoOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer = AVCaptureVideoPreviewLayer.init(session: mySession)
        myVideoLayer?.frame = self.view.bounds
        myVideoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer!)
        
        // セッション開始.
        mySession.startRunning()
        
        // UIボタンを作成.
        myButtonStart = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        myButtonStop = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        
        myButtonStart.backgroundColor = UIColor.red
        myButtonStop.backgroundColor = UIColor.gray
        
        myButtonStart.layer.masksToBounds = true
        myButtonStop.layer.masksToBounds = true
        
        myButtonStart.setTitle("撮影", for: .normal)
        myButtonStop.setTitle("停止", for: .normal)
        
        myButtonStart.layer.cornerRadius = 20.0
        myButtonStop.layer.cornerRadius = 20.0
        
        myButtonStart.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y:self.view.bounds.height-50)
        myButtonStop.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y:self.view.bounds.height-50)
        
        myButtonStart.addTarget(self, action: #selector(ViewController.onClickStartRecording), for: .touchUpInside)
        myButtonStop.addTarget(self, action: #selector(ViewController.onClickStopRecording), for: .touchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(myButtonStart)
        self.view.addSubview(myButtonStop)
    }
    
    func onClickStartRecording(){
        print("撮影開始")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "\(documentsDirectory)/test.mp4"
        let fileURL = URL(fileURLWithPath: filePath)
        myVideoOutput.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)
    }
    
    func onClickStopRecording(){
        print("撮影停止")
        myVideoOutput.stopRecording()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // レコード開始時
    private func capture(_ captureOutput: AVCaptureFileOutput!,
                         didStartRecordingToOutputFileAt fileURL: URL!,
                         fromConnections connections: [AnyObject]!) {
        print("レコード開始時")
    }

    // レコード終了時
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didFinishRecordingToOutputFileAt outputFileURL: URL!,
                 fromConnections connections: [Any]!,
                 error: Error!) {
        print("レコード終了時")
    }
}

