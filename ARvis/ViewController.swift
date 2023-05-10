//  Scene.swift
//  ARvis
//  Created by Nikhil, Ayush.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit
import Alamofire
import Vision
import SceneKit
import ARKit
import Foundation
import XCDYouTubeKit
import SpriteKit
import SwiftyJSON


class ViewController: UIViewController, ARSessionDelegate{
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    private lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    private var movieFrame: ARFrame?
    private var isVideoOn = false
    private var movieName = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blankViewController = BlankViewController()
        // Add the blank view controller's view as a subview to the current view controller's view
        addChildViewController(blankViewController)
        view.addSubview(blankViewController.view)
        blankViewController.didMove(toParentViewController: self)


    }
    
     func setupOverlayScene() {
         super.viewDidLoad()
         print("HELLO")
        let overlayScene = SKScene(size: view.bounds.size)
        sceneView.overlaySKScene = overlayScene
        sceneView.delegate = self
        sceneView.session.delegate = self
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartSession()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        self.currentBuffer = frame.capturedImage
        processCapturedImage()
    }
    private var currentBuffer: CVPixelBuffer?
    private let visionQueue = DispatchQueue(label: "com.example.apple-samplecode.ARKitVision.serialVisionQueue")
    private func processCapturedImage() {
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
        visionQueue.async {
            defer { self.currentBuffer = nil }
            self.recognizePosterImage(cvPixelBuffer: self.currentBuffer!)
        }
    }
 
    func toggleGoogleReverseImageSearch(cameraImage: Data, apiKey: String, completion: @escaping (String?) -> Void) {
        let baseURL = "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
        let base64EncodedImage = cameraImage.base64EncodedString()
        let jsonRequestData = """
            {
                "requests": [
                    {
                        "image": {
                            "content": "\(base64EncodedImage)"
                        },
                        "features": [
                            {
                                "type": "WEB_DETECTION",
                                "maxResults": 5
                            }
                        ]
                    }
                ]
            }
            """
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonRequestData.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("Error: No data returned from Google Vision API")
                completion(nil)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let responses = json["responses"] as! [[String: Any]]
                let webDetection = responses[0]["webDetection"] as? [String: Any]
                let webEntities = webDetection?["webEntities"] as? [[String: Any]]
                print(webEntities)
                if let webEntities = webEntities {
                    var webEntityDescriptions: [String] = []
                    for (index, entity) in webEntities.enumerated() {
                        if let description = entity["description"] as? String {
                            webEntityDescriptions.append(description)
                            if index == 2 { // Only get first, second and third web entities
                                break
                            }
                        }
                    }
                    if webEntityDescriptions.isEmpty == false {
                        completion(webEntityDescriptions.joined(separator: " "))
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
                
            } catch let error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
        }
        task.resume()
    }
    
    private func recognizePosterImage(cvPixelBuffer: CVPixelBuffer) {
        var ciImage = CIImage(cvPixelBuffer: self.currentBuffer!)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let image = UIImage(cgImage: cgImage!)
        guard let cameraImage = UIImageJPEGRepresentation(image, 1) else {
            dismiss(animated: true, completion: nil)
            return
        }
        var firstEntity = ""
        let googleVisionAPIKey = readKey(key: "GoogleVisionCloudAPI")
        if (!isVideoOn) {
            
            toggleGoogleReverseImageSearch(cameraImage: cameraImage, apiKey: googleVisionAPIKey) { [self] entity in
                if let entity = entity {
                    firstEntity = entity
                } else {
                    print("No entity detected.")
                }
                movieName = firstEntity
                createVideoAnchor()
                isVideoOn = true
                do{
                    sleep(120)
                }
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
            setOverlaysHidden(false)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        setOverlaysHidden(true)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    private func setOverlaysHidden(_ shouldHide: Bool) {
        sceneView.scene.rootNode.childNodes.forEach { node in
            if shouldHide {
                node.isHidden = true
            } else {
                node.isHidden = false
            }
        }
    }
    
    private func restartSession() {
        statusViewController.cancelAllScheduledMessages()
        statusViewController.showMessage("RESTARTING SESSION")
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Error handling
    
    private func displayErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.restartSession()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func createVideoAnchor() {
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            if (!isVideoOn){
                self.movieFrame = currentFrame
            }
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1.5
            let transform = matrix_multiply((movieFrame?.camera.transform)!, translation)
            
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}


extension ViewController: BlankViewControllerDelegate {
    func blankViewControllerDidDismiss() {
        setupOverlayScene()
    }
}

protocol BlankViewControllerDelegate: AnyObject {
    func blankViewControllerDidDismiss()
}

extension ViewController: ARSCNViewDelegate {
    
    func fetchMovieID(extractedString: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
        let imdbAPIKey = readKey(key: "ImdbAPIKey")
        let urlString = "https://imdb-api.com/en/API/SearchMovie/\(imdbAPIKey)/"+extractedString
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil // disable cache
        
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completionHandler(.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(.failure(NSError(domain: "Missing data", code: 0, userInfo: nil)))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let id = firstResult["id"] as? String {
                    completionHandler(.success(id))
                } else {
                    // Handle invalid JSON
                    completionHandler(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
                }
            } catch let error {
                // Handle JSON parsing error
                completionHandler(.failure(error))
            }
        }
        task.resume()
    }
    
    
    func fetchMovieDetails(movieID: String, completionHandler: @escaping (Result<(title: String, year: String, directors: String, stars: [(name: String, id: String)], imDbRating: String, genres:String, plot:String, worldWideCollection:String), Error>) -> Void) {
        let imdbAPIKey = readKey(key: "ImdbAPIKey")
        let urlString = "https://imdb-api.com/en/API/Title/\(imdbAPIKey)/\(movieID)/FullActor,Ratings,"
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil // disable cache
        
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completionHandler(.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(.failure(NSError(domain: "Missing data", code: 0, userInfo: nil)))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let title = json["title"] as? String,
                   let year = json["year"] as? String,
                   let directors = json["directors"] as? String,
                   let starList = json["starList"] as? [[String: Any]] {
                    let imDbRating = json["imDbRating"] as? String ?? ""
                    let genres = json["genres"] as? String ?? ""
                    let plot = json["languages"] as? String ?? ""
                    let boxOffice = json["boxOffice"] as? [String: Any]
                    let worldWideCollection = boxOffice?["cumulativeWorldwideGross"] as? String ?? ""
                    var stars: [(name: String, id: String)] = []
                    for star in starList.prefix(2) {
                        if let name = star["name"] as? String, let id = star["id"] as? String {
                            stars.append((name: name, id: id))
                        }
                    }
                    
                    completionHandler(.success((title: title, year: year, directors: directors, stars: stars, imDbRating: imDbRating, genres:genres, plot:plot, worldWideCollection:worldWideCollection)))
                } else {
                    completionHandler(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
                }
            } catch let error {
                completionHandler(.failure(error))
            }
        }
        task.resume()
    }
    
    
    func extractStringBeforeTrailer(string: String) -> String {
        let delimiter1 = "trailer"
        let delimiter2 = "official"
        let stringLowercased = string.lowercased().replacingOccurrences(of: "new", with: "")
        if let range1 = stringLowercased.range(of: delimiter1.lowercased()), let range2 = stringLowercased.range(of: delimiter2.lowercased()) {
            let index1 = range1.lowerBound
            let index2 = range2.lowerBound
            let extractedString = String(string[..<min(index1, index2)]).trimmingCharacters(in: .whitespacesAndNewlines)
            let allowedCharacterSet = CharacterSet.alphanumerics
            let cleanedString = extractedString.components(separatedBy: allowedCharacterSet.inverted).joined()
            return cleanedString
        } else if let range1 = stringLowercased.range(of: delimiter1.lowercased()) {
            let index = range1.lowerBound
            let extractedString = String(string[..<index]).trimmingCharacters(in: .whitespacesAndNewlines)
            let allowedCharacterSet = CharacterSet.alphanumerics
            let cleanedString = extractedString.components(separatedBy: allowedCharacterSet.inverted).joined()
            return cleanedString
        } else if let range2 = stringLowercased.range(of: delimiter2.lowercased()) {
            let index = range2.lowerBound
            let extractedString = String(string[..<index]).trimmingCharacters(in: .whitespacesAndNewlines)
            let allowedCharacterSet = CharacterSet.alphanumerics
            let cleanedString = extractedString.components(separatedBy: allowedCharacterSet.inverted).joined()
            return cleanedString
        } else {
            let allowedCharacterSet = CharacterSet.alphanumerics
            let cleanedString = string.components(separatedBy: allowedCharacterSet.inverted).joined()
            return cleanedString
        }
    }
    

    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("INSIDE")
        let key = readKey(key: "YouTubeDataAPI")
        let query = movieName + " trailer"
        let youtubeAPI = ("https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=" + query + "&key=" + key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(youtubeAPI!).responseJSON { response in
            print(response)
            switch response.result {
            case .success(let value):
                let jsonObject = JSON(value)
                let videoId = jsonObject["items"][0]["id"]["videoId"].stringValue
                let url = "https://www.youtube.com/watch?v=" + videoId
                let videoIdentifier = videoId
                
                XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error: Error?) in
                    if let video = video {
                        if let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] {
                            
                            let extractedString = self.extractStringBeforeTrailer(string: video.title)
                            print("Exatracted String")
                            print(extractedString)
                            print("url string")
                            var resultID = "NO ID"
                            self.fetchMovieID(extractedString: extractedString) { result in
                                switch result {
                                case .success(let id):
                                    resultID = id
                                    self.fetchMovieDetails(movieID: resultID) { result in
                                        switch result {
                                        case .success(let movieDetails):
                                            print("Title: \(movieDetails.title)")
                                            print("Year: \(movieDetails.year)")
                                            print("Directors: \(movieDetails.directors)")
                                            print("Stars:")
                                            let starsString = movieDetails.stars.map { "- \($0.name)" }.joined(separator: ", ")
                                            print(starsString)
                                            addVideoToSCNNode(url: streamURL.absoluteString, node: node, title:movieDetails.title, year:movieDetails.year, director: movieDetails.directors,stars:starsString, imDbRating:movieDetails.imDbRating, genres:movieDetails.genres, plot:movieDetails.plot, worldWideCollection:movieDetails.worldWideCollection)
                                        case .failure(let error):
                                            print("Error: \(error.localizedDescription)")
                                        }
                                    }

                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        } else {
                            print("No stream URL found")
                        }
                    } else {
                        print("Error loading video: \(error?.localizedDescription ?? "")")
                    }
                }
                
            case .failure(let error):
                print(error)
                self.isVideoOn = false
            }
            
        }
        
    }
}
