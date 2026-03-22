{
  description = "Elm tutorial development environment";

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
            elmPackages.elm
            elmPackages.elm-test
            elmPackages.elm-format
            nodejs_20
            python3  # for http.server in demos
          ];

          shellHook = ''
            echo "Elm $(elm --version)"
            echo "Node $(node --version)"
            echo "elm-test $(elm-test --version 2>/dev/null || echo 'available')"
          '';
        };
      });
}
