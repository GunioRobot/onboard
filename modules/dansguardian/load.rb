class OnBoard
  module ContentFilter
    class DG
      ROOTDIR = File.dirname(__FILE__)
      $LOAD_PATH.unshift  ROOTDIR + '/lib'
      if OnBoard.web?
        OnBoard.find_n_load ROOTDIR + '/etc/menu'
        OnBoard.find_n_load ROOTDIR + '/controller'
      end
    end
  end
end


