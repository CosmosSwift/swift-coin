import ABCIMessages

public typealias DeliverTxFunction<Payload> = (_ deliverTxRequest: RequestDeliverTx<Payload>) -> ResponseDeliverTx<Payload>
