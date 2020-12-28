// Paginate returns the correct starting and ending index for a paginated query,
// given that client provides a desired page and limit of objects and the handler
// provides the total number of objects. If the start page is invalid, non-positive
// values are returned signaling the request is invalid.
//
// NOTE: The start page is assumed to be 1-indexed.
func paginate(count: Int, page: Int, limit: Int, definitiveLimit: Int) -> (Int, Int) {
    var limit = limit
    
    if page == 0 {
        // invalid start page
        return (-1, -1)
    } else if limit == 0 {
        limit = definitiveLimit
    }

    let start = (page - 1) * limit
    var end = limit + start

    if end >= count {
        end = count
    }

    if start >= count {
        // page is out of bounds
        return (-1, -1)
    }

    return (start, end)
}

