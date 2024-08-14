//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Dilara Akdeniz on 10.08.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton! //Details sayfasından butonun ayarlarıyla oynayabilmek için bu butonu outlet olarak tanımladık.
    
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Bu sayfa açıldığında ViewController'dan ya tableview üzerinden veri çekilip getiriliyor olabilir ya da artı tuşuna basılarak yeni bir tanesi eklenmeye çalışılıyor olabilir. if-else kontrolleriyle veri çekilecek ya da default sayfa açılacak
        
        if chosenPainting != ""{
            
            saveButton.isHidden = true
            
            
            
            //Core Data

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            //Filtreleme işlemi ile Core Data'dan çektiğimiz verinin doğru şekilde gelmesini sağladık
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!) //Id'si verilen id'ye eşit olanı getir
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameTextField.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistTextField.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearTextField.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                        
                    }
                }
            } catch {
                print("error")
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            artistTextField.text = ""
            yearTextField.text = ""
        }
        
        //Recognizers
        
//View'a gesture recognizer ekleyerek klavyeyi saklama kısmını yaptık
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
//Image view'a getsure recognizer ekleyerek tıklanıldığında resim seçme kısmını yaptık
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true //Kullanıcı fotoğrafını editleyebilir
        present(picker,animated: true)
    }
    
    //Media seçimini bitirdikten sonra bu fonksiyon bize dictionary döndürür. Any type dönmesinin sebebi media'nın ne olarak dönceğini bilmemesinden kaynaklanır ama dönen UIimage'dır.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage //Bu kısımda dönen şeyin UIImage olup olmadığından emin değiliz, kullanıcı cancel yapıp geri de dönebilir. Dolayısıyla as? casting yaptık.
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    

    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate  //App Delegate'ı değişken olarak tanımladık.
        let context = appDelegate.persistentContainer.viewContext //App Delegate içerisinde bulunan context kısmına eriştik. Bu kısma ulaşarak Core Data'ya veri kaydetmeye çalışıyoruz.
        
        //Bu kısımdan önce aşağıda kullanılan fonksiyonları kullanmak için Core Data importu yapılması gerektiğini unutma!
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artistTextField.text!, forKey: "artist")
        
        if let yearText = yearTextField.text, let yearValue = Int(yearText) {
            newPainting.setValue(yearValue, forKey: "year")
        } else {
            print("Invalid year value")
        }

        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5) //Bu kısımda kullanıcıdan aldığımız image dataya dönüştürülür
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        //NotificationCenter kullanarak view controller'lar arası mesaj gönderilebilir
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true) //Bir önceki controllera geri gider
    }
    
    

}
