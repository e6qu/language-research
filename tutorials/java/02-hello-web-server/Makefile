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
	@lsof -ti:8080 | xargs kill 2>/dev/null || true
	@sleep 1
	java -cp target/*-jar-with-dependencies.jar hello.Main 8080 &
	@sleep 2
	curl -s http://localhost:8080/ | grep -q "Hello"
	curl -s http://localhost:8080/greet/Test | grep -q "Hello, Test!"
	@kill %1 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	mvn -q package -DskipTests
	@echo "Fat JAR:"
	@ls -la target/*-jar-with-dependencies.jar 2>/dev/null || ls -la target/*.jar

lint:
	mvn -q compile -Xlint:all

autoformat:
	@echo "Use google-java-format or spotless plugin"

format-check:
	@echo "Use google-java-format or spotless plugin"
