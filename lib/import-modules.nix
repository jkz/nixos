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