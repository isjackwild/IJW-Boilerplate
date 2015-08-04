var dest = "./www";
var src = './src';

module.exports = {
  browserSync: {
    proxy: "127.0.0.1:8888" // Make this your localhost IP:port
    // proxy: "192.168.1.185:8888" // Make this your localhost IP:port
    // server: {
    //   // Serve up our build folder
    //   baseDir: dest
    // }
  },
  sass: {
    //compile this file to CSS
    src: src + "/sass/style.sass",
    //watch for changes in any of the Sass files
    watchSrc: src + "/sass/**",
    dest: dest,
    sourceComments: "normal",
    settings: {
      indentedSyntax: true, // Enable .sass syntax!
      imagePath: 'images' // Used by the image-url helper
    }
  },
  images: {
    src: src + "/images/**",
    dest: dest + "/images"
  },
  markup: {
    src: src + "/htdocs/**",
    dest: dest
  },
  php: {
    src: src + "/php/**",
    dest: dest
  },
  iconFonts: {
    name: 'Gulp Starter Icons',
    src: src + '/icons/*.svg',
    dest: dest + '/fonts',
    sassDest: src + '/sass',
    template: './gulp/tasks/iconFont/template.sass.swig',
    sassOutputName: '_icons.sass',
    fontPath: 'fonts',
    className: 'icon',
    options: {
      fontName: 'Post-Creator-Icons',
      appendCodepoints: true,
      normalize: false
    }
  },
  fonts: {
    src: src + '/fonts/**',
    dest: dest + '/fonts'
  },
  browserify: {
    // A separate bundle will be generated for each
    // bundle config in the list below
    bundleConfigs: [{
      entries: src + '/javascript/main.coffee',
      dest: dest,
      outputName: 'main.js',
      // Additional file extentions to make optional
      extensions: ['.coffee'],
      // list of modules to make require-able externally
      require: ['jquery'] // Do we need this!?
    }]
  },
  production: {
    cssSrc: dest + '/*.css',
    jsSrc: dest + '/*.js',
    dest: dest
  },
  stagingserver: {
    server: null,
    source: 'wordpress/wp-content/themes/OKA-wp-theme/*',
    dest: '/var/www/html/wp-content/themes/OKA-wp-theme/'
  },
  productionserver: {
    server: null,
    source: 'wordpress/wp-content/themes/OKA-wp-theme/*',
    dest: '/var/www/html/wp-content/themes/OKA-wp-theme/'
  }
};
