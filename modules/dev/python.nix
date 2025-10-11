{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python312
    python312Packages.pip
    python312Packages.virtualenv
    python312Packages.setuptools
    python312Packages.wheel
    poetry
    jupyter
    black
    pylint
  ];

  environment.variables.PYTHONPATH = "/usr/lib/python3.12/site-packages";
}
