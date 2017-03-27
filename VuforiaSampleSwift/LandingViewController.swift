import SnapKit
import UIKit

class LandingViewController: UIViewController {
    var header = UILabel()
    var subheader = UILabel()
    var StoneAndChipsButton = UIButton()
    var AdvertisementsButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureButtonTargets()
        addUIContents()
        layoutUI()
    }
    
    func configureButtonTargets() {
        StoneAndChipsButton.addTarget(self, action: #selector(LandingViewController.StoneAndChipsButtonPressed), for: .touchUpInside)
        AdvertisementsButton.addTarget(self, action: #selector(LandingViewController.AdvertisementsButtonPressed), for: .touchUpInside)
    }
    
    func StoneAndChipsButtonPressed() {
        print("Stones pressed")
        router.push(.stonesAndChips)
    }
    
    func AdvertisementsButtonPressed() {
        print("Advertisements pressed")
        router.push(.advertisements)
    }
    
    func addUIContents() {
        header.font = header.font.withSize(20)
        subheader.font = subheader.font.withSize(16)
        
        StoneAndChipsButton.setTitleColor(.black, for: .normal)
        StoneAndChipsButton.layer.borderWidth = 2
        StoneAndChipsButton.layer.borderColor = UIColor.black.cgColor
        StoneAndChipsButton.titleEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
        StoneAndChipsButton.titleLabel!.adjustsFontSizeToFitWidth = true

        AdvertisementsButton.setTitleColor(.black, for: .normal)
        AdvertisementsButton.layer.borderWidth = 2
        AdvertisementsButton.layer.borderColor = UIColor.black.cgColor
        AdvertisementsButton.titleEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
        AdvertisementsButton.titleLabel!.adjustsFontSizeToFitWidth = true

        // Relevant text
        header.text = "Example Augmented Reality App"
        subheader.text = "Built with Swift, Vuforia, and Scenekit"
        StoneAndChipsButton.setTitle("Stone And Chips", for: .normal)
        AdvertisementsButton.setTitle("Advertisements", for: .normal)
        
        // Add contents to the view
        view.addSubview(header)
        view.addSubview(subheader)
        view.addSubview(StoneAndChipsButton)
        view.addSubview(AdvertisementsButton)
    }
    
    func layoutUI() {
        header.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view).offset(100)
            make.centerX.equalTo(view)
        }
        subheader.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(header).offset(50)
            make.centerX.equalTo(view)
        }
        StoneAndChipsButton.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(50)
            make.width.equalTo(view.snp.width).dividedBy(3)
        }
        AdvertisementsButton.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(view).offset(-100)
            make.right.equalTo(view).offset(-50)
            make.width.equalTo(view.snp.width).dividedBy(3)
        }
    }
    
    
}
