import hello;
import std.stdio;
import std.json;

void main() {
    auto spec = buildGreetingSpec();
    auto json = specToJson(spec);
    writeln(json.toPrettyString());
}
