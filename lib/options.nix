{lib}: {
  # Create an "enable" option with default value and description
  mkEnableOption = description:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable ${description}.";
    };

  # Create a boolean option with specified default and description
  mkBoolOpt = {
    default ? false,
    description,
  }:
    lib.mkOption {
      type = lib.types.bool;
      inherit default description;
    };

  # Create a string option with specified default and description
  mkStrOpt = {
    default ? "",
    description,
  }:
    lib.mkOption {
      type = lib.types.str;
      inherit default description;
    };

  # Create a port number option with default and description
  mkPortOpt = {
    default,
    description,
  }:
    lib.mkOption {
      type = lib.types.port;
      inherit default description;
    };

  # Create an enum option with specified values
  mkEnumOpt = {
    default,
    values,
    description,
  }:
    lib.mkOption {
      type = lib.types.enum values;
      inherit default description;
    };

  # Create a nullable option
  mkNullableOpt = type: {
    default ? null,
    description,
  }:
    lib.mkOption {
      type = lib.types.nullOr type;
      inherit default description;
    };

  # Create an attribute set option
  mkAttrsOpt = {
    default ? {},
    description,
  }:
    lib.mkOption {
      type = lib.types.attrs;
      inherit default description;
    };

  # Create an integer option
  mkIntOpt = {
    default,
    description,
  }:
    lib.mkOption {
      type = lib.types.int;
      inherit default description;
    };

  # Create a path option
  mkPathOpt = {
    default,
    description,
  }:
    lib.mkOption {
      type = lib.types.path;
      inherit default description;
    };
}
