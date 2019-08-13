//
//  RaitingControll.swift
//  WishList
//
//  Created by Artem Esolnyak on 11/07/2019.
//  Copyright © 2019 Artem Esolnyak. All rights reserved.
//

import UIKit

@IBDesignable class RaitingControll: UIStackView {

    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    //MARK: privateMethods
    
    //метод настройки (утсановок) кнопок
    private func setUpButton(){
        
        for button in ratingButton {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButton.removeAll()
        
        //загружаем графон звезд
        let bundle = Bundle(for: type(of: self))
        let fillStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptySTar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let hightlightedSTar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        for _ in 0..<starCount {
            
   
         
        
        //создание кнопки
        let button = UIButton()
        button.backgroundColor = .white
                 //установливаем изображения для звезд
            button.setImage(emptySTar, for: .normal)
            button.setImage(fillStar, for: .selected)
            button.setImage(hightlightedSTar, for: .highlighted)
            button.setImage(hightlightedSTar, for: [.highlighted, .selected])
        
        //добавляем констрейнты
        //отключаем автоматические констрейны
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
        
        //устарновка действии кнопки
        button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
        
        //доболвяем кнопку в список представлений (в стек)
        addArrangedSubview(button)
        //добавляем новую кнопку в массив кнопок
        ratingButton.append(button)
        
        }
        updateButtonSelectionState()
    }
    
    //MARK: Properties
    private var ratingButton = [UIButton]()
    var raiting = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setUpButton()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setUpButton()
        }
    }
    
    
    
    //MARK: Button Actions
    @objc func ratingButtonTapped(button: UIButton){
        guard  let index = ratingButton.firstIndex(of: button) else {return}
        // вычисления рейтинга с помеченной звуздой
        let selectedRaiting = index + 1
        if selectedRaiting == raiting {
            raiting = 0
        } else {
            raiting = selectedRaiting
        }
    }
    private func updateButtonSelectionState() {
        for (index, button) in ratingButton.enumerated() {
            button.isSelected = index < raiting
        }
        
    }
    

}
