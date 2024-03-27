# This was a nice little exercise to get familiar with defining and using functions
# Whether it should exist is a second point;
# On the one hand it encourages a pattern for module definitions,
# on the other hand it makes that structure implicit, which makes things harder for newcomers
# e.g. If you see that a module is being imported like this
#  (import ./module.nix).someAttribute you know that the module has other things going for it
attr: args:
  map (arg: 
    if builtins.isString arg || builtins.isPath arg
      # If it's a string we try to import it
      then
        let 
          maybe-module = (import arg);
        in 
          if maybe-module ? ${attr}
            # if them imported set has the given attribute, we use it
            then maybe-module.${attr}
            # otherwise we return the path itself and let the user handle it
            else arg
      # Otherwise string we assume it's an inline module
      else arg
  ) args