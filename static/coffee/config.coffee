require.config
  baseUrl:"js"
  paths:
    "jQuery":"lib/jquery"
    "underscore":"lib/underscore"
    "Backbone":"lib/backbone"

  shim:
    "jQuery":
      exports:"jQuery"
    "underscore":
      exports:"_"
    "Backbone":
      deps:["underscore","jQuery"]
      exports:"Backbone"
    "lib/jquery.transit":
      deps:["jQuery"]