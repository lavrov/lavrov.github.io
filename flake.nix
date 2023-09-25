{
  outputs = { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default =
        pkgs.mkShell {
          packages = [
            pkgs.bundler
            pkgs.rubyPackages.github-pages
          ];
        };
    };
}
