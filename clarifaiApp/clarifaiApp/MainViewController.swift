//
//  ViewController.swift
//  Snapoetry
//  
//  An app that can take a photo, recognize the image with tags,
//  then display hardcoded poetry from another api using the first tag.
//
//  Created by Jonathan Turnbull on 18/08/2017.
//  Copyright © 2017 partywolfAPPS. All rights reserved.
//

import UIKit
import Clarifai
import SnapKit
import Foundation
import AVFoundation

class MainViewController: UIViewController,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {
    
    // Declared Variables - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var poeticText: UITextView!
    
    // Custom camera outlets
    @IBOutlet weak var previewView: UIView!

    // Custom camera variables
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    
    
    @IBOutlet weak var backNavButton: UIButton!
    @IBOutlet weak var shareNavButton: UIButton!
    
    
    // Declaring Variables - Globals
    var app:ClarifaiApp?
    let picker = UIImagePickerController()
    var poems = [String]()
    var loaded = false
    var tagOne = "no poem"
    //var cameraNeeded = true;
 
    /* ERIN TO IMPLEMENT THIS LATER....
    //Check to see which device the app is running on, in order to apply appropriate contraints.
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPHONE_7          = IS_IPHONE_6
        static let IS_IPHONE_7P         = IS_IPHONE_6P
        static let IS_IPHONE_8          = IS_IPHONE_6
        static let IS_IPHONE_8P         = IS_IPHONE_6P
        static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
        static let iPad                 = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    }
    */
    
    // Load Clarifai API
    override func viewDidLoad() {
        
        //setupInitialUI()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Declare my api key
        app = ClarifaiApp(apiKey: "ab5e1c0750f14e5685e24b243de99d27")
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup your camera here...
        
        // Setup Session to use camera inputs
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Rear Camera is chosen
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Prepare the rear camera as input
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        // Check Errors for the session
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            // ...
            // The remainder of the session setup will go here...
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if session!.canAddOutput(stillImageOutput) {
                session!.addOutput(stillImageOutput)
                // ...
                // Configure the Live Preview here...
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
                
                
                
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = previewView.bounds
        
        
    }
    
    // When the app starts it will open the camera
//    override func viewDidAppear(_ animated: Bool) {
//        if (cameraNeeded == true) {
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = .camera
//                imagePicker.allowsEditing = false
//
//                // Present it to screen
//                self.present(imagePicker, animated: false, completion: nil)
//
//                poeticText.text.removeAll()
//                cameraNeeded = false
//            }
//
//        }
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
//    // select photo icon blinks
//    @IBAction func selectPhotoDown(_ sender: UIButton) {
//         selectPhoto.setImage(UIImage(named: "snapoetry_closed"), for: .normal)
//    }
    
    
//    // Select a photo from the album
//    @IBAction func selectPhoto(_ sender: UIButton) {
//
//        // Open the eye on touch up
//        selectPhoto.setImage(UIImage(named: "snapoetry_photo_alt"), for: .normal)
//
//        // Show a UIImagePickerController to let the user pick an image from their library.
//        picker.allowsEditing = false;
//
//        // Open Users device photo library
//        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        picker.delegate = self;
//
//        // present photo to screen
//        present(picker, animated: true, completion: nil)
//
//        poeticText.text.removeAll()
//
//    }
    
    
    @IBAction func didTakePhoto(_ sender: UIButton) {
        
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            // ...
            // Code for photo capture goes here...
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                // ...
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!)
                    // ...
                    // Add the image to captureImageView here...
                    
                    self.imageView.image = image
                }
                
                
            })
            
        }
    }
    
    
    
    
    // Pick an image from the users library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The user picked an image. Send it to Clarifai for recognition.
        dismiss(animated: true, completion: nil)
        //redraw UI
        setupPhotolUI()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Needs a fix
            // Set image to the UIImageView
            imageView.image = image
            
            // Get Width and Height of Chosen Image
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            // Create a new frame for the image to sit in
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageWidth, height: imageHeight)
            
            // Automatically resizes the height of the image
            imageView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            
            // Scales the image to fit on the screen
            self.imageView.contentMode = UIViewContentMode.scaleAspectFit
            
            // Recognizes the image
            recognizeImage(image: image)
            //textView.text = "Hmmmm..."
            
            // Disable buttons while recognizing
            //selectPhoto.isEnabled = false
            //selectPhoto.setImage(UIImage(named: "snapoetry_closed"), for: .normal)
            
            
            
        }
    }
    
    // Recognize the Image with Clarifai
    func recognizeImage(image: UIImage) {
        
        // Check that the application was initialized correctly.
        if let app = app {
            
            // Fetch Clarifai's general model.
            app.getModelByName("general-v1.3", completion: { (model, error) in
                
                // Create a Clarifai image from a uiimage.
                let caiImage = ClarifaiImage(image: image)!
                
                // Use Clarifai's general model to pedict tags for the given image.
                model?.predict(on: [caiImage], completion: { (outputs, error) in
                    print("%@", error ?? "no error")
                    guard
                        let caiOuputs = outputs
                        else {
                            print("Predict failed")
                            return
                    }
                    
                    if let caiOutput = caiOuputs.first {
                        // Loop through predicted concepts (tags), and display them on the screen.
                        let tags = NSMutableArray()
                        for concept in caiOutput.concepts {
                            
                            // Removes the tag "no person" as it was causing problems
                            if ( concept.conceptName! == "no person" ){
                                tags.remove(concept.conceptName)
                            } else {
                                tags.add("It is \(concept.conceptName!)")
                                
                                
                            }
                            
                        }
                        
                        // Wait for the API to load before outputing to screen
                        DispatchQueue.main.async {
                            // Update the new tags in the UI.
                            //self.textView.text = String(format: "Tags: ", tags.componentsJoined(by: " "))
                            
                            
                            // Take all the tags and push them into a string
                            
                            self.tagOne = "\(tags)"
                            
                            print(tags)
                            // Send tag to our API to generate poetry
                            //self.getRequest(poemName: self.tagOne)
                            
                            //Check if list of tags contains one of our key topics, to generate relevant poem
                            if (self.tagOne.contains("animal")){
                                print("Poem topic identified as Animals")
                                self.generateAnimal1()
                            }
                            else if (self.tagOne.contains("nature")){
                                print("Poem topic identified as Nature")
                                self.generateNature1()
                                }
                            else if (self.tagOne.contains("people")){
                                print("Poem topic identified as People")
                                self.generatePeople1()
                            }
                            else {
                                print("Poem topic not identified")
                                self.generatePoem2()
                            }
                            
                        }
                        
                    }
                    
                    // Once finished enable buttons again
                    DispatchQueue.main.async {
                      
                        
                        
                    }
                    
                })
            })
        }
    
    }
    
    // ***************************************************
    // * Wordclasser 
    // *
    // ***************************************************
    
    //identify word class for each word in sentence
    func getWordClass(text: String, language: String = "en")->[String:[String]]{
        
        // Disregards the unimportant things inside the text ie. gaps, puncuation etc..
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        // Chooses a language english
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: language)
        // Tags will be english and the options will be disregarded.
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        
        var words = [String:[String]]()
        
        // Text perameter becomes a tagger string
        tagger.string = text
        // Text is then converted to NSString
        let tmpString = text as NSString
        // The range is the max length of tmpString
        let range = NSRange(location: 0, length: tmpString.length)
    
        // The tagger beginners classing the words inside the tmpString with Noun, Verb, Adj etc
        tagger.enumerateTags(in: range, scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
            
            let token = tmpString.substring(with: tokenRange)

            if(words[tag] == nil){
                words[tag] = [String]()
            }
           
            words[tag]!.append(token)
           
        }

        return words
    }
    
    
    //if there aren't enough  adj/verb/adverb in image tags for us to choose from, we can use those supplement
    let wordSupplement = ["Adjective":["sweet", "beautiful", "bright", "shining", "brilliant", "wonderful", "gigantic", "huge", "little", "amazing", "great", "shy", "lazy", "exciting", "slow", "smooth", "soft", "warm"], "Verb":["run", "walk", "jump", "fly", "laugh", "smile", "sing", "rise", "cry", "swim", "climb", "burn", "eat", "push", "sit", "look"], "Adverb":["happily", "excitedly", "cheerfully", "lightly", "alone", "fast", "gladly", "swiftly", "shyly", "brightly", "silently", "lazily", "excitingly", "slowly", "smoothly", "softly", "warmly"], "Pronoun":["he","she","they"], "Detirminer":["the", "every", "this", "those", "that", "many", "my", "his", "hers", "yours"]]
    
    //select a specific type of word from the image tags
    func selectRandomWord(wordClass:String, imageTags:[String:[String]])->String{
        
        if(imageTags[wordClass] == nil){
            let len = wordSupplement[wordClass]!.count
            let random = Int(arc4random_uniform(UInt32(len)))
            
            return wordSupplement[wordClass]![random]
        }
        else{
            let len = imageTags[wordClass]!.count
            let random = Int(arc4random_uniform(UInt32(len)))
            
            return imageTags[wordClass]![random]
        }
    }
    
    //define article(a/an) before word
    func getArticle(word: String)->String{
        var firstCharacter = ""
        firstCharacter.append(word[word.startIndex])
        let vowels = ["a", "e", "i", "o", "u"]
        
        for i in 0..<vowels.count{
            if(firstCharacter.lowercased() == vowels[i]){
                return "an"
            }
        }
        
        return "a"
    }
    
    
    
//    for (wordClass, wordArray) in words{
//    print("\(wordClass): \(wordArray)")
//    }
    
    /*poem structure 1
     I am in the {0:noun}, it is so {1:adj}
     What a/an {2:adj} {3:noun}
     I cannot erase this {4:noun} in my mind
     Just {5: adv} {6:verb}ing
     */
    
    func generatePoem1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Noun", "Adverb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "I am in the " + chosenWords[0] + ", it is so " + chosenWords[1] + ".\n"
        poem += "What " + getArticle(word: chosenWords[2]) + " " + chosenWords[2] + " " + chosenWords[3]
        poem += "\nI cannot erase that " + chosenWords[4] + " in my mind\n"
        poem += "Just " + chosenWords[5] + " " + chosenWords[6] + "ing"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*poem structure 2
     The {0:noun} {1:verb} in the {2:noun}
     Without {3:determiner} {4:adjective} or {5:adjective}
     {6:Pronoun} {7:adverb} the {8:noun}"
     */
    
    func generatePoem2()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        /*print poem structure*/
        print("Poem Structure:\n")
        
        print("The {noun} {verb} in the {noun}\nWithout {determiner} {adjective} or {adjective}\n{Pronoun} {adverb} the {noun}")
        print("Poem:\n")
        
        let wordClasses = ["Noun", "Verb", "Noun", "Detirminer", "Adjective", "Adjective", "Pronoun", "Verb", "Noun",]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "The " + chosenWords[0] + " " + chosenWords[1] + " in the " + chosenWords[2]
        poem += ".\n Without " + chosenWords[3] + " " + chosenWords[4] + " or " + chosenWords[5] + ".\n"
        poem += chosenWords[6] + " " + chosenWords[7] + " the " + chosenWords[8]
        
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        
        return poem
    }

    
    /*
     Animal poem structure #1
     {0:adj} {1:noun}, with your eyes so {2:adj}
     You see the {3:noun} so {4:adj} and {5:adj}
     Time to {6:verb}, so much to {7:verb}
     */
    
    func generateAnimal1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        
        print(words)
        
        let wordClasses = ["Adjective", "Noun", "Adjective", "Noun", "Adjective", "Adjective", "Verb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem =  getArticle(word: chosenWords[0]) + " " + chosenWords[0] + " " + chosenWords[1] + ", with your eyes so " + chosenWords[2] + ", \n"
        poem += "You see the " + chosenWords[3] + " so " + chosenWords[4] + " and " + chosenWords[5] + ", \n"
        poem += "Time to " + chosenWords[6] + ", so much to " + chosenWords[7] + "."
        
        print(getArticle(word: chosenWords[0]))
        print(chosenWords[0])
        print(chosenWords[1])
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*
     Animal poem structure #2
     I have a {0:adj} {1:noun}
     Most {2: adj} for miles around
     Wherever there’s lots of {3:noun}
     That’s where he’ll {4:verb}
     
     */
    func generateAnimal2()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Noun", "Adverb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "I am in the " + chosenWords[0] + ", it is so " + chosenWords[1] + ".\n"
        poem += "What " + getArticle(word: chosenWords[2]) + " " + chosenWords[2] + " " + chosenWords[3]
        poem += "\nI cannot erase that " + chosenWords[4] + " in my mind\n"
        poem += "Just " + chosenWords[5] + " " + chosenWords[6] + "ing"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*
     Nature poem structure #1
     Let your eyes consume the beauty of {0:noun}
     Let {1: adj} {2:noun} soothe your mind
     You’ll feel the aloha spirit—
     A more {3:adj} {4:noun} you won’t find
     
     */
    func generateNature1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Noun", "Adverb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "I am in the " + chosenWords[0] + ", it is so " + chosenWords[1] + ".\n"
        poem += "What " + getArticle(word: chosenWords[2]) + " " + chosenWords[2] + " " + chosenWords[3]
        poem += "\nI cannot erase that " + chosenWords[4] + " in my mind\n"
        poem += "Just " + chosenWords[5] + " " + chosenWords[6] + "ing"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    
    /*
    Nature poem structure #2
    {0:noun} is such a {1:adj} sight,
    With {2:adj} {3:noun} and {4:adj} {5:noun}
    An abundance of {6:noun}, what pure delight
    */
    
    func generateNature2()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Adjective", "Noun", "Noun"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = chosenWords[0] + " is such a " + chosenWords[1] + " sight,"
        poem += "\nWith " + chosenWords[2] + " " + chosenWords[3] + " and " + chosenWords[4] + " " + chosenWords[5]
        poem += "\nWith " + chosenWords[6] + " in my mind"
        poem += "\nAn abundance of " + chosenWords[7] + " what pure delight."
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
 
    /*
    Room poem structure #1
    A {0:adj} {1:noun}
    A {2:adj} {3:adj} room
    With {4:noun} and {5:noun} tossed throughout
    Where does that {6:adj} {7:noun} come from ?
    */
    
    func generateRoom1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Adjective", "Noun", "Adjective", "Adjective", "Noun", "Noun", "Adjective", "Noun"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "A " + chosenWords[0] + " " + chosenWords[1]
        poem += "\n" + chosenWords[2] + " " + chosenWords[3] + " room "
        poem += "\nWith " + chosenWords[4] + " and " + chosenWords[5] + " tossed throughout"
        poem += "\nWhere does that " + chosenWords[6] + " " + chosenWords[7] + " come from?"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*
    People poem structure #1
    {0:adj} {1:adj} eyes embedded in the {2:adj} face
    A {4:adj} mouth beneath {3:adj} nose
    The most {5:adj} person ever known
    Your {6:adj} {7:noun} lit up the New York City
    */
    
    func generatePeople1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Adjective", "Adjective", "Adjective", "Adjective", "Adjective", "Adjective", "Adjective", "Noun"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = chosenWords[0] + " " + chosenWords[1] + " eyes embedded in the " + chosenWords[2] + " face"
        poem += "\nA " + chosenWords[2] + " mouth beneath " + chosenWords[2] + " nose "
        poem += "\nThe most " + chosenWords[3] + " person ever known "
        poem += "\nYour " + chosenWords[5] + " " + chosenWords[6] + " blushes like a rose"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    
    // Back button after taking photo
    
    @IBAction func cancelSnap(sender: UIButton) {
        // Confirm Cancellation.
        
        print("User pressed back")
        let defaultAction = UIAlertAction(title: "Okay",
                                          style: .default) { (action) in
                                            // Respond to user selection of the action.
                                            self.setupInitialUI()
                                           
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (action) in
                                            // Respond to user selection of the action.
        }
        
        // Create and configure the alert controller.
        let alert = UIAlertController(title: "Cancel",
            message: "All changes will be lost. Continue?",
                                      preferredStyle: .alert)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) {
            // The alert was presented
            
        }
        
    }
    
    
 

    func setupInitialUI(){
        
        //** CONFIGURE OVERALL LAYOUT
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = .whiteColour
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
//        //** CONFIGURE BACKGROUND VIEW
//        let backgroundView = UIView()
//        contentView.addSubview(backgroundView)
//        //        self.view.bringSubview(toFront: titleView)
//        backgroundView.backgroundColor = .snapoetryBackground
//        backgroundView.snp.makeConstraints { (make) in
//            make.top.left.right.equalTo(contentView)
//            make.bottom.equalTo(contentView.snp.centerY)
//        }
        
        //** CONFIGURE TITLE VIEW
        let titleView = UIView()
        view.addSubview(titleView)
        self.view.bringSubview(toFront: titleView)
        titleView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(180)
            make.left.right.equalTo(contentView)
        }
        
        
//        //** CONFIGURE TITLE TEXT
//        titleView.addSubview(snapoetryTitle)
//        snapoetryTitle.snp.makeConstraints { (make) in
//            make.centerY.equalTo(titleView.snp.centerY).offset(-25)
//            make.centerX.equalTo(titleView.snp.centerX)
//            make.width.equalTo(400)
//            make.height.equalTo(120)
//        }
        
        
        //** CONFIGURE ICON VIEW
        let iconView = UIView()
        view.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-50)
            make.height.equalTo(self.view.snp.height).multipliedBy(0.15)
        }
        
        //** CONFIGURE PHOTO VIEW
        let photoView = UIView()
        contentView.addSubview(photoView)
        photoView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.right.equalTo(contentView)
        }
        
//        //** CONFIGURE CAMERA ICON
//        iconView.addSubview(openCamera)
//        self.view.bringSubview(toFront: openCamera)
//        openCamera.layer.borderWidth = 2
//        openCamera.layer.borderColor = UIColor.snapoetryBackground.cgColor
//        openCamera.layer.cornerRadius = 10
//        openCamera.snp.makeConstraints { (make) in
//            make.centerY.equalTo(iconView.snp.centerY)
//            make.left.equalTo(iconView.snp.left).offset(30)
//            make.height.equalTo(iconView).multipliedBy(0.95)
//            make.width.equalTo(iconView.snp.height)
//
//        }
        
//        //** CONFIGURE PHOTO LIBRARY ICON
//        iconView.addSubview(selectPhoto)
//        self.view.bringSubview(toFront: selectPhoto)
//        selectPhoto.layer.borderWidth = 2
//        selectPhoto.layer.borderColor = UIColor.snapoetryBackground.cgColor
//        selectPhoto.layer.cornerRadius = 10
//        selectPhoto.snp.makeConstraints { (make) in
//            make.centerY.equalTo(iconView.snp.centerY)
//            make.right.equalTo(iconView.snp.right).offset(-30)
//            make.height.equalTo(iconView).multipliedBy(0.9)
//            make.width.equalTo(iconView.snp.height)
//        }
        
    }
    
    func setupPhotolUI(){
        
        //** CONFIGURE OVERALL LAYOUT
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = .whiteColour
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        //** CONFIGURE NAVBAR VIEW
        let navBar = UIView()
        view.addSubview(navBar)
        navBar.backgroundColor = .whiteColour
        navBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(64)
        }
        
        //** CONFIGURE BACK BUTTON
        navBar.addSubview(backNavButton)
        self.view.bringSubview(toFront: backNavButton)
        backNavButton.snp.makeConstraints { (make) in
            make.left.equalTo(navBar.snp.left).offset(10)
            make.bottom.equalTo(navBar.snp.bottom).offset(-10)

        }
        
        //** CONFIGURE SOCIAL MEDIA SHARE BUTTON
        navBar.addSubview(shareNavButton)
        self.view.bringSubview(toFront: shareNavButton)
        shareNavButton.snp.makeConstraints { (make) in
            make.right.equalTo(navBar.snp.right).offset(-10)
            make.bottom.equalTo(navBar.snp.bottom).offset(-10)
            make.height.width.equalTo(30)
        }
        
        //** CONFIGURE ICON VIEW
        let iconView = UIView()
        view.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.height.equalTo(64)
        }
        
        //** CONFIGURE PHOTO VIEW
        let photoView = UIView()
        contentView.addSubview(photoView)
        photoView.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.equalTo(contentView.snp.bottom)
            make.left.right.equalTo(contentView)
        }
        
//        //** CONFIGURE FONT BUTTON SINGLE
//        iconView.addSubview(selectFont)
//        selectFont.backgroundColor = .whiteColour
//        selectFont.layer.borderWidth = 1
//        selectFont.layer.borderColor = UIColor.snapoetryBackground.cgColor
//        selectFont.layer.cornerRadius = 10
//        selectFont.snp.makeConstraints { (make) in
//            make.centerY.equalTo(iconView.snp.centerY)
//            make.left.equalTo(iconView.snp.left).offset(10)
//            make.height.equalTo(iconView).multipliedBy(0.8)
//            make.width.equalTo(selectFont.snp.height)
//
//        }
        
//        //** CONFIGURE COLOUR BUTTON SINGLE
        let selectColourView = UIView()
        iconView.addSubview(selectColourView)
        selectColourView.backgroundColor = .whiteColour
        self.view.bringSubview(toFront: selectColourView)
        selectColourView.layer.borderWidth = 1
        selectColourView.layer.borderColor = UIColor.snapoetryBackground.cgColor
        selectColourView.layer.cornerRadius = 10
        selectColourView.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconView.snp.centerY)
            make.right.equalTo(iconView.snp.right).offset(-10)
            make.height.equalTo(iconView).multipliedBy(0.8)
            make.width.equalTo(selectColourView.snp.height)

        }
        
        let selectColour = UIButton()
        selectColourView.addSubview(selectColour)
        selectColour.backgroundColor = .whiteColour
        self.view.bringSubview(toFront: selectColour)
        selectColour.layer.borderWidth = 1
        selectColour.layer.borderColor = UIColor.greyColour.cgColor
        selectColour.layer.cornerRadius = 10
        selectColour.snp.makeConstraints { (make) in
            make.center.equalTo(selectColourView.snp.center)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }
        
        //** CONFIGURE PHOTO DISPLAYED VIEW
        photoView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(photoView.snp.top)
            make.bottom.equalTo(photoView.snp.bottom)
            make.center.equalTo(photoView.snp.center)
        }
        
        //** CONFIGURE POEM VIEW
        let poemView = UIView()
        self.view.bringSubview(toFront: poemView)
        contentView.addSubview(poemView)
        poemView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).offset(64)
        }
        
        //** CONFIGURE POEM TEXT
        photoView.addSubview(poeticText)
        self.view.bringSubview(toFront: poeticText)
        poeticText.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)
        poeticText.textAlignment = NSTextAlignment.center
        poeticText.textColor = .whiteColour
        poeticText.layer.shadowColor = UIColor.black.cgColor
        poeticText.layer.shadowOpacity = 0.9
        poeticText.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        poeticText.text = "Analysing Image..."

        poeticText.snp.makeConstraints { (make) in
            make.top.equalTo(poemView.snp.centerY).offset(-50)
            make.width.equalTo(poemView).multipliedBy(0.8)
            make.centerX.equalTo(contentView.snp.centerX)
            make.height.equalTo(400)

        }

        
    }
    
}

