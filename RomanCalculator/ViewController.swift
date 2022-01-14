//
//  ViewController.swift
//  RomanCalculator
//
//  Created by Ali Arda İsenkul on 9.01.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    var romanNumbers = [
                            "I": 1,
                            "V": 5,
                            "X": 10,
                            "L": 50,
                            "C": 100,
                            "D": 500,
                            "M": 1000
                       ]

    @IBOutlet weak var romanNumber: UITextField!
    @IBOutlet weak var resultNumber: UITextField!
    @IBOutlet weak var favoriteButton: UIButton!

    /*
               TÜM KURALLAR
    Sol -
    Sağ +
    Soldaki küçükse çıkarılır XIV 10-1+5 XVI 10+5+1
    Bir sembol 3'den fazla tekrarlamaz.
    V, L ve D sembolleri asla tekrarlanmaz.
    Bir sembol üç defadan fazla tekrarlanmaz.
    Daha büyük değerli bir sembolün sağına daha küçük bir sembol yazılırsa, değeri daha büyük sembolün değerine eklenir. Örneğin, VI=5+1=6, XI=11 vb.
    Daha büyük değerli bir sembolün soluna daha küçük bir sembol yazılırsa, değeri büyük sembolün değerinden çıkarılır. IV= 5-1=4, IX=9 vb.
    V, L ve D sembolleri hiçbir zaman daha büyük değere sahip bir sembolün soluna yazılmaz, yani V, L ve D asla çıkarılmaz. I sembolü sadece V ve X'ten çıkarılabilir. X sembolü sadece L, M ve C'den çıkarılabilir.
    Bir sembol, daha büyük değere sahip belirli bir sembolden bir kereden fazla çıkarılamaz. Başka bir deyişle, bir sembolün sol tarafında bir sembolü tekrarlayamayız. Örneğin, 98 IIC olarak değil XCVIII olarak yazılmıştır.
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.bookmarks, target: self, action: #selector(goToFavorites))
    }

    override func viewWillAppear(_ animated: Bool) {
        romanNumber.text = ""
        resultNumber.text = ""
        favoriteButton.isEnabled = false
    }
   
    @objc func goToFavorites(){
        performSegue(withIdentifier: "showFavorites", sender: nil)
    }

    @IBAction func addToFavorite(_ sender: Any) {
        
        guard Int(resultNumber.text!) != nil else {
           print("Roman Number is empty")
           return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newFavorite = NSEntityDescription.insertNewObject(forEntityName: "Favorites", into: context)
        
        //Attributes        
        newFavorite.setValue(romanNumber.text!, forKey: "roman")
        newFavorite.setValue(Int32(resultNumber.text!), forKey: "number")
        newFavorite.setValue(UUID(), forKey: "id")

        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        goToFavorites()
    }

    @IBAction func convertNumber(_ sender: Any) {
       let romanN = romanNumber.text ?? ""
        if romanN == "" {
            resultNumber.text = String("INVALID INPUT")
            return
        }
        
        //Roman numbers text to Char Array
        let romanArray = Array(romanN.uppercased())
        
        /*
        Girilen roma rakamlarının 1. kural dizisi kontrolü
        -----------------------------------------------------------------------------
        -Aynı karakterin 3'den fazla tekrar ediyor mu kontrol işlemi
        -L - V - D harflerinin 1'den fazla tekrar ediyor mu kontrol işlemi
        -Girilen harflerin hepsini roma rekamlarının içerisinde olup olmadığı kontrol işlemi
        */
        if !checkNumbers(romanArray: romanArray) {
            resultNumber.text = String("INVALID INPUT")
            return
        }

        /*
        Girilen roma rakamlarının 2. kural dizisi kontrolü
        -----------------------------------------------------------------------------
        -X harfinden sonra D ve M harflerinin gelip gelmediğinin kontrol işlemi
        -L harfinden sonra C-D ve M harflerinin gelip gelmediğinin kontrol işlemi
        -D harfinden sonra M harfinin gelip gelmediğinin kontrol işlemi
        */
        if !checkOccurence(charArray: romanArray) {
            resultNumber.text = String("INVALID INPUT")
            return
        }

        //Roman numbers to Integer
        let convertResult = romanToNumbers(charArray: romanArray)

        resultNumber.text = String(convertResult)
        favoriteButton.isEnabled = true
    }
    func romanToNumbers(charArray:Array<Character>) -> Int {
        
        var index = 0
        var allNumbers = [Int]()
        /*
        Roman rakamlarını ikili bloklar halinde soldan başlayarak işleme tabi tutuldu.
        Eğer sağdaki değer soldakinden büyük ise iki değer arasında çıkarma işlemi yapıldı ve bu değerler sırayla allNumbers dizisine eklendi.
        Tüm karakterler sırayla işleme tabi tutulduktan sonra birbiriyle toplanacak karakterler allNumbers dizisi içerisne yerleştirilmiş oldu.
        Son olarak bu dizi loop'a alınarak toplandı ve Roman numbers to Integer işlemi gerçekleştirildi.
        */
        while(index < charArray.count) {
            var first = romanNumbers[String(charArray[index])]! // I - 1
            var second = 0
            if index < charArray.count - 1 {
                second = romanNumbers[String(charArray[index + 1])]! // V - 5 VII
                print(first, second)
                if second > first {
                    first = second - first
                    index += 1
                }
            }
            allNumbers.append(first)
            index += 1
        }
        var total = 0
        for item in allNumbers {
            total += item
        }
        return total
    }

    //1. kural dizisi kontrolü
    func checkNumbers(romanArray:Array<Character>) -> Bool {
        for item in romanArray {
            if romanNumbers[String(item)] == nil {
                return false
            }
            let filterArray = romanArray.filter { char in
                return char == item
            }
            if item == "L" || item == "V" || item == "D"{
                if filterArray.count > 1 {
                    return false
                }
            }else {
                if(filterArray.count > 3) {
                   return false
               }
            }
        }
        return true
    }

    //2. kural dizisi kontrolü
    func checkOccurence(charArray:Array<Character>) -> Bool {
        var index = 0
        while(index < charArray.count) {
            if index == charArray.count - 1 {
                break
            }
        if charArray[index] == "X"{
            if charArray[index+1] == "D" || charArray[index+1] == "M"{
                return false
            }
        }else if charArray[index] == "L"{
            if charArray[index+1] == "C" || charArray[index+1] == "D" || charArray[index+1] == "M"{
                return false
            }
        }
        else if charArray[index] == "D"{
            if  charArray[index+1] == "M"{
                return false
            }
        }
            index+=1
    }
        return true
    }
    
}

