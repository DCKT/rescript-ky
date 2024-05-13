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
type error<'data> = {response: option<Response.t>, request: option<Request.t>, name: string}

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
type beforeErrorCallback<'data> = error<'data> => error<'data>
type responseOptions

@unboxed
type afterResponseCallbackResponse<'data> =
  | Sync(Response.t)
  | Async(promise<Response.t>)

type afterResponseCallback<'responseData> = (
  request,
  responseOptions,
  Response.t,
) => afterResponseCallbackResponse<'responseData>

type hooks<'errorData, 'responseData> = {
  beforeRequest?: array<beforeRequestCallback>,
  beforeRetry?: array<beforeRetryCallback>,
  beforeError?: array<beforeErrorCallback<'errorData>>,
  afterResponse?: array<afterResponseCallback<'responseData>>,
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

type requestOptions<'json, 'searchParams, 'errorData, 'responseData> = {
  prefixUrl?: string,
  method?: HttpMethod.t,
  json?: 'json,
  searchParams?: 'searchParams,
  retry?: retry,
  timeout?: int,
  throwHttpErrors?: bool,
  hooks?: hooks<'errorData, 'responseData>,
  onDownloadProgress?: onDownloadProgress,
  parseJson?: string => Js.Json.t,
  headers?: Headers.t,
}

@module("ky")
external fetch: (
  string,
  requestOptions<'json, 'searchParams, 'errorData, 'responseData>,
) => Response.t = "default"

@module("ky") @scope("default")
external get: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => Response.t = "get"
@module("ky") @scope("default")
external post: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => Response.t = "post"
@module("ky") @scope("default")
external put: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => Response.t = "put"
@module("ky") @scope("default")
external patch: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => Response.t = "patch"
@module("ky") @scope("default")
external head: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => Response.t = "head"
@module("ky") @scope("default")
external delete: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => Response.t = "delete"

module Instance = {
  type t

  @module("ky") @scope("default")
  external create: requestOptions<'json, 'searchParams, 'errorData, 'responseData> => t = "create"

  type callable<'json, 'searchParams, 'errorData, 'responseData> = (
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => Response.t

  external asCallable: t => callable<'json, 'searchParams, 'errorData, 'responseData> = "%identity"

  @send
  external get: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => Response.t = "get"
  @send
  external post: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => Response.t = "post"
  @send
  external put: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => Response.t = "put"
  @send
  external patch: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => Response.t = "patch"
  @send
  external head: (
    t,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => Response.t = "head"
  @send
  external delete: (
    t,
    string,
    requestOptions<'json, 'searchParams, 'errorData, 'responseData>,
  ) => Response.t = "delete"

  @send
  external extend: (t, requestOptions<'json, 'searchParams, 'errorData, 'responseData>) => t =
    "extend"
}

external unkownToError: unknown => error<'data> = "%identity"
