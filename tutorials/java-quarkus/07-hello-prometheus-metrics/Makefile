.PHONY: build clean test typecheck e2e fatbin native lint autoformat format-check

build:
	mvn -q package -DskipTests -Dquarkus.package.jar.type=uber-jar

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
	curl -sf http://localhost:8080/q/metrics | grep -q "greetings_total"
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

lint:
	mvn -q compile

autoformat:
	@echo "Use spotless plugin"

format-check:
	@echo "Use spotless plugin"
