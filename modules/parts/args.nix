{ inputs, self, ... }:
{
  _module.args = {
    inherit inputs self;
  };
}
