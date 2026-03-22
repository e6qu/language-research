.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	mvn -q package -DskipTests

clean:
	mvn -q clean

test:
	mvn -q test

typecheck:
	mvn -q compile

e2e: build
	@lsof -ti:4083 | xargs kill 2>/dev/null || true
	java -jar target/*.jar &
	@sleep 10
	curl -sf http://localhost:4083/actuator/health | grep -q "status"
	@pkill -f "target/.*jar" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	mvn -q package -DskipTests
	@echo "Fat JAR:"
	@ls -la target/*.jar | grep -v original

lint:
	mvn -q compile

autoformat:
	@echo "Use spotless plugin"

format-check:
	@echo "Use spotless plugin"
