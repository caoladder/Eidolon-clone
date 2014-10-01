import UIKit

class PlaceBidViewController: UIViewController {

    dynamic var bidDollars: UInt = 0

    @IBOutlet var bidAmountTextField: UITextField!
    @IBOutlet var keypadContainer: KeypadContainerView!

    @IBOutlet var currentBidLabel: UILabel!
    @IBOutlet var nextBidAmountLabel: UILabel!

    @IBOutlet var artistNameLabel: ARSerifLabel!
    @IBOutlet var artworkTitleLabel: ARSerifLabel!
    @IBOutlet var artworkPriceLabel: ARSerifLabel!

    class func instantiateFromStoryboard() -> PlaceBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.PlaceYourBid) as PlaceBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let keypad = self.keypadContainer!.keypad!
        let bidIsZeroSignal = RACObserve(self, "bidDollars").map {
            return ($0 as UInt == 0)
        }

        for button in [bidButton, keypad.rightButton, keypad.leftButton] {
            RAC(button, "enabled") <~ bidIsZeroSignal.notEach()
        }

        let formattedBidTextSignal = RACObserve(self, "bidDollars").map({ (bid) -> AnyObject! in
            return NSNumberFormatter.currencyStringForDollars(bid as UInt)
        })

        RAC(bidAmountTextField, "text") <~ RACSignal.`if`(bidIsZeroSignal, then: RACSignal.defer{ RACSignal.`return`("") }, `else`: formattedBidTextSignal)

        keypadSignal.subscribeNext(addDigitToBid)
        deleteSignal.subscribeNext(deleteBid)
        clearSignal.subscribeNext(clearBid)

        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(nav.bidDetails, "bidAmountCents") <~ RACObserve(self, "bid").map { return ($0 as Float * 100) }

            if let saleArtwork:SaleArtwork = nav.bidDetails.saleArtwork {

                RAC(currentBidLabel, "text") <~ RACObserve(saleArtwork, "openingBidCents").map(toCurrentBidString)
                RAC(nextBidAmountLabel, "text") <~ RACObserve(saleArtwork, "openingBidCents").map(toOpeningBidString)

                if let artist = saleArtwork.artwork.artists?.first {
                    RAC(artistNameLabel, "text") <~ RACObserve(artist, "name")
                }

<<<<<<< HEAD
                RAC(artworkTitleLabel, "text") <~ RACObserve(saleArtwork.artwork, "title")
                RAC(artworkPriceLabel, "text") <~ RACObserve(saleArtwork.artwork, "price")
            }
=======
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == SegueIdentifier.ConfirmBid {
            let confirmVC = segue.destinationViewController as ConfirmYourBidViewController
            confirmVC.bid = Bid(id: "FAKE BID", amountCents: Int(self.bidDollars * 100))
>>>>>>> wip
        }
    }

    @IBOutlet var bidButton: Button!
    @IBAction func bidButtonTapped(sender: AnyObject) {
        self.performSegue(SegueIdentifier.ConfirmBid)
    }

    lazy var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
    lazy var clearSignal:RACSignal!  = self.keypadContainer.keypad?.rightSignal
    lazy var deleteSignal:RACSignal! = self.keypadContainer.keypad?.leftSignal
}

/// These are for RAC only

private extension PlaceBidViewController {

    func addDigitToBid(input:AnyObject!) -> Void {
        let inputInt = input as? UInt ?? 0
        let newBidDollars = (10 * self.bidDollars) + inputInt
        if newBidDollars <= 10000000 {
            self.bidDollars = newBidDollars
        } else {
            // TODO: handle too big number
        }
    }

    func deleteBid(input:AnyObject!) -> Void {
        self.bidDollars = UInt(min(floor(Double(self.bidDollars)/10), 0))
    }

    func clearBid(input:AnyObject!) -> Void {
        self.bidDollars = 0
    }

    func toCurrentBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? UInt) {
            return dollars
        }
        return ""
    }

    func toOpeningBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? UInt) {
            return "Enter \(dollars) or more"
        }
        return ""
    }
}
