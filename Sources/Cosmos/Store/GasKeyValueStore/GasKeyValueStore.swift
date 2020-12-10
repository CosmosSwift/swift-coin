import Foundation
import Database

// Store applies gas tracking to an underlying KVStore. It implements the
// KVStore interface.
struct GasKeyValueStore {
    let gasMeter:  GasMeter
    let gasConfiguration: GasConfiguration
    let parent: KeyValueStore
    
    // NewStore returns a reference to a new GasKVStore.
    init(parent: KeyValueStore, gasMeter: GasMeter, gasConfiguration: GasConfiguration) {
        self.parent = parent
        self.gasMeter = gasMeter
        self.gasConfiguration = gasConfiguration
    }
}

extension GasKeyValueStore: KeyValueStore {

    // Implements Store.
    var storeType: StoreType {
        parent.storeType
    }

    // Implements KVStore.
    func get(key: Data) -> Data? {
        gasMeter.consumeGas(amount: gasConfiguration.readCostFlat, descriptor: gasReadCostFlatDescriptor)
        let value = parent.get(key: key)
        // TODO overflow-safe math?
        gasMeter.consumeGas(amount: gasConfiguration.readCostPerByte * Gas(value?.count ?? 0), descriptor: gasReadPerByteDescriptor)
        return value
    }
    
    // Implements KVStore.
    func set(key: Data, value: Data) {
        assertValid(value: value)
        gasMeter.consumeGas(amount: gasConfiguration.writeCostFlat, descriptor: gasWriteCostFlatDescriptor)
        // TODO overflow-safe math?
        gasMeter.consumeGas(amount: gasConfiguration.writeCostPerByte * Gas(value.count), descriptor: gasWritePerByteDescriptor)
        parent.set(key: key, value: value)
    }

    // Implements KVStore.
    func has(key: Data) -> Bool {
        gasMeter.consumeGas(amount: gasConfiguration.hasCost, descriptor: gasHasDescriptor)
        return parent.has(key: key)
    }

    // Implements KVStore.
    func delete(key: Data) {
        // charge gas to prevent certain attack vectors even though space is being freed
        gasMeter.consumeGas(amount: gasConfiguration.deleteCost, descriptor: gasDeleteDescriptor)
        parent.delete(key: key)
    }

    // Iterator implements the KVStore interface. It returns an iterator which
    // incurs a flat gas cost for seeking to the first key/value pair and a variable
    // gas cost based on the current value's length if the iterator is valid.
    func iterator(start: Data?, end: Data?) -> Iterator {
        iterator(start: start, end: end, ascending: true)
    }

    // ReverseIterator implements the KVStore interface. It returns a reverse
    // iterator which incurs a flat gas cost for seeking to the first key/value pair
    // and a variable gas cost based on the current value's length if the iterator
    // is valid.
    func reverseIterator(start: Data?, end: Data?) -> Iterator {
        iterator(start: start, end: end, ascending: false)
    }

    // Implements KVStore.
    func cacheWrap() -> CacheWrap {
        fatalError("cannot CacheWrap a GasKVStore")
    }

    // CacheWrapWithTrace implements the KVStore interface.
//    func cacheWrapWithTrace(_ io.Writer, _ types.TraceContext) -> CacheWrap {
//        fatalError("cannot CacheWrapWithTrace a GasKVStore")
//    }

    func iterator(start: Data?, end: Data?, ascending: Bool) -> Iterator {
        let parentIterator: Iterator
        
        if ascending {
            parentIterator = parent.iterator(start: start, end: end)
        } else {
            parentIterator = parent.reverseIterator(start: start, end: end)
        }

        let gasIterator = GasIterator(gasMeter: gasMeter, gasConfiguration: gasConfiguration, parent: parentIterator)
        
        if gasIterator.isValid {
            gasIterator.consumeSeekGas()
        }

        return gasIterator
    }

}

struct GasIterator: Iterator {
    let gasMeter: GasMeter
    let gasConfiguration: GasConfiguration
    let parent: Iterator
    
    init(gasMeter: GasMeter, gasConfiguration: GasConfiguration, parent: Iterator) {
        self.gasMeter = gasMeter
        self.gasConfiguration = gasConfiguration
        self.parent = parent
    }
    
    // Implements Iterator.
    var domain: (start: Data, end: Data) {
        parent.domain
    }

    // Implements Iterator.
    var isValid: Bool {
        parent.isValid
    }

    // Next implements the Iterator interface. It seeks to the next key/value pair
    // in the iterator. It incurs a flat gas cost for seeking and a variable gas
    // cost based on the current value's length if the iterator is valid.
    func next() {
        if isValid {
            consumeSeekGas()
        }

        parent.next()
    }

    // Key implements the Iterator interface. It returns the current key and it does
    // not incur any gas cost.
    var key: Data {
        parent.key
    }

    // Value implements the Iterator interface. It returns the current value and it
    // does not incur any gas cost.
    var value: Data {
        parent.value
    }

    // Implements Iterator.
    func close() {
        parent.close()
    }

    // Error delegates the Error call to the parent iterator.
    var error: Swift.Error {
        parent.error
    }

    // consumeSeekGas consumes a flat gas cost for seeking and a variable gas cost
    // based on the current value's length.
    func consumeSeekGas() {
        gasMeter.consumeGas(amount: gasConfiguration.readCostPerByte * Gas(value.count), descriptor: gasValuePerByteDescriptor)
        gasMeter.consumeGas(amount: gasConfiguration.iterationNextCostFlat, descriptor: gasIterNextCostFlatDescriptor)
    }

}

