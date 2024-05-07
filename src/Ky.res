type request
type response<'data> = {json: unit => promise<'data>, status: int, url: string, ok: bool}
type error<'data> = {response: option<response<'data>>, request: option<request>, name: string}

type httpMethod =
  | GET
  | POST
  | PUT
  | HEAD
  | DELETE
  | PATCH

type rec retryOptions = {
  limit?: int,
  methods?: array<retryMethod>,
  statusCodes?: array<int>,
  backoffLimit?: int,
  delay?: int => float,
}
and retryMethod =
  | GET
  | PUT
  | HEAD
  | DELETE
  | OPTIONS
  | TRACE

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
  | Sync(response<'data>)
  | Async(promise<response<'data>>)

type afterResponseCallback<'responseData> = (
  request,
  responseOptions,
  response<'responseData>,
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
  method?: httpMethod,
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
) => response<'data> = "default"

@module("ky") @scope("default")
external get: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => response<'data> = "get"
@module("ky") @scope("default")
external post: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => response<'data> = "post"
@module("ky") @scope("default")
external put: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => response<'data> = "put"
@module("ky") @scope("default")
external patch: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => response<'data> = "patch"
@module("ky") @scope("default")
external head: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => response<'data> = "head"
@module("ky") @scope("default")
external delete: (
  string,
  ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
) => response<'data> = "delete"

module Instance = {
  type t<'json, 'searchParams, 'errorData, 'responseData, 'data> = (
    string,
    requestOptions<'json, 'searchParams, 'errorData, 'responseData>,
  ) => response<'data>

  @module("ky") @scope("default")
  external create: requestOptions<'json, 'searchParams, 'errorData, 'responseData> => t<
    'json,
    'searchParams,
    'errorData,
    'responseData,
    'data,
  > = "create"

  @send
  external get: (
    t<'json, 'searchParams, 'errorData, 'responseData, 'data>,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => response<'data> = "get"
  @send
  external post: (
    t<'json, 'searchParams, 'errorData, 'responseData, 'data>,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => response<'data> = "post"
  @send
  external put: (
    t<'json, 'searchParams, 'errorData, 'responseData, 'data>,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => response<'data> = "put"
  @send
  external patch: (
    t<'json, 'searchParams, 'errorData, 'responseData, 'data>,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => response<'data> = "patch"
  @send
  external head: (
    t<'json, 'searchParams, 'errorData, 'responseData, 'data>,
    string,
    ~options: requestOptions<'json, 'searchParams, 'errorData, 'responseData>=?,
  ) => response<'data> = "head"
  @send
  external delete: (
    t<'json, 'searchParams, 'errorData, 'responseData, 'data>,
    string,
    requestOptions<'json, 'searchParams, 'errorData, 'responseData>,
  ) => response<'data> = "delete"

  @send
  external extend: (
    t<'json, 'searchParams, 'errorData, 'responseData, 'data>,
    requestOptions<'json, 'searchParams, 'errorData, 'responseData>,
  ) => t<'json, 'searchParams, 'errorData, 'responseData, 'data> = "extend"
}
