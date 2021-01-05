import Foundation

extension BaseApp {
    func simulate(transactionData: Data, transaction: Transaction) -> (GasInfo, Swift.Result<Result, Swift.Error>) {
        runTransaction(
            mode: .simulate,
            transactionData: transactionData,
            transaction: transaction
        )
    }
}
