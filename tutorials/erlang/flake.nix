{
  description = "Erlang tutorial development environment";

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
            erlang_27
            rebar3
            curl
            jq
          ];

          shellHook = ''
            echo "Erlang/OTP $(erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().')"
            echo "Rebar3 $(rebar3 version 2>/dev/null | head -1)"
          '';
        };
      });
}
