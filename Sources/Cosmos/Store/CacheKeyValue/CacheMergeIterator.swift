import Foundation
import Database

// cacheMergeIterator merges a parent Iterator and a cache Iterator.
// The cache iterator may return nil keys to signal that an item
// had been deleted (but not deleted in the parent).
// If the cache iterator has the same key as the parent, the
// cache shadows (overrides) the parent.
//
// TODO: Optimize by memoizing.
final class CacheMergeIterator: Iterator {
    var parent: Iterator
    var cache: Iterator
    let ascending: Bool
    
    init(parent: Iterator, cache: Iterator, ascending: Bool) {
        self.parent = parent
        self.cache = cache
        self.ascending = ascending
    }
}

extension CacheMergeIterator {
    // Domain implements Iterator.
    // If the domains are different, returns the union.
    var domain: (start: Data, end: Data) {
        let (parentStart, parentEnd) = parent.domain
        let (cacheStart, cacheEnd) = cache.domain
        
        let start: Data
        let end: Data
        
        if compare(lhs: parentStart, rhs: cacheStart) == .orderedAscending {
            start = parentStart
        } else {
            start = cacheStart
        }
        
        if compare(lhs: parentEnd, rhs: cacheEnd) == .orderedAscending {
            end = cacheEnd
        } else {
            end = parentEnd
        }
        
        return (start, end)
    }

    // Valid implements Iterator.
    var isValid: Bool {
        skipUntilExistsOrInvalid()
    }

    // Next implements Iterator
    func next() {
        skipUntilExistsOrInvalid()
        assertValid()

        // If parent is invalid, get the next cache item.
        guard parent.isValid else {
            return cache.next()
        }

        // If cache is invalid, get the next parent item.
        guard cache.isValid else {
            return parent.next()
        }

        // Both are valid.  Compare keys.
        let parentKey = parent.key
        let cacheKey = cache.key
        
        switch compare(lhs: parentKey, rhs: cacheKey) {
        case .orderedAscending: // parent < cache
            parent.next()
        case .orderedSame: // parent == cache
            parent.next()
            cache.next()
        case .orderedDescending: // parent > cache
            cache.next()
        }
    }

    // Key implements Iterator
    var key: Data {
        skipUntilExistsOrInvalid()
        assertValid()

        // If parent is invalid, get the cache key.
        guard parent.isValid else {
            return cache.key
        }

        // If cache is invalid, get the parent key.
        guard !cache.isValid else {
            return parent.key
        }

        // Both are valid.  Compare keys.
        let parentKey = parent.key
        let cacheKey = cache.key
        
        switch compare(lhs: parentKey, rhs: cacheKey) {
        case .orderedAscending: // parent < cache
            return parentKey
        case .orderedSame: // parent == cache
            return parentKey
        case .orderedDescending: // parent > cache
            return cacheKey
        }
    }

    // Value implements Iterator
    var value: Data {
        skipUntilExistsOrInvalid()
        assertValid()

        // If parent is invalid, get the cache value.
        guard parent.isValid else {
            return cache.value
        }

        // If cache is invalid, get the parent value.
        guard cache.isValid else {
            return parent.value
        }

        // Both are valid.  Compare keys.
        let parentKey = parent.key
        let cacheKey = cache.key
        
        switch compare(lhs: parentKey, rhs: cacheKey) {
        case .orderedAscending: // parent < cache
            return parent.value
        case .orderedSame: // parent == cache
            return cache.value
        case .orderedDescending: // parent > cache
            return cache.value
        }
    }

    // Close implements Iterator
    func close() {
        parent.close()
        cache.close()
    }

    // Error returns an error if the cacheMergeIterator is invalid defined by the
    // Valid method.
    var error: Swift.Error? {
        if !isValid {
            struct CacheMergeIteratorError: Swift.Error, CustomStringConvertible {
                var description: String
            }
            
            return CacheMergeIteratorError(description: "invalid cacheMergeIterator")
        }

        return nil
    }

    // If not valid, panics.
    // NOTE: May have side-effect of iterating over cache.
    private func assertValid() {
        if let error = self.error {
            fatalError("\(error)")
        }
    }

    // Like bytes.Compare but opposite if not ascending.
    func compare(lhs: Data, rhs: Data) -> ComparisonResult {
        if ascending {
            return lhs.lexicographicallyPrecedes(rhs) ?
                .orderedAscending :
                lhs == rhs ?
                    .orderedSame :
                    .orderedDescending
        }

        return lhs.lexicographicallyPrecedes(rhs) ?
            .orderedDescending :
            lhs == rhs ?
                .orderedSame :
                .orderedAscending
    }

    // Skip all delete-items from the cache w/ `key < until`.  After this function,
    // current cache item is a non-delete-item, or `until <= key`.
    // If the current cache item is not a delete item, does nothing.
    // If `until` is nil, there is no limit, and cache may end up invalid.
    // CONTRACT: cache is valid.
    private func skipCacheDeletes(until: Data?) {
        while
            cache.isValid,
            // TODO: Check if it really makes sense for iterator.value to be nil.
//            cache.value == nil,
            let until = until,
            compare(lhs: cache.key, rhs: until) == .orderedAscending
        {
            cache.next()
        }
    }

    // Fast forwards cache (or parent+cache in case of deleted items) until current
    // item exists, or until iterator becomes invalid.
    // Returns whether the iterator is valid.
    @discardableResult
    func skipUntilExistsOrInvalid() -> Bool {
        while true {
            // If parent is invalid, fast-forward cache.
            guard parent.isValid else {
                skipCacheDeletes(until: nil)
                return cache.isValid
            }
            
            // Parent is valid.
            guard cache.isValid else {
                return true
            }
            
            // Parent is valid, cache is valid.
            // Compare parent and cache.
            let parentKey = parent.key
            let cacheKey = cache.key
            
            switch compare(lhs: parentKey, rhs: cacheKey) {
            case .orderedAscending: // parent < cache.
                return true
            case .orderedSame: // parent == cache.
                // Skip over if cache item is a delete.
                guard !cache.value.isEmpty else {
                    parent.next()
                    cache.next()
                    continue
                }
                
                // Cache is not a delete.
                return true // cache exists.
            case .orderedDescending: // cache < parent
                // Skip over if cache item is a delete.
                guard !cache.value.isEmpty else {
                    skipCacheDeletes(until: parentKey)
                    continue
                }
                
                // Cache is not a delete.
                return true // cache exists.
            }
        }
    }
}
