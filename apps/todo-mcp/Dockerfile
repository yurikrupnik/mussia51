# This file is generated by Nx.
#
# Build the docker image with `npx nx docker-build todo-mcp`.
# Tip: Modify "docker-build" options in project.json to change docker build args.
#
# Run the container with `docker run -p 3000:3000 -t todo-mcp`.
FROM docker.io/node:lts-alpine

ENV HOST=0.0.0.0
ENV PORT=3000

WORKDIR /app

RUN addgroup --system todo-mcp && \
          adduser --system -G todo-mcp todo-mcp

COPY dist/apps/todo-mcp todo-mcp/
RUN chown -R todo-mcp:todo-mcp .

# You can remove this install step if you build with `--bundle` option.
# The bundled output will include external dependencies.
RUN npm --prefix todo-mcp --omit=dev -f install

CMD [ "node", "todo-mcp" ]
