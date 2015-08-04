
(function(win){
	
	win.Array.prototype.move = function (old_index, new_index) {
	    if (new_index >= this.length) {
	        var k = new_index - this.length;
	        while ((k--) + 1) {
	            this.push(undefined);
	        }
	    }
	    this.splice(new_index, 0, this.splice(old_index, 1)[0]);
	    return this; // for testing purposes
	};

	win.String.prototype.capitalize = function(){
       return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
      };

})(window)