module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    banner: 
        js: '/**\n' +
              '* <%= pkg.name %>.js v<%= pkg.version %> by @nurcahyo \n' +
              '* Copyright <%= grunt.template.today("yyyy") %> <%= pkg.author %>\n' +
              '* <%= _.pluck(pkg.licenses, "url").join(", ") %>\n' +
              '*/\n'
        css: '/**\n' +
              '* <%= pkg.name %>.css v<%= pkg.version %> by @nurcahyo \n' +
              '* Copyright <%= grunt.template.today("yyyy") %> <%= pkg.author %>\n' +
              '* <%= _.pluck(pkg.licenses, "url").join(", ") %>\n' +
              '*/\n'
    concat:
      js:
        options:
          stripBanners: true
          banner: '<%= banner.js %>'
        src: ['dist/js/<%= pkg.name %>.js']
        dest: 'dist/js/<%= pkg.name %>.js'
      css:
        options:
          stripBanners: true
          banner: '<%= banner.css %>'
        files: 
          'dist/css/<%= pkg.name %>.css':['dist/css/<%= pkg.name %>.css']
          'dist/css/<%= pkg.name %>.min.css':['dist/css/<%= pkg.name %>.min.css']
    ##uglify js minifier
    uglify:
      options:
        compress: true
        preserveComments: "all"
      lib:
        files:
          'dist/js/<%= pkg.name %>.min.js': ['dist/js/<%= pkg.name %>.js']

    # Less compiler
    less:
      development:
        options:
            outputSourceFiles: true
        files:
          "dist/css/<%= pkg.name %>.css": "src/less/<%= pkg.name %>.less"
      production:
        options:
          cleancss:true
          compress: true
          yuicompress: true
          optimization: 2
        files:
          "dist/css/<%= pkg.name %>.min.css": "src/less/<%= pkg.name %>.less"
    # Coffee compiler
    coffee:
      lib:
        options:
          bare: false
          join: true
        expand: true
        files: 
          'dist/js/<%= pkg.name %>.js': 'src/coffee/*.coffee'
        ext: '.js'
    # watcher
    watch:
      lib:
        files: ['src/**/*.coffee']
        tasks: ['coffee','concat:js','uglify:lib']
      style:
        files: ["src/**/*.less"]
        tasks: ['less','concat:css']

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  
  # Default task.
  grunt.registerTask 'default', ['coffee']