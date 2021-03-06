import RxSwift
import RxOptional

class RegistrationPostalZipViewController: UIViewController, RegistrationSubController {
    @IBOutlet var zipCodeTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finished = PublishSubject<Void>()

    lazy var viewModel: GenericFormValidationViewModel = {
        let zipCodeIsValid = self.zipCodeTextField.rx.text.asObservable().replaceNilWith("").map(isZeroLength).not()
        return GenericFormValidationViewModel(isValid: zipCodeIsValid, manualInvocation: self.zipCodeTextField.rx_returnKey, finishedSubject: self.finished)
    }()

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        zipCodeTextField.text = bidDetails.newUser.zipCode.value

        zipCodeTextField
            .rx.text
            .asObservable()
            .takeUntil(viewWillDisappear)
            .bind(to: bidDetails.newUser.zipCode)
            .disposed(by: rx.disposeBag)

        confirmButton.rx.action = viewModel.command

        zipCodeTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext(Void())
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> RegistrationPostalZipViewController {
        return storyboard.viewController(withID: .RegisterPostalorZip) as! RegistrationPostalZipViewController
    }
}
