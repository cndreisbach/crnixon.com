require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'nesta/app'

Nesta::App.root = ::File.expand_path('.', ::File.dirname(__FILE__))
use Rack::Static, :urls => ["/js", "/img"], :root => "public"
run Nesta::App
