{
  description = "C3 tutorial development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ curl jq python3 ];
          shellHook = ''
            echo "C3 compiler (c3c) must be installed from https://c3-lang.org"
            which c3c > /dev/null 2>&1 && echo "c3c $(c3c --version 2>&1 | head -1)" || echo "c3c not found"
          '';
        };
      });
}
