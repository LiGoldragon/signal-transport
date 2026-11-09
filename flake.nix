{
  description = "signal-transport - asynchronous Signal framing over tokio streams, for Nexus transports";

  inputs.base.url = "github:LiGoldragon/build-base";

  # Cargo.nix is generated from Cargo.lock by the build base's crate2nix and
  # committed, so evaluation imports no derivation:
  #   nix run github:LiGoldragon/build-base#crate2nix -- generate
  outputs =
    { self, base }:
    base.lib.workspaceOutputs {
      cargoNix = ./Cargo.nix;

      extraChecks =
        {
          pkgs,
          toolchain,
          clippy,
          ...
        }:
        let
          manifest = builtins.fromTOML (builtins.readFile ./Cargo.toml);
          rust = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [ ./src ./tests ];
          };
        in
        {
          fmt = pkgs.runCommand "signal-transport-fmt" { nativeBuildInputs = [ toolchain ]; } ''
            rustfmt --check --edition ${manifest.package.edition} ${rust}/src/lib.rs ${rust}/tests/*.rs
            touch $out
          '';
          # The test build compiled by clippy-driver under the crate's lints,
          # every target, warnings refused.
          clippy = clippy "signal-transport" [ "default" ] [ "-D" "warnings" ];
        };
    };
}
