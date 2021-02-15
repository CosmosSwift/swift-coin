import ABCI

public typealias DeliverTxFunction = (_ deliverTxRequest: RequestDeliverTx) -> ResponseDeliverTx
