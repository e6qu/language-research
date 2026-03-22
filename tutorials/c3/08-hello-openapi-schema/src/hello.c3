module hello_openapi;
import std::io;

// Hand-build an OpenAPI 3.0 spec as a string.
// C3 does not yet have JSON libraries, so we emit it directly.

const char[] OPENAPI_SPEC =
`{
  "openapi": "3.0.3",
  "info": {
    "title": "Hello C3 API",
    "version": "0.1.0",
    "description": "A minimal greeting API"
  },
  "paths": {
    "/greet": {
      "get": {
        "summary": "Greet a user",
        "parameters": [
          {
            "name": "name",
            "in": "query",
            "required": false,
            "schema": { "type": "string", "default": "World" }
          }
        ],
        "responses": {
          "200": {
            "description": "Successful greeting",
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "message": { "type": "string" }
                  }
                }
              }
            }
          }
        }
      }
    },
    "/health": {
      "get": {
        "summary": "Health check",
        "responses": {
          "200": {
            "description": "Healthy",
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "status": { "type": "string" }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}`;

fn char[] get_spec() {
    return OPENAPI_SPEC;
}
