module Request = {
  type t
}
module Response = {
  type t = {
    status: int,
    url: string,
    ok: bool,
  }

  @send
  external json: (t, unit) => promise<'data> = "json"
  external text: (t, unit) => promise<'data> = "text"
}
type request
type error = {response: option<Response.t>, request: option<Request.t>, name: string}

module HttpMethod = {
  type t =
    | GET
    | POST
    | PUT
    | HEAD
    | DELETE
    | PATCH
}

module RetryMethod = {
  type t =
    | GET
    | PUT
    | HEAD
    | DELETE
    | OPTIONS
    | TRACE
}

type retryOptions = {
  limit?: int,
  methods?: array<RetryMethod.t>,
  statusCodes?: array<int>,
  backoffLimit?: int,
  delay?: int => float,
}

type retryCallbackParams = {
  request: request,
  retryCount: int,
}

type beforeRequestCallback = request => unit
type beforeRetryCallback = retryCallbackParams => unit
type beforeErrorCallback = error => error
type responseOptions

@unboxed
type afterResponseCallbackResponse =
  | Sync(Response.t)
  | Async(promise<Response.t>)

type afterResponseCallback = (request, responseOptions, Response.t) => afterResponseCallbackResponse

type hooks = {
  beforeRequest?: array<beforeRequestCallback>,
  beforeRetry?: array<beforeRetryCallback>,
  beforeError?: array<beforeErrorCallback>,
  afterResponse?: array<afterResponseCallback>,
}

@unboxed
type retry =
  | Int(int)
  | Options(retryOptions)

type rec onDownloadProgress = (progress, Js.TypedArray2.Uint8Array.t) => unit
and progress = {
  percent: int,
  transferredBytes: int,
  totalBytes: int,
}

module Headers = {
  type t

  external fromObj: Js.t<{..}> => t = "%identity"
  external fromDict: Js.Dict.t<string> => t = "%identity"
}

type requestOptions<'searchParams> = {
  prefixUrl?: string,
  method?: HttpMethod.t,
  json?: Js.Json.t,
  searchParams?: 'searchParams,
  retry?: retry,
  timeout?: int,
  throwHttpErrors?: bool,
  hooks?: hooks,
  onDownloadProgress?: onDownloadProgress,
  parseJson?: string => Js.Json.t,
  headers?: Headers.t,
}

@module("ky")
external fetch: (string, requestOptions<'searchParams>) => Response.t = "default"

@module("ky") @scope("default")
external get: (string, ~options: requestOptions<'searchParams>=?) => Response.t = "get"
@module("ky") @scope("default")
external post: (string, ~options: requestOptions<'searchParams>=?) => Response.t = "post"
@module("ky") @scope("default")
external put: (string, ~options: requestOptions<'searchParams>=?) => Response.t = "put"
@module("ky") @scope("default")
external patch: (string, ~options: requestOptions<'searchParams>=?) => Response.t = "patch"
@module("ky") @scope("default")
external head: (string, ~options: requestOptions<'searchParams>=?) => Response.t = "head"
@module("ky") @scope("default")
external delete: (string, ~options: requestOptions<'searchParams>=?) => Response.t = "delete"

module Instance = {
  type t

  @module("ky") @scope("default")
  external create: requestOptions<'searchParams> => t = "create"

  type callable<'searchParams> = (string, ~options: requestOptions<'searchParams>=?) => Response.t

  external asCallable: t => callable<'searchParams> = "%identity"

  @send
  external get: (t, string, ~options: requestOptions<'searchParams>=?) => Response.t = "get"
  @send
  external post: (t, string, ~options: requestOptions<'searchParams>=?) => Response.t = "post"
  @send
  external put: (t, string, ~options: requestOptions<'searchParams>=?) => Response.t = "put"
  @send
  external patch: (t, string, ~options: requestOptions<'searchParams>=?) => Response.t = "patch"
  @send
  external head: (t, string, ~options: requestOptions<'searchParams>=?) => Response.t = "head"
  @send
  external delete: (t, string, requestOptions<'searchParams>) => Response.t = "delete"

  @send
  external extend: (t, requestOptions<'searchParams>) => t = "extend"
}

external unkownToError: unknown => error = "%identity"
