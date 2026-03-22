module hello;

import std.json;
import std.array : appender;

struct SchemaProperty {
    string name;
    string type;
    string description;
    bool required;
}

struct Schema {
    string name;
    SchemaProperty[] properties;
}

struct Endpoint {
    string path;
    string method;
    string summary;
    string responseSchema;
    int responseCode;
}

struct OpenApiSpec {
    string title;
    string ver;
    string description;
    Endpoint[] endpoints;
    Schema[] schemas;
}

JSONValue propertyToJson(SchemaProperty p) {
    JSONValue j = JSONValue.emptyObject;
    j["type"] = p.type;
    if (p.description.length > 0) {
        j["description"] = p.description;
    }
    return j;
}

JSONValue schemaToJson(Schema s) {
    JSONValue j = JSONValue.emptyObject;
    j["type"] = "object";
    JSONValue props = JSONValue.emptyObject;
    JSONValue[] req;

    foreach (p; s.properties) {
        props[p.name] = propertyToJson(p);
        if (p.required) {
            req ~= JSONValue(p.name);
        }
    }
    j["properties"] = props;
    if (req.length > 0) {
        j["required"] = JSONValue(req);
    }
    return j;
}

JSONValue specToJson(OpenApiSpec spec) {
    JSONValue root = JSONValue.emptyObject;
    root["openapi"] = "3.0.0";

    JSONValue info = JSONValue.emptyObject;
    info["title"] = spec.title;
    info["version"] = spec.ver;
    info["description"] = spec.description;
    root["info"] = info;

    JSONValue paths = JSONValue.emptyObject;
    foreach (ep; spec.endpoints) {
        if (ep.path !in paths) {
            paths[ep.path] = JSONValue.emptyObject;
        }

        JSONValue op = JSONValue.emptyObject;
        op["summary"] = ep.summary;

        JSONValue resp = JSONValue.emptyObject;
        import std.conv : to;
        JSONValue respDetail = JSONValue.emptyObject;
        respDetail["description"] = ep.summary;

        if (ep.responseSchema.length > 0) {
            JSONValue content = JSONValue.emptyObject;
            JSONValue mediaType = JSONValue.emptyObject;
            JSONValue schemaRef = JSONValue.emptyObject;
            schemaRef["$ref"] = "#/components/schemas/" ~ ep.responseSchema;
            mediaType["schema"] = schemaRef;
            content["application/json"] = mediaType;
            respDetail["content"] = content;
        }

        resp[ep.responseCode.to!string] = respDetail;
        op["responses"] = resp;
        paths[ep.path][ep.method] = op;
    }
    root["paths"] = paths;

    if (spec.schemas.length > 0) {
        JSONValue components = JSONValue.emptyObject;
        JSONValue schemasJson = JSONValue.emptyObject;
        foreach (s; spec.schemas) {
            schemasJson[s.name] = schemaToJson(s);
        }
        components["schemas"] = schemasJson;
        root["components"] = components;
    }

    return root;
}

OpenApiSpec buildGreetingSpec() {
    Schema greetingSchema;
    greetingSchema.name = "Greeting";
    greetingSchema.properties = [
        SchemaProperty("message", "string", "The greeting message", true),
        SchemaProperty("timestamp", "string", "ISO 8601 timestamp", true),
    ];

    Schema healthSchema;
    healthSchema.name = "Health";
    healthSchema.properties = [
        SchemaProperty("status", "string", "Service status", true),
    ];

    return OpenApiSpec(
        "Hello API",
        "1.0.0",
        "A minimal greeting API",
        [
            Endpoint("/greet", "get", "Get a greeting", "Greeting", 200),
            Endpoint("/health", "get", "Health check", "Health", 200),
        ],
        [greetingSchema, healthSchema],
    );
}

unittest {
    auto spec = buildGreetingSpec();
    assert(spec.title == "Hello API");
    assert(spec.endpoints.length == 2);
    assert(spec.schemas.length == 2);

    auto json = specToJson(spec);
    assert(json["openapi"].str == "3.0.0");
    assert(json["info"]["title"].str == "Hello API");
    assert("paths" in json);
    assert("/greet" in json["paths"]);
    assert("components" in json);
    assert("Greeting" in json["components"]["schemas"]);

    auto greetSchema = schemaToJson(spec.schemas[0]);
    assert(greetSchema["type"].str == "object");
    assert("message" in greetSchema["properties"]);
    assert("required" in greetSchema);

    auto prop = propertyToJson(spec.schemas[0].properties[0]);
    assert(prop["type"].str == "string");
}
