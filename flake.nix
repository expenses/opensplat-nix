{
  description = "Flake utils demo";

  inputs = {
    opensplat-src = {
      url = "github:pierotofy/opensplat";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/345c263f2f53a3710abe117f28a5cb86d0ba4059";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      opensplat-src,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        build-simple-trainer = true;
      in
      {
        packages.default =
          with pkgs;
          stdenv.mkDerivation {
            name = "opensplat";
            src = opensplat-src;
            buildInputs = [
              cmake
              libtorch-bin
              opencv
              nlohmann_json
              cxxopts
              nanoflann
            ];
            cmakeFlags = [
              (lib.cmakeBool "OPENSPLAT_BUILD_SIMPLE_TRAINER" build-simple-trainer)
              (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
              (lib.cmakeFeature "GPU_RUNTIME" "")
            ];
            patches = [ ./patch ];
          };
      }
    );
}
