module.exports =
  dist:
    options:
      baseUrl: "./app/scripts"
      mainConfigFile: "./app/scripts/main.js"
      out: "./dist/scripts/robe.js"
      name: "robe"

      removeCombined: true
      findNestedDependencies: true
      fileExclusionRegExp: /^\./
