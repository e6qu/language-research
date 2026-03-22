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
	mvn -q exec:java -Dexec.mainClass="hello.Main" | grep -q "Hello"
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
