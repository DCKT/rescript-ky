open RescriptCore
open RescriptBun
open RescriptBun.Globals
open Test

let wait = ms => {
  Promise.make((resolve, _) => setTimeout(() => resolve(), ms)->ignore)
}

let retry = ref(0)

@module("bun:test")
external mock: (unit => unit) => unit => unit = "mock"

let afterResponseMock = mock(() => ())

@val
external jsonResponse: (
  'a,
  ~options: RescriptBun.Globals.Response.responseInit=?,
) => RescriptBun.Globals.Response.t = "Response.json"

let server = Bun.serve({
  fetch: async (request, _server) => {
    let url = URL.make(request->Globals.Request.url)
    switch url->Globals.URL.pathname {
    | "/" => jsonResponse({"test": 1})
    | "/instance/get"
    | "/instance/post"
    | "/instance/put"
    | "/instance/delete" =>
      jsonResponse({"test": 1})
    | "/test" => jsonResponse({"test": 2})
    | "/afterResponse" => {
        afterResponseMock()
        jsonResponse({"test": 1})
      }
    | "/extend/test" => jsonResponse({"test": 1})
    | "/method" => jsonResponse({"method": request->Globals.Request.method})
    | "/timeout" => {
        await wait(500)
        jsonResponse({"test": 1})
      }
    | "/json" => {
        let data = await request->Globals.Request.json
        jsonResponse(data)
      }
    | "/error-code" => jsonResponse({"code": "ERROR_CODE"}, ~options={status: 400})
    | "/retry" =>
      if retry.contents === 0 {
        retry := retry.contents + 1
        jsonResponse("busy !", ~options={status: 429})
      } else {
        jsonResponse({"retryCount": retry.contents})
      }
    | _ => jsonResponse(`404`, ~options={status: 404})
    }
  },
})

let port =
  server
  ->Bun.Server.port
  ->Int.toString

let mockBasePath = `http://localhost:${port}`

type jsonMethod = {method: Ky.HttpMethod.t}
describe("HTTP methods imports", () => {
  testAsync("GET", async () => {
    let response: jsonMethod =
      await Ky.get("method", ~options={prefixUrl: mockBasePath})->Ky.Response.json()

    expect(response.method)->Expect.toBe(GET)
  })
  testAsync("POST", async () => {
    let response: jsonMethod =
      await Ky.post("method", ~options={prefixUrl: mockBasePath})->Ky.Response.json()

    expect(response.method)->Expect.toBe(POST)
  })
  testAsync("PUT", async () => {
    let response: jsonMethod =
      await Ky.put("method", ~options={prefixUrl: mockBasePath})->Ky.Response.json()

    expect(response.method)->Expect.toBe(PUT)
  })
  testAsync("PATCH", async () => {
    let response: jsonMethod =
      await Ky.patch("method", ~options={prefixUrl: mockBasePath})->Ky.Response.json()

    expect(response.method)->Expect.toBe(PATCH)
  })
  testAsync("DELETE", async () => {
    let response: jsonMethod =
      await Ky.delete("method", ~options={prefixUrl: mockBasePath})->Ky.Response.json()

    expect(response.method)->Expect.toBe(DELETE)
  })
})

type jsonData = {test: int, randomStr: string}
external jsonData_encode: jsonData => Js.Json.t = "%identity"

describe("Configuration", () => {
  testAsync("Simple fetch", async () => {
    let response = await Ky.fetch("", {prefixUrl: mockBasePath, method: GET})->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
  })

  testAsync("Json", async () => {
    let data = {
      test: 1,
      randomStr: "test",
    }

    let response: jsonData =
      await Ky.post(
        "json",
        ~options={prefixUrl: mockBasePath, json: data->jsonData_encode},
      )->Ky.Response.json()

    expect(response.test)->Expect.toBe(1)
  })

  testAsync("Custom retry", async () => {
    let response =
      await Ky.fetch(
        `retry`,
        {prefixUrl: mockBasePath, method: GET, retry: Int(1)},
      )->Ky.Response.json()

    expect(response["retryCount"])->Expect.toBe(1)
  })

  testAsync("Custom timeout", async () => {
    try {
      await Ky.fetch(
        `timeout`,
        {prefixUrl: mockBasePath, method: GET, timeout: 100},
      )->Ky.Response.json()
    } catch {
    | JsError(err) => {
        let err: Ky.error = err->Obj.magic
        expect(err.name)->Expect.toBe("TimeoutError")
      }
    }
  })
})

describe("Instance", () => {
  let instance = Ky.Instance.create({prefixUrl: `${mockBasePath}/instance`})

  testAsync("fetch", async () => {
    let response =
      await (instance->Ky.Instance.asCallable)("get", ~options={method: GET})->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
  })

  testAsync("GET", async () => {
    let response = await instance->Ky.Instance.get("get")->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
  })

  testAsync("POST", async () => {
    let response = await instance->Ky.Instance.post("post")->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
  })
  testAsync("PUT", async () => {
    let response = await instance->Ky.Instance.put("put")->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
  })
  testAsync("DELETE", async () => {
    let response = await instance->Ky.Instance.delete("delete", {})->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
  })

  testAsync("Extend", async () => {
    let extendedInstance = instance->Ky.Instance.extend({
      prefixUrl: `${mockBasePath}/extend`,
      headers: Ky.Headers.fromObj({
        "custom-header": "test",
      }),
    })

    let response = await extendedInstance->Ky.Instance.get("test")->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
  })
})

describe("Hooks", () => {
  let instance = Ky.Instance.create({
    prefixUrl: mockBasePath,
    hooks: {
      afterResponse: [
        (_request, _responseOptions, _response) => {
          Ky.Async(Ky.get("afterResponse", ~options={prefixUrl: mockBasePath})->Ky.Response.json())
        },
      ],
    },
  })

  testAsync("Async", async () => {
    let response = await instance->Ky.Instance.get("")->Ky.Response.json()

    expect(response["test"])->Expect.toBe(1)
    expect((afterResponseMock->Obj.magic: string))->Expect.toHaveBeenCalled
  })
})

type errorPayload = {code: string}
describe("Error handling", () => {
  testAsync("Get code error from the payload", async () => {
    try {
      let _ = await Ky.get("error-code", ~options={prefixUrl: mockBasePath})->Ky.Response.json()
    } catch {
    | JsError(err) => {
        let errorResponse = (err->Ky.unkownToError).response->Option.getExn
        let errorData: errorPayload = await errorResponse->Ky.Response.json()

        expect(errorData.code)->Expect.toBe("ERROR_CODE")
      }
    }
  })
})
