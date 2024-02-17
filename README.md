# rescript-ky

ReScript bindings for [ky HTTP client]([url](https://github.com/sindresorhus/ky))

## Setup

1. Install the module

```bash
bun install @dck/rescript-ky
# or
yarn install @dck/rescript-ky
# or
npm install @dck/rescript-ky
```

2. Add it to your `rescript.json` config

```json
{
  "bsc-flags": ["@dck/rescript-ky"]
}
```

## Usage

```rescript
type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await Ky.fetch("test", {prefixUrl: "https://fake.com", method: GET}).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```

Use shortcut method :

```rescript
type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await Ky.get("test", {prefixUrl: "https://fake.com"}).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```

### Instance

```rescript
let instance = Ky.Instance.create({prefixUrl: "https://fake.com"})

type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await (instance->Ky.Instance.get("test")).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```

### Extend

```rescript
let instance = Ky.Instance.create({prefixUrl: "https://fake.com"})
let extendedInstance = instance->Ky.Instance.extend({
  prefixUrl: `${mockBasePath}/extend`,
  headers: Ky.Headers.fromObj({
    "custom-header": "test",
  }),
})

type data = {anything: string}

let fetchSomething = async () => {
  try {
    let response: data = await (instance->Ky.Instance.get("test")).json()
    // handle response data
  } catch {
    | JsError(err) => {
      // handle err
      Js.log(err)
    }
  }
}
```