{
  description = "Java Spring Boot tutorial development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            jdk21
            maven
            curl
            jq
            python3
          ];

          shellHook = ''
            echo "Java $(java --version 2>&1 | head -1)"
            echo "Maven $(mvn --version 2>&1 | head -1)"
          '';
        };
      });
}
