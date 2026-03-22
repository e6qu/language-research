{
  description = "Lua tutorial development environment";

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
            lua5_4
            luarocks
            curl
            jq
            python3
          ];

          shellHook = ''
            echo "Lua $(lua -v 2>&1 | head -1)"
            echo "LuaRocks $(luarocks --version 2>&1 | head -1)"
            eval $(luarocks path --bin 2>/dev/null)
            luarocks install busted --local 2>/dev/null || true
            luarocks install dkjson --local 2>/dev/null || true
            luarocks install luasocket --local 2>/dev/null || true
          '';
        };
      });
}
