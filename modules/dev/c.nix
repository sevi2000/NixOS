{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gcc gdb cmake make clang clang-tools-extra llvm
  ];
}

