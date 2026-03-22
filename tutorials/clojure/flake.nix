{
  description = "Clojure tutorial development environment";

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
            clojure
            leiningen
            jdk21
            curl
            jq
            python3
          ];

          shellHook = ''
            echo "Clojure $(clj --version 2>&1)"
            echo "Leiningen $(lein version 2>&1 | head -1)"
            echo "Java $(java --version 2>&1 | head -1)"
          '';
        };
      });
}
