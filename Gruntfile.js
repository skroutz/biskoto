module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    bower: {
      install: {
        options:{
          install        : true,
          copy           : false,
          cleanTargetDir : false,
          cleanBowerDir  : false
        }
      }
    },

    bump: {
      options: {
        files: [
          'bower.json',
          'package.json'
        ],
        commitFiles: [
          'bower.json',
          'package.json'
        ],
        pushTo: 'origin',
      }
    },

    karma: {
      options: {
        configFile: 'karma.conf.js',
      },
      background: {
        background: true
      },
      single: {
        browsers: ['PhantomJS'],
        logLevel: 'ERROR',
        singleRun: true
      },
    },

    watch: {
      options: {
        livereload: true,
      },
      specs:{
        files: [
          'spec/**/*_spec.coffee',
        ],
        tasks: [
          'run_tests',
        ]
      },
      coffee:{
        files: [
          'coffee/**/*.coffee',
        ],
        tasks: [
          'build',
        ]
      }
    },

    coffee: {
      options: {
        bare: true
      },
      dist: {
        expand: true,
        extDot: 'last',
        cwd: 'coffee',
        src: [
          '**/*.coffee',
        ],
        dest: 'dist/',
        ext: '.js'
      },
    },

    uglify: {
      options: {
        mangle: false,
        beautify: {
          ascii_only: true
        },
        preserveComments: false,
        report: "min",
        compress: {
          hoist_funs: false,
          loops: false,
          unused: false
        }
      },
      js: {
        files: [{
          expand: true,
          cwd: 'dist',
          extDot: 'last',
          src: [
            '**/*.js',
            '!**/*.min.js',
          ],
          dest: 'dist',
          ext: '.min.js'
        }]
      }
    }
  });

  require('load-grunt-tasks')(grunt);

  grunt.registerTask('build', [
    'coffee:dist',
    'uglify:js'
  ]);

  //TEST TASKS
  grunt.registerTask('start_test_server', ['karma:background:start']);
  grunt.registerTask('run_tests', ['karma:background:run']);


  grunt.registerTask('default', [
    'start_test_server',
    'watch',
  ]);

  grunt.registerTask('test', [
    'bower:install',
    'karma:single'
  ]);
};
