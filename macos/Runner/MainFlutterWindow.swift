import Cocoa
import FlutterMacOS
import IOKit.ps
import AVFoundation

class MainFlutterWindow: NSWindow {
  
  var captureSession: AVCaptureSession?
  var photoOutput: AVCapturePhotoOutput?
  var captureResult: FlutterResult?
    
    
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
      
    let macosCameraChannel = FlutterMethodChannel(
      name: "macos_camera",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
      
    macosCameraChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "initializeCamera":
          self.initializeCamera()
          result(nil)
      case "disposeCamera":
          self.disposeCamera()
          result(nil)
      case "captureImage":
        self.captureResult = result
        self.captureImage()
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }

    func requestPermission(completionHandler: @escaping (Bool) -> Void) {
          if #available(macOS 10.14, *) {
              AVCaptureDevice.requestAccess(for: .video, completionHandler: completionHandler)
          } else {
              completionHandler(false)
          }
      }
    
  func initializeCamera() {
      self.requestPermission { granted in
          if granted {
              self.captureSession = AVCaptureSession()
              guard let captureSession =  self.captureSession else { return }
              
          guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
              guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
              
          
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
          
              self.photoOutput = AVCapturePhotoOutput()
              if let photoOutput =  self.photoOutput, captureSession.canAddOutput(photoOutput) {
                     captureSession.addOutput(photoOutput)
                 }
              captureSession.startRunning()
          }
      }
          
  
  }

    func disposeCamera() {
        
        self.captureSession?.stopRunning()
        self.captureSession?.inputs.forEach { captureSession?.removeInput($0) }
        self.captureSession?.outputs.forEach { captureSession?.removeOutput($0) }
        

        self.photoOutput = nil
        self.captureSession = nil
    }
    func captureImage() {
        self.requestPermission { granted in
            if granted {
                guard let photoOutput =  self.photoOutput else {
                    self.captureResult?(FlutterError(code: "NO_CAMERA", message: "Camera not initialized", details: nil))
                  return
                }
                
                let photoSettings = AVCapturePhotoSettings()
                photoOutput.capturePhoto(with: photoSettings, delegate: self)
                
                // The result will be handled in the delegate method
            }
        }
        
      }
}

extension MainFlutterWindow: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
       if let error = error {
         print("Error capturing photo: \(error)")
         captureResult?(FlutterError(code: "CAPTURE_ERROR", message: error.localizedDescription, details: nil))
         return
       }
       
       guard let photoData = photo.fileDataRepresentation() else {
         captureResult?(FlutterError(code: "CAPTURE_ERROR", message: "Failed to get photo data", details: nil))
         return
       }
       
       // Convert the photo data to a base64 string to send it back to Flutter
       let base64String = photoData.base64EncodedString()
       
       // Pass the base64 string back to Flutter
       captureResult?(base64String)
     }
}
