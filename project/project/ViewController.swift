//
//  ViewController.swift
//  project
//
//  Created by Donald Ng on 10/04/2023.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func uploadaccountbutton(_ sender: Any) {
        uploadaccount()
    }
    
    //setting up the imagepickercontroller to accesst the video library
    @IBAction func button(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.mediaTypes = ["public.movie"]
        present(vc , animated: true)
    }
    
    //picking the video from the video library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[.mediaURL] as? URL {
            uploadvideo(url)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //dismiss the video library when the cancel button is clicked
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    
    
    //uploading to the api
    //might be handy to add a parameter for the url of the csv file
    func uploadvideo(_ videourl:URL){
    
        //turning the video url into video file
        guard let videoData = try? Data(contentsOf: videourl) else {
            print("Failed to read video file")
            return
        }
        
        
        
        let urlString = "http://192.168.0.21:8000/api/exercise/"
        let url = URL(string: urlString)!
        let boundary = UUID().uuidString
        
        
        
        
        //getting the url string from the local file felix use file maneger so u might have to delete this
        guard let csvURL = Bundle.main.url(forResource: "test_squat", withExtension: "csv") else {
            print("CSV file not found")
            return
        }
        
        //creating a post http request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //creating form data that is required for the api
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"account\"\r\n\r\n".data(using: .utf8)!)
        body.append("1\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"exercise_type\"\r\n\r\n".data(using: .utf8)!)
        body.append("squat\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"datetime\"\r\n\r\n".data(using: .utf8)!)
        body.append("2023-03-10 13:48:41\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video_file\"; filename=\"video.mov\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/quicktime\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"csv_file\"; filename=\"data.csv\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!)
        do {
            //turning csv url into csv file
            let csvData = try Data(contentsOf: csvURL)
            body.append(csvData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        } catch let error {
            print("Error reading CSV data: \(error.localizedDescription)")
        }
        
        body.append("Content-Disposition: form-data; name=\"quality\"\r\n\r\n".data(using: .utf8)!)
        body.append("unchecked\r\n".data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let session = URLSession.shared
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            if httpResponse.statusCode == 200 {
                print("Video uploaded successfully")
            } else {
                print("Error uploading video: \(httpResponse.statusCode)")
            }
            
        }
        task.resume()
        
        
        
    }
        func uploadaccount(){
            let data = ["first_name": "felix","last_name": "berns","username": "fb","password": "fb1234","email": "fb123@gmail.com"] as [String : Any]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])else{
                print("Failed to convert to jsonfile")
                return
            }
            let url = URL(string: "http://192.168.0.21:8000/api/accounts/")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("Status code: \(response.statusCode)")
                    if response.statusCode == 500{
                        print("server side error, accounts most likely exist")
                    }
                }
                
            }

            task.resume()
        }

    func uploadworkout(){
        let data = ["account" : 2,"startTime" : "2023-03-10 15:48:40","endTime" : "2023-03-10 16:48:40","title":"food ","description":"morgan"] as [String : Any]
        //convert into json file
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])else{
            print("Failed to convert to jsonfile")
            return
        }
        let url = URL(string: "http://192.168.0.21:8000/api/workouts/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Status code: \(response.statusCode)")
                if response.statusCode == 500{
                    print("server side error, accounts most likely exist")
                }
            }
            
        }

        task.resume()
    }

    @IBAction func uploadworkoutbutton(_ sender: Any) {
        uploadworkout()
    }
}
