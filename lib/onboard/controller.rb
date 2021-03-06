# encoding: utf-8

require 'rubygems'
require 'thin' 
require 'sinatra/base'
require 'erubis'

require 'onboard/extensions/sinatra/base'
require 'onboard/extensions/sinatra/templates'

require 'onboard/controller/auth'
require 'onboard/controller/error'
require 'onboard/controller/format'
require 'onboard/controller/gui'
require 'onboard/controller/locale'
require 'onboard/controller/logger'
require 'onboard/controller/thread'

class OnBoard
  class Controller < ::Sinatra::Base

    # Several options are not enabled by default if you inherit from 
    # Sinatra::Base .
    enable :method_override, :static, :show_exceptions
    
    set :root, OnBoard::ROOTDIR

    # Sinatra::Base#static! has been overwritten to allow multiple path
    set :public_folder, 
        Dir.glob(OnBoard::ROOTDIR + '/public')            +
        Dir.glob(OnBoard::ROOTDIR + '/modules/*/public')      

    set :views, OnBoard::ROOTDIR + '/views'

    not_found do
      status(404)
      format(:path=>'404', :format=>'html') 
    end

    # modular controller
    OnBoard.find_n_load OnBoard::ROOTDIR + '/controller/'

  end

end
