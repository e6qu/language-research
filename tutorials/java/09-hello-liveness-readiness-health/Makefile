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
	@lsof -ti:4073 | xargs kill -9 2>/dev/null || true
	@sleep 1
	java -jar target/*-jar-with-dependencies.jar &
	@sleep 8
	curl -sf http://localhost:4073/health | grep -q "status"
	@pkill -f "jar-with-dependencies" 2>/dev/null || true
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
