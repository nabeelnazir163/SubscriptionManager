import StoreKit

public struct Configuration {
    public var productIds: [String]
    
    public init(productIds: [String]) {
        self.productIds = productIds
    }
}

public protocol SubscriptionProtocol {
    func subscriptionManager(_ subscriptionManager: SubscriptionManager, productsFetched products: [SKProduct])
}

public final class SubscriptionManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private let configurations: Configuration

    public var delegate: SubscriptionProtocol?
        
    public init(configurations: Configuration) {
        self.configurations = configurations
    }

    public func fetchSubscriptionProducts() {
        let productIdentifiers = Set(configurations.productIds)
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        delegate?.subscriptionManager(self, productsFetched: response.products)
    }

    public func purchaseSubscription(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Unlock content here
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let error = transaction.error as NSError? {
                    print("Transaction failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                // Restore purchases
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
