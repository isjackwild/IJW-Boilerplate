var gulp = require('gulp');
var gutil = require('gulp-util');
var config = require('../config');
var shelljs = require('shelljs');


gulp.task('stage', function () {

	var server = config.productionserver;

	gutil.log('stage to:', server.server);
    var command = 'rsync -rlDvz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress `source` root@`server`:`dest`'
    for (var i in server) command = command.replace(new RegExp('`'+i+'`','g'), server[i]);
    var ret = shelljs.exec(command, { silent: false });
    
    if (ret.code !=0) {
        // halt on error
        return gutil.log(ret.output);
    }
});


gulp.task('stageproduction', ['production'], function () {

	var server = config.productionserver;

	gutil.log('stage to:', server.server);
    var command = 'rsync -rlDvz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress `source` root@`server`:`dest`'
    for (var i in server) command = command.replace(new RegExp('`'+i+'`','g'), server[i]);
    var ret = shelljs.exec(command, { silent: false });
    
    if (ret.code !=0) {
        // halt on error
        return gutil.log(ret.output);
    }
});