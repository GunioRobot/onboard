require 'rubygems'
require 'thin' # we need to explicit the server, for some reason... :-?
require 'sinatra/base'
require 'sinatra/r18n'
require 'locale'
require 'erb'
require 'find'
require 'json'
require 'yaml'
require 'logger'
require 'pp'

require 'onboard/extensions/object'
require 'onboard/menu/node'

class OnBoard
  class Controller < ::Sinatra::Base
    # Extensions must be explicitly registered in modular style apps.
    register ::Sinatra::R18n

    # Several options are not enabled by default if you inherit from 
    # Sinatra::Base .
    enable :methodoverride, :static, :show_exceptions
    set :root, OnBoard::ROOTDIR
    set :public, OnBoard::ROOTDIR + '/public'
    set :views, OnBoard::ROOTDIR + '/views'

    Thread.abort_on_exception = true if environment == :development

    # TODO: do not hardcode, make it configurable
    # NOTE: and, until then, comment it out ;-)
=begin    
    use Rack::Auth::Basic do |username, password|
      [username, password] == ['admin', 'admin']
    end  
=end

    # TODO: do not hardcode, make it themable :-)
    IconDir = '/icons/gnome/gnome-icon-theme-2.18.0'
    IconSize = '16x16'
    
    include ERB::Util

    @@formats = %w{html json yaml} # order matters

    not_found do
      format(:path=>'404', :format=>'html') 
    end

    #before do
    #  if request.path_info =~ /\.html$/ or request.path_info =~ /^\/?$/
    #    puts "filter called at #{request.path_info}"
    #  end
    #end

    helpers do

      def current_language_code
        #i18n.locale.
      end

      # This method should be called PROVIDED that the resource exists.
      def format(h)
        if h[:module] 
          h[:path] = '../modules/' + h[:module] + '/views/' + h[:path].sub(/^\//, '') 
        end
        
        case h[:format]
        when 'html'#, 'xhtml'
          content_type 'text/html', :charset => 'utf-8'
          return erb(
            (h[:path] + '.' + h[:format]).to_sym,
            :layout => ("layout." + h[:format]).to_sym,
            :locals => {
              :objects => h[:objects], 
              :icondir => IconDir, 
              :iconsize => IconSize,
              :msg => h[:msg] 
            } 
          )

        when 'json', 'yaml'
          # Some converters use sorts of ASCII escaping, other emit UTF8
          # strings as they are.
          if h[:format] == 'json'
            content_type  'application/json'
          else  # elsif h[:format] == 'yaml' would be redundant...
            if $ya2yaml_1_9compatible_available
              content_type 'application/json', :charset => 'utf-8'
            else
              content_type 'application/json' # base64(ASCII) used by std lib
            end
          end
          # The following is common to YAML and JSON.
          if h[:objects].class == Array and h[:objects][0].respond_to? :data
            # we assume that array is made up of objects of the same class
            return (h[:objects].map {|obj| obj.data}).to_(h[:format]) 
          elsif h[:objects].respond_to? :data
            return h[:objects].data.to_(h[:format])
          else
            return h[:objects].to_(h[:format])
          end

        when 'rb'
          if options.environment == :development
            content_type 'text/x-ruby'
            return h[:objects].pretty_inspect 
          else
            multiple_choices(h)
          end
        else
          multiple_choices(h)
        end  
      end

      def multiple_choices(h)
        status(300)
        paths = []
        @@formats.each do |fmt|
          paths << request.path_info.sub(/\.[^\.]*$/, '.' + fmt) 
        end
        @@formats.each do |fmt|
          if request.env["HTTP_ACCEPT"] [fmt] # "contains"
            return format(
              :path => '300',
              :format => fmt,
              :objects => {
                :paths => paths, 
              }
            )
          end
          format(
            :path => '300',
            :format => 'html',
            :objects => {
                :paths => paths, 
            }          
          )
        end
      end

    end

    # just to have "CSS variables"
    get '/css/:stylesheet' do
      content_type 'text/css'
      erb ('css/' + params[:stylesheet]).to_sym
    end

    # modular controller
    OnBoard.find_n_load OnBoard::ROOTDIR + '/controller/'

  end

end
