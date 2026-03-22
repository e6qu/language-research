.PHONY: build clean test typecheck e2e fatbin

build:
	perl -c lib/OpenApiSpec.pm

clean:
	rm -f *.out

test:
	prove -v t/

typecheck:
	perl -c lib/OpenApiSpec.pm

e2e: build
	perl -Ilib -MOpenApiSpec -e 'print OpenApiSpec::to_json()' | grep -q "openapi"
	@echo "e2e passed"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o openapi lib/OpenApiSpec.pm"
