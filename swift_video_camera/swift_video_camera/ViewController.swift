import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    var myVideoOutput: AVCaptureMovieFileOutput!
    var myButtonStart: UIButton!
    var myButtonStop: UIButton!
    
    override func viewDidLoad() {
        print("初期化")
        super.viewDidLoad()
        
        let videoCaptureSession = AVCaptureSession()
        
        let myDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        do{
            let audioInput = try AVCaptureDeviceInput(device: audioDevice) as AVCaptureInput
            let videoInput = try! AVCaptureDeviceInput.init(device: myDevice)
            myVideoOutput = AVCaptureMovieFileOutput()
            
            // 毎フレームで処理するための設定
            let frameOutput = AVCaptureVideoDataOutput()
            //let dctPixelFormatType : Dictionary = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
//            frameOutput.videoSettings = dctPixelFormatType
            frameOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            frameOutput.alwaysDiscardsLateVideoFrames = true
            // フレーム入出力
            
            videoCaptureSession.addInput(videoInput)
            videoCaptureSession.addInput(audioInput)
            videoCaptureSession.addOutput(myVideoOutput)
            
            // video view layer
            let videoLayer = AVCaptureVideoPreviewLayer.init(session: videoCaptureSession)
            videoLayer?.frame = self.view.bounds
            videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.view.layer.addSublayer(videoLayer!)

            videoCaptureSession.startRunning()
            
            self.addUI()
            self.addArtFrame()
        }catch{
            print(error)
        }
    }
    
    func addUI(){
        // board
        let W = self.view.frame.size.width
        let H = self.view.frame.size.height
        let uiHeight = H / 8
        
        // position
        let upperPosition = CGRect(x:0, y:H - uiHeight, width:W, height:uiHeight)
        let bottomPosition = CGRect(x:0, y:0, width:W, height:uiHeight)
        
        let bgColor = UIColor.black
        
        let upperBoard = UIView(frame: upperPosition)
        let bottomBoard = UIView(frame: bottomPosition)
        
        upperBoard.backgroundColor = bgColor
        bottomBoard.backgroundColor = bgColor
        
        upperBoard.alpha = 0.25
        bottomBoard.alpha = 0.25
        
        self.view.addSubview(upperBoard)
        self.view.addSubview(bottomBoard)
        
        // add rec buttons
        myButtonStart = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        myButtonStop = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        
        myButtonStart.layer.masksToBounds = true
        myButtonStop.layer.masksToBounds = true
        
        notRecordingView()
        
        myButtonStart.layer.cornerRadius = 20.0
        myButtonStop.layer.cornerRadius = 20.0
        
        myButtonStart.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y:self.view.bounds.height - uiHeight / 2)
        myButtonStop.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y:self.view.bounds.height - uiHeight / 2)
        
        myButtonStart.addTarget(self, action: #selector(ViewController.onClickStartRecording), for: .touchUpInside)
        myButtonStop.addTarget(self, action: #selector(ViewController.onClickStopRecording), for: .touchUpInside)
        
        self.view.addSubview(myButtonStart)
        self.view.addSubview(myButtonStop)
    }
    
    // 録画中の表示
    func recordingView(){
        myButtonStart.backgroundColor = UIColor.gray
        myButtonStop.backgroundColor = UIColor.red
        
        myButtonStart.setTitle("撮影", for: .normal)
        myButtonStop.setTitle("停止", for: .normal)
        
        myButtonStart.isEnabled = false
        myButtonStop.isEnabled = true
    }
    
    // 撮影中以外の表示
    func notRecordingView(){
        myButtonStart.backgroundColor = UIColor.red
        myButtonStop.backgroundColor = UIColor.gray
        
        myButtonStart.setTitle("撮影", for: .normal)
        myButtonStop.setTitle("停止", for: .normal)

        myButtonStart.isEnabled = true
        myButtonStop.isEnabled = false
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
    
    func onClickStartRecording(){
        print("撮影開始 押下")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "\(documentsDirectory)/test.mp4"
        let saveURL = URL(fileURLWithPath: filePath)
        myVideoOutput.startRecording(toOutputFileURL: saveURL, recordingDelegate: self)
        recordingView()
    }
    
    func onClickStopRecording(){
        print("撮影停止 押下")
        myVideoOutput.stopRecording()
        notRecordingView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // レコード開始時
    // TODO 使われるようにする
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didStartRecordingToOutputFileAt fileURL: URL!,
                 fromConnections connections: [AnyObject]!) {
        print("レコード開始時 capture")
    }
    
    // 毎フレームの画像処理
    // TODO 使われるようにする
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        print("every")
    }
    
    // レコード終了時
    // 呼ばれてる
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didFinishRecordingToOutputFileAt outputFileURL: URL!,
                 fromConnections connections: [Any]!,
                 error: Error!) {
        print("レコード終了時 capture")

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

