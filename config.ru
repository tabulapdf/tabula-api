require 'lib/tabula_api'
use Rack::Sendfile
run TabulaApi::REST
