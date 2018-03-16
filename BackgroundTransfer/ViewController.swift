//
//  ViewController.swift
//  BackgroundTransfer
//
//  Created by Joaquin Perez on 15/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate {

    static let onceToken = "onceTokenSession"
    
    let downloadString = "http://www.hanedanrpg.com/photos/hanedanrpg/12/55932.jpg"

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var session: URLSession!
    var downloadTask: URLSessionDownloadTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        session = backgroundSession()
        
        progressView.progress = 0
        imageView.isHidden = false
        progressView.isHidden = true
     
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(start))
    }
    
    func backgroundSession() -> URLSession {
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "example.keepcoding.com")
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
        
    }
    
    @objc func start()
    {
        if downloadTask != nil
        {
            return
        }
        
        /*
         Create a new download task using the URL session. Tasks start in the “suspended” state; to start a task you need to explicitly call -resume on a task after creating it.
         */
        
        let downloadURL = URL(string: downloadString)!
        let urlRequest = URLRequest(url: downloadURL)
        downloadTask = session.downloadTask(with: urlRequest)
        downloadTask?.resume()
        
        imageView.isHidden = true
        progressView.isHidden = false
        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        /*
         Report progress on the task.
         If you created more than one task, you might keep references to them and report on them individually.
         */
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        /*
         The download completed, you need to copy the file at targetPath before the end of this block.
         As an example, copy the file to the Documents directory of your app.
         */
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        print(documentDirectory.absoluteString)
        
        let originalURL = downloadTask.originalRequest?.url
        
        let destinationURL = documentDirectory.appendingPathComponent(originalURL!.lastPathComponent)
        
        try? FileManager.default.removeItem(at: destinationURL)
        
        do {
        try FileManager.default.copyItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                let img = UIImage.init(contentsOfFile: destinationURL.path)
                self.imageView.image = img
                self.imageView.isHidden = false
                self.progressView.isHidden = true
            }
            self.downloadTask = nil
        }
        catch {
            print(error)
        }
   
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let err = error
        {
        print(err)
        }
    }
    
    
    /*
     If an application has received an -application:handleEventsForBackgroundURLSession:completionHandler: message, the session delegate will receive this message to indicate that all messages previously enqueued for this session have been delivered. At this time it is safe to invoke the previously stored completion handler, or to begin any internal updates that will result in invoking the completion handler.
     */
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let compHandler = appDelegate.backgroundSessionCompletionHandler
        {
            appDelegate.backgroundSessionCompletionHandler = nil
            compHandler()
        }
    }
    
}
