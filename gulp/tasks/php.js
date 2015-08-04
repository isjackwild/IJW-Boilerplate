var gulp = require('gulp');
var config = require('../config').php
var browserSync  = require('browser-sync');

gulp.task('php', function() {
  return gulp.src(config.src)
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload({stream:true}));
});
