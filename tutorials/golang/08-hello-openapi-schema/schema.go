package main

// OpenAPI spec types modeled as Go structs.

type OpenAPISpec struct {
	OpenAPI string              `json:"openapi"`
	Info    Info                `json:"info"`
	Paths   map[string]PathItem `json:"paths"`
}

type Info struct {
	Title   string `json:"title"`
	Version string `json:"version"`
}

type PathItem struct {
	Get  *Operation `json:"get,omitempty"`
	Post *Operation `json:"post,omitempty"`
}

type Operation struct {
	Summary     string              `json:"summary"`
	OperationID string              `json:"operationId"`
	Parameters  []Parameter         `json:"parameters,omitempty"`
	Responses   map[string]Response `json:"responses"`
}

type Parameter struct {
	Name     string `json:"name"`
	In       string `json:"in"`
	Required bool   `json:"required"`
	Schema   Schema `json:"schema"`
}

type Schema struct {
	Type       string            `json:"type"`
	Properties map[string]Schema `json:"properties,omitempty"`
	Required   []string          `json:"required,omitempty"`
}

type Response struct {
	Description string `json:"description"`
}

// BuildSpec constructs the OpenAPI spec for our API.
func BuildSpec() OpenAPISpec {
	return OpenAPISpec{
		OpenAPI: "3.0.3",
		Info: Info{
			Title:   "Hello API",
			Version: "1.0.0",
		},
		Paths: map[string]PathItem{
			"/": {
				Get: &Operation{
					Summary:     "Root endpoint",
					OperationID: "getRoot",
					Responses: map[string]Response{
						"200": {Description: "Greeting response"},
					},
				},
			},
			"/greet/{name}": {
				Get: &Operation{
					Summary:     "Greet by name",
					OperationID: "greetByName",
					Parameters: []Parameter{
						{
							Name:     "name",
							In:       "path",
							Required: true,
							Schema:   Schema{Type: "string"},
						},
					},
					Responses: map[string]Response{
						"200": {Description: "Greeting response"},
						"400": {Description: "Invalid request"},
					},
				},
			},
			"/greet": {
				Post: &Operation{
					Summary:     "Greet via POST body",
					OperationID: "greetPost",
					Responses: map[string]Response{
						"200": {Description: "Greeting response"},
						"400": {Description: "Invalid request body"},
					},
				},
			},
		},
	}
}
