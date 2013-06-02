module.exports = (grunt) ->
  grunt.initConfig
    components: "components"

    resource:
      path:"www"
      js: "<%= resource.path %>/js"
      css: "<%= resource.path %>/css"
      less: "<%= resource.path %>/less"
      img: "<%= resource.path %>/img"
      font: "<%= resource.path %>/font"
      build: "<%= resource.path %>/build"


    copy:
      img: files: [
        flatten: true
        expand: true
        src: "*"
        cwd: "static/img"
        dest: "<%= resource.img %>/"
      ,
        flatten: true
        expand: true
        src: "*"
        cwd: "maket/"
        dest: "<%= resource.img %>/maket/"
      ]
      jquery: files: [
        flatten: true
        expand: true
        src: "jquery.js"
        cwd: "<%= components %>/jquery/"
        dest: "<%= resource.js %>/lib/"
      ]
      requirejs: files: [
        flatten: true
        expand: true
        src: "require.js"
        cwd: "<%= components %>/requirejs/"
        dest: "<%= resource.js %>/lib/"
      ]
      html: files:[
        flatten: true
        expand: true
        src: "*.html"
        cwd: "static/html/"
        dest: "<%= resource.path %>/"
      ]
      backboneunderscore:files:[
        flattern: true
        expand: true
        src: "backbone.js"
        cwd: "<%= components %>/backbone/"
        dest: "<%= resource.js %>/lib/"
      ,
        flattern: true
        expand: true
        src: "underscore.js"
        cwd: "<%= components %>/underscore"
        dest: "<%= resource.js %>/lib/"
      ]

    less:
      common:
        files:
          "<%= resource.css %>/style.css": "static/less/style.less"

    coffee:
      common:
        expand: true
        src: ["*.coffee", "**/*.coffee", "**/**/*.coffee"]
        cwd: "static/coffee/"
        dest: "<%= resource.js %>/"
        rename: (dest, filename, orig)->
          dest + filename.replace /\.coffee$/g, ".js"
        options:
          bare: true

    requirejs:
      common:
        options:
          name: "main"
          baseUrl: "<%= resource.js %>/"
          mainConfigFile: "<%= resource.js %>/config.js"
          out: "<%= resource.build %>/main.min.js"

    connect:
      server:
        options:
          port: 9002,
          base: 'www'

    watch:
      html:
        files: "static/html/*.html"
        tasks: ["copy:html"]
      coffee:
        files: ["static/coffee/*.coffee","static/coffee/**/*.coffee"]
        tasks: ["coffee"]
      less:
        files: "static/less/*.less"
        tasks: ["less"]

  grunt.registerTask "default", ["copy", "coffee", "less", "connect", "watch"]
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-text-replace"