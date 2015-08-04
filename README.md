FUTURECORP BOILER-PLATE
=======================


FutureCorp Boilerplate using the  [Gulp + Browserify project](http://viget.com/extend/gulp-browserify-starter-faq) and Wordpress. Check out the [Wiki](https://github.com/greypants/gulp-starter/wiki) for some good background knowledge.

Includes the following tools, tasks, and workflows:

- [Browserify](http://browserify.org/) (with [browserify-shim](https://github.com/thlorenz/browserify-shim))
- [Watchify](https://github.com/substack/watchify) (caching version of browserify for super fast rebuilds)
- [SASS](http://sass-lang.com/) (super fast libsass with [source maps](https://github.com/sindresorhus/gulp-ruby-sass#sourcemap), and [autoprefixer](https://github.com/sindresorhus/gulp-autoprefixer))
- [CoffeeScript](http://coffeescript.org/) (with source maps!)
- [BrowserSync](http://browsersync.io) for live reloading and a static server
- Error handling in the console [and in Notification Center](https://github.com/mikaelbr/gulp-notify)


If you've never used Node or npm before, you'll need to install Node.
If you use homebrew, do:

```
brew install node
```

Otherwise, you can download and install from [here](http://nodejs.org/download/).

### Install npm dependencies
```
npm install
```

### Start your MAMP (or similar) server

[Install MAMP if you don't have it](http://www.mamp.info/en/). Or you can use a similar server app if you prefer.

- Make sure the Document Root (found under Preferences > Apache) is set to the wordpress directory.
- In gulp/config you need to make sure your browserSync.proxy is set to your `localhost IP address` : `portNumber`
- *The MAMP server won't live-reload*. You need to visit through browsersync. Run `gulp` and it should open, or visit localhost:3000


### Run gulp.

```
gulp
```

This will run the `default` gulp task defined in `gulp/tasks/default.js`.


#### gulp production

There is also a `production` task you can run with `gulp production`, which will re-build optimized, compressed css and js files to the wordpress theme folder.

### Configuration
All paths and plugin settings have been abstracted into a centralized config object in `gulp/config.js`.


## Folder structure

Work within the src folder for all of the themes templates, scripts and styles.

```
root
|	gulpfile.js     						# Base [Gulp](http://gulpjs.com/) file. Will pull in all tasks from /gulp/tasks
|	package.json     						# Package for [NPM](https://docs.npmjs.com/)
|___gulp     								# [Read: Gulp + Browserify project](http://viget.com/extend/gulp-browserify-starter-faq)
|
|___src    									# Work on the Wordpress template in here. All styles, templates and scripts. Compiles to the template file
|	|___fonts
|	|___htdocs     							# Template files.
|	|___icons
|	|___images		
|	|___javascript
|	|	|	Controller.coffee     			# Site controller. Inits the Router
|	|	|	Router.coffee    				# Routing
|	|	|	main.coffee     				# Setup namespace. Init Controller
|	|	|
|	|	|___modules     					# Our modules in here
|	|	|___vendor     						# External libraries for inclusion go in here
|	|
|	|___sass
|		|	global.sass     				# Global styles, site scaffolding. Keep this small.
|		|	style.sass     					# Import and concat everything here. Compiles everything to one CSS file for the theme
|		|	typography.sass     			# Typography styles here. But not typography layout.
|		|	shame.sass     					# Hot fixes. Added at the end. Shouldn't have more than a few rules. Ideally should be empty! Anything added here shouldn't stay here long.
|		|
|		|___modules     					# Styles for modules
|		|___template-layouts     			# Styles for page layouts
|		|___variables
|			|
|			|	_media-queries.scss
|			|	_vars_transitions.scss     	# Timings, easings, etc.
|			|	_vars_colours.scss
|			|	_vars_layout.scss     		# Margins, grids, etc.
|			|	_variables.scss     		# All variables are gathered together in here, for easy conclusion
|
|___wordpress     							# Wordpress stuff goes here. Src will compile to template folder  
```

### Sass

`/src/sass`

- Module styles are in `/modules`
- Template layout styles are in `/template-layouts`
- `global.sass` contains global styles and layout scaffolding
- `typography.sass` contains typography, but not typographic layout, which should be in the relevant module or page-template file
- `shame.sass` contains any hot-fixes. They should only be temporary, and ideallyt this file should be empty. If it's more than can fit in one window, something is wrong!
- `style.sass` includes all other stylus files and is used to build the main stylesheet which is linked to the theme. Any new module or template needs to be added into this file


#### Variables (including Media Queries)

Variables are in the `/variables` directory
All variables are compiled to `_variables.sass`, for easy including in other sass files. You should only ever have to include `_variables.sass` in other style files

#### Responsive Grid

We have a reponsive grid setup with variables and mixins calculated to help us. Take a look at `/variables/_vars-layout.sass` to see how this works, with example usage. There's an Illustrator file with variable naming references... they're colour coded rather than numbered, in case we need to add in extra columns and margins.



### Javascript (Coffee)

`/src/javascript`

- We use Browserify to include modules
- Module logic is in `/modules`
- External libraries are in `/vendor`
- `Controller.coffee` is the app controller
- `Router.coffee` is the router, which is instantiated in the controller. This han
dles the hyperlinks, history-states and ajax requests, adds / removes page modules, and kicks off lazy-loading. Sometimes it makes sense to do ajax-y stuff outside of the router, so for the sake of keeping it clean, that's okay. For example, pre-loading the next page in the continuous scroll module is not done here.
- `main.coffee` includes all modules and dependencies and is used to build the main js which is linked to the theme.

There's an example module class `ExampleModule.coffee`, which is commented, and can be used as a boilerplate if needed.


#### Libraries
- [PubSub](https://github.com/mroderick/PubSubJS) pub/sub events
- [Gator](craig.is/riding/gators) for event delegation
- [Q](https://github.com/kriskowal/q) for promises
- [Lodash](https://lodash.com) utilities library, which we're mainly using for debouncing
- [Classie](https://github.com/desandro/classie) to add / remove / check classes
- [jQuery](http://jquery.com/) mainly for ajax




### Markup

`/src/ht-docs`

Contains all the markup templates


###Wordpress

`/wordpress` is where the wordpress CMS lives. Everything from `/src` is compiled into the wordpress theme (specified in `/gulp/congif.js`)


## Staging

To do
