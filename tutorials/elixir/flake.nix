{
  description = "Elixir tutorial development environment";

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
            elixir_1_17
            erlang_27
            rebar3
            hex
            curl
            jq
          ];

          shellHook = ''
            echo "Elixir $(elixir --version | tail -1)"
            echo "Erlang/OTP $(erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().')"
            export MIX_HOME="$PWD/.mix"
            export HEX_HOME="$PWD/.hex"
            mix local.hex --force --if-missing > /dev/null 2>&1
            mix local.rebar --force --if-missing > /dev/null 2>&1
          '';
        };
      });
}
