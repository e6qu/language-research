.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	mvn compile

clean:
	mvn -q clean

test:
	mvn test

typecheck:
	mvn compile

e2e: build
	@lsof -ti:4072 | xargs kill 2>/dev/null || true
	java -cp target/*-jar-with-dependencies.jar hello.Main 4072 &
	@sleep 2
	curl -sf http://localhost:4072/api/openapi | grep -q "openapi"
	@pkill -f "hello.Main" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	mvn compile
	@echo "Fat JAR:"
	@ls -la target/*-jar-with-dependencies.jar 2>/dev/null || ls -la target/*.jar

lint:
	mvn compile -Xlint:all

autoformat:
	@echo "Use google-java-format or spotless plugin"

format-check:
	@echo "Use google-java-format or spotless plugin"
