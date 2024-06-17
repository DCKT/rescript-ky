type t

@unboxed type init = Object(Js.Dict.t<string>) | String(string) | Array(array<array<string>>)

@new external make: unit => t = "URLSearchParams"
@new external makeWithInit: init => t = "URLSearchParams"

/** Appends a specified key/value pair as a new search parameter. */
@send
external append: (t, string, string) => unit = "append"

/** Deletes the given search parameter, and its associated value, from the list of all search parameters. */
@send
external delete: (t, string) => unit = "delete"

/** Returns the first value associated to the given search parameter. */
@send
@return(nullable)
external get: (t, string) => option<string> = "get"

/** Returns all the values association with a given search parameter. */
@send
external getAll: (t, string) => array<string> = "getAll"

/** Returns a Boolean indicating if such a search parameter exists. */
@send
external has: (t, string) => bool = "has"

/** Sets the value associated to a given search parameter to the given value. If there were several values, delete the others. */
@send
external set: (t, string, string) => unit = "set"

/** Sorts all key/value pairs, if any, by their keys. */
@send
external sort: t => unit = "sort"

/** Returns a string containing a query string suitable for use in a URL. Does not include the question mark. */
@send
external toString: t => string = "toString"
