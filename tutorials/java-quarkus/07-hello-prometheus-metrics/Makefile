.PHONY: build clean test typecheck e2e fatbin native lint autoformat format-check

build:
	mvn -q package -DskipTests

clean:
	mvn -q clean

test:
	mvn -q test

typecheck:
	mvn -q compile

e2e: build
	@lsof -ti:4091 | xargs kill -9 2>/dev/null || true
	@sleep 1
	java -jar target/quarkus-app/quarkus-run.jar &
	@sleep 12
	curl -sf http://localhost:4091/work > /dev/null
	curl -sf http://localhost:4091/q/metrics | grep -q "work"
	@pkill -f "quarkus-run" 2>/dev/null || true
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
