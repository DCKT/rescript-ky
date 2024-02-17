type expect<'a> = {toBe: 'a}
@module("bun:test")
external expect: 'a => expect<'b> = "expect"
@module("bun:test")
external test: (string, unit => unit) => unit = "test"
@module("bun:test")
external testAsync: (string, unit => promise<unit>) => unit = "test"

type mock = {
  mockInstance: unit => unit,
  path: string,
}

@module("./mock.ts")
external mockBasePath: string = "mockBasePath"

@module("./mock.ts")
external initMockServer: unit => unit = "initMockServer"

initMockServer()

testAsync("Simple fetch", async () => {
  let response = await Ky.fetch("", {prefixUrl: mockBasePath, method: GET}).json()

  expect(response["test"]).toBe(1)
})

testAsync("Custom retry", async () => {
  let response = await Ky.fetch(
    `retry`,
    {prefixUrl: mockBasePath, method: GET, retry: Int(1)},
  ).json()

  expect(response["retryCount"]).toBe(1)
})

testAsync("Custom timeout", async () => {
  try {
    await Ky.fetch(`timeout`, {prefixUrl: mockBasePath, method: GET, timeout: 100}).json()
  } catch {
  | JsError(err) => {
      let err: Ky.error<unit> = err->Obj.magic
      expect(err.name).toBe("TimeoutError")
    }
  }
})
