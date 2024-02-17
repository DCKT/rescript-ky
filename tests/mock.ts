export const mockBasePath = "http://localhost:3000";

let retry = 0;

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export const initMockServer = () =>
  Bun.serve({
    async fetch(req) {
      const url = new URL(req.url);
      if (url.pathname === "/") return Response.json({ test: 1 });
      if (url.pathname === "/timeout") {
        await wait(2000);
        return Response.json({ test: 1 });
      }
      if (url.pathname === "/retry") {
        if (retry === 0) {
          retry = retry + 1;
          return new Response("busy !", { status: 429 });
        } else {
          return Response.json({ retryCount: retry });
        }
      }
      return new Response("404!", { status: 404 });
    },
  });
