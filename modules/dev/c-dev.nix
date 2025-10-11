{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    gdb
    cmake
    make
    clang
    llvm
    valgrind
    pkg-config
  ];

  environment.variables.CC = "gcc";
}
