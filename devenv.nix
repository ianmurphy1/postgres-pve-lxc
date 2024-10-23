{ pkgs, stdenv, lib, config, inputs, ... }:
{
  # https://devenv.sh/basics/
  env.REQUESTS_CA_BUNDLE = "/home/ian/.step/certs/root_ca.crt";

  # https://devenv.sh/packages/
  packages = [
    pkgs.nixos-generators
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages = {
    terraform.enable = true;
  };

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
