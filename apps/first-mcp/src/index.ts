import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
// import {Effect} from "effect";
// import {  } from "@effect/schema";

// const NWS_API_BASE = "https://api.weather.gov";
const NWS_API_BASE = "http://localhost:8080/api/todo";
const USER_AGENT = "todo-app/1.0";

// Create server instance
const server = new McpServer({
  name: "todo",
  version: "1.0.0",
});

// todo - change regular fetch to effect.
// function getData(url: string, method: string = "GET", body?: any) {
//   const headers = {
//     "User-Agent": USER_AGENT,
//     Accept: "application/json",
//   };
//   return Effect.gen(function* (_) {
//     const response = yield* _(
//       Effect.tryPromise(() => fetch(url, { headers, body, method }))
//     )
//     if (!response.ok) {
//       return yield* Effect.fail("Failed with response")
//     }
//     const data = yield* _(Effect.tryPromise(() => response.json()))
//     return data;
//   });
// }

// Helper function for making NWS API requests
async function makeNWSRequest<T>(
  url: string,
  method = "GET",
  body?: any,
): Promise<T | null> {
  const headers = {
    "User-Agent": USER_AGENT,
    Accept: "application/json",
  };

  try {
    const response = await fetch(url, { headers, body, method });
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return (await response.json()) as T;
  } catch (error) {
    console.error("Error making NWS request:", error);
    return null;
  }
}

// Register todo tools
server.tool("get-todos", "Get info about todos items", async () => {
  const todos = await makeNWSRequest(NWS_API_BASE);
  return {
    content: [
      {
        type: "text",
        text: JSON.stringify(todos),
      },
    ],
  };
});

server.tool(
  "get-todo",
  "Get info about specific todo item",
  {
    id: z.string(),
  },
  async ({ id }) => {
    // add logic
    const todo: any = await makeNWSRequest(`${NWS_API_BASE}/${id}`);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(todo),
        },
      ],
    };
  },
);

// todos tools
server.tool(
  "add-todo",
  "Add a new todo",
  {
    text: z.string(),
  },
  async ({ text }) => {
    // add logic
    const todo: any = await makeNWSRequest(NWS_API_BASE, "POST", { text });
    return {
      content: [
        {
          type: "text",
          text: `${text} was added to our to todo with ID ${todo.id}`,
        },
      ],
    };
  },
);

server.tool(
  "remove-todo",
  "Get info about the DB and collection",
  {
    id: z.string(),
  },
  async ({ id }) => {
    // add logic
    const todo: any = await makeNWSRequest(`${NWS_API_BASE}/${id}`, "DELETE");
    if (todo.status) {
      console.log("all good");
    }
    return {
      content: [
        {
          type: "text",
          text: `Todo with the id: ${id} was deleted`,
        },
      ],
    };
  },
);

server.tool(
  "do-shit",
  "Testing some shit",
  {
    id: z.string(),
  },
  async ({ id }) => {
    // add logic
    // const todo: any = await makeNWSRequest(`${NWS_API_BASE}/${id}`, "DELETE");
    // if (todo.status) {
    //   console.log('all good');
    // }
    return {
      content: [
        {
          type: "text",
          text: "Some shit returned",
        },
      ],
    };
  },
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Weather MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error in main():", error);
  process.exit(1);
});
