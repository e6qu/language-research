.PHONY: build clean test typecheck e2e fatbin native

build:
	mvn -q compile

clean:
	mvn -q clean

test:
	mvn -q test

typecheck:
	mvn -q compile

e2e: fatbin
	java -jar target/quarkus-app/quarkus-run.jar &
	sleep 3
	curl -sf http://localhost:8080/ | grep -q "Hello"
	curl -sf http://localhost:8080/q/openapi | grep -q "openapi"
	kill %1 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	mvn -q package -DskipTests
	@echo "Fat JAR (Quarkus fast-jar):"
	@ls -la target/quarkus-app/quarkus-run.jar

native:
	mvn -q package -Dnative -DskipTests -Dquarkus.native.container-build=true
	@echo "Native binary:"
	@ls -la target/*-runner
