{lib}: configurations:
lib.foldl' (acc: config: acc // config) {} configurations
