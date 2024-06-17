type t

@new external make: unit => t = "FormData"

@unboxed type formDataEntryValue = String(string) | File(Js.File.t)
@unboxed type formDataValueResult = | ...formDataEntryValue | @as(null) Null

@send external get: (t, string) => formDataValueResult = "get"
@send external getAll: (t, string) => array<formDataEntryValue> = "getAll"

@unboxed
type stringOrBlob = String(string) | Blob(Js.Blob.t)

/**
   * Appends a new value onto an existing key inside a FormData object, or adds
   * the key if it does not already exist.
   *
   * @param name The name of the field whose data is contained in value.
   * @param value The field's value.
   * @param fileName The filename reported to the server.
   *
   * ## Upload a file
   * ```ts
   * const formData = new FormData();
   * formData.append("username", "abc123");
   * formData.append("avatar", Bun.file("avatar.png"), "avatar.png");
   * await fetch("https://example.com", { method: "POST", body: formData });
   * ```
   */
@send
external append: (t, string, stringOrBlob) => unit = "append"
@send external delete: (t, string) => unit = "delete"
@send external has: (t, string) => bool = "has"
@send external set: (t, string, stringOrBlob, ~fileName: string=?) => unit = "set"
