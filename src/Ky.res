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

type retryMethod =
  | GET
  | PUT
  | HEAD
  | DELETE
  | OPTIONS
  | TRACE

type retryOptions = {
  limit?: int,
  methods?: array<retryMethod>,
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
type beforeErrorCallback<'data> = error<'data> => unit

type hooks<'errorData> = {
  beforeRequest?: array<beforeRequestCallback>,
  beforeRetry?: array<beforeRetryCallback>,
  beforeError?: array<beforeErrorCallback<'errorData>>,
}

@unboxed
type retry =
  | Int(int)
  | Options(retryOptions)

type requestOptions<'json, 'searchParams, 'errorData> = {
  prefixUrl?: string,
  method?: httpMethod,
  json?: 'json,
  searchParams?: 'searchParams,
  retry?: retry,
  timeout?: int,
  hooks?: hooks<'errorData>,
}

@module("ky")
external fetch: (string, requestOptions<'json, 'searchParams, 'errorData>) => response<'data> =
  "default"
