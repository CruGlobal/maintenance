// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "jquery"
import "bootstrap"
import "chosen-js"
import "tether"
import "validations"

var event = new CustomEvent("modulesLoaded");
document.dispatchEvent(event);
