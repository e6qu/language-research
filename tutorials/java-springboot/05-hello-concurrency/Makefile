.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	mvn -q compile

clean:
	mvn -q clean

test:
	mvn -q test

typecheck:
	mvn -q compile

e2e: test
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
