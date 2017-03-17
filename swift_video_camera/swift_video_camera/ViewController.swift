import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    var myVideoOutput: AVCaptureMovieFileOutput!
    var myButtonStart: UIButton!
    var myButtonStop: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        // デバイス.
        let myDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        //let myDevice : AVCaptureDevice!
        
//        let audioCaptureDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio)
//        let audioInput = try! AVCaptureDeviceInput.init(device: audioCaptureDevices?.first as! AVCaptureDevice)

        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        //var audioInput:AVCaptureInput
        do{
            let audioInput = try AVCaptureDeviceInput(device: audioDevice) as AVCaptureInput
            // バックライトをmyDeviceに格納.
            //        for device in devices! {
            //            if(device.position == AVCaptureDevicePosition.back){
            //                myDevice = device as? AVCaptureDevice
            //            }
            //        }
            
            // バックカメラを取得.
            let videoInput = try! AVCaptureDeviceInput.init(device: myDevice)
            
            //let myImageOutput = AVCapturePhotoOutput()
            myVideoOutput = AVCaptureMovieFileOutput()
            
            captureSession.addInput(videoInput)
            captureSession.addInput(audioInput)
            //captureSession.addOutput(myImageOutput)
            captureSession.addOutput(myVideoOutput)
            
            // 画像を表示するレイヤーを生成.
            let myVideoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
            myVideoLayer?.frame = self.view.bounds
            myVideoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            // Viewに追加.
            self.view.layer.addSublayer(myVideoLayer!)
            
            // セッション開始.
            captureSession.startRunning()
            
            self.addArtFrame()
            self.addButtons()

        }catch{
            print(error)
        }
    }
    
    func addArtFrame(){
        let image:UIImage = UIImage(named:"mona_lisa_frame.png")!
        let imageView = UIImageView(image:image)
        
        // size
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        // position
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        
        // add
        self.view.addSubview(imageView)
    }
    
    func addButtons(){
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
        let saveURL = URL(fileURLWithPath: filePath)
        myVideoOutput.startRecording(toOutputFileURL: saveURL,
                                     recordingDelegate: self)
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
    // TODO 使われるようにする
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

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                print(error)
            }
        }
    }
}

