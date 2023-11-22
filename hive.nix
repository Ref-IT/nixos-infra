inputs:

{
  meta = {
    description = "StuRa Ilmenau nixfiles";

    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [];
    };

    specialArgs = { inherit inputs; };
  };

  defaults = ./common;

  # hosts
  majestix = ./hosts/majestix;
  miraculix = ./hosts/miraculix;
  obelix = ./hosts/obelix;
}