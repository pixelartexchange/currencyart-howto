require 'cocos'



## 3rd party gems
require 'pixelart'

## database support gems
require 'active_record'
require 'sqlite3'




## our own code
require_relative 'artbase-cocos/version'    # note: let version always go first


### add (shared) "global" config
module Artbase
class Configuration

  #######################
  ## accessors

  ##  todo/check:  keep trailing / in ipfs_gateway - why? why not?
  def ipfs_gateway()       @ipfs_gateway || 'https://ipfs.io/ipfs/'; end
  def ipfs_gateway=(value) @ipfs_gateway = value; end
end # class Configuration


## lets you use
##   Artbase.configure do |config|
##      config.ipfs_gateway = 'https://cloudflare-ipfs.com/ipfs/'
##   end
def self.configure() yield( config ); end
def self.config()    @config ||= Configuration.new;  end
end  # module Artbase


require_relative 'artbase-cocos/image'


require_relative 'artbase-cocos/helper'
require_relative 'artbase-cocos/retry'    ## (global) retry_on_error helper

require_relative 'artbase-cocos/collection'
require_relative 'artbase-cocos/attributes'


require_relative 'artbase-cocos/reports/base'
require_relative 'artbase-cocos/reports/collections_linter'  # e.g. LintCollectionsReport etc.
require_relative 'artbase-cocos/reports/contracts_linter'

require_relative 'artbase-cocos/reports/export'
require_relative 'artbase-cocos/reports/opensea_linter'



## todo - move to load on demand to build - why? why not?
require_relative 'artbase-cocos/database'




######
## move to helper - why? why not?



## quick ipfs (interplanetary file system) hack
##   - make more reuseable
##   - different name  e.g. ipfs_to_http or such - why? why not?
##   change/rename parameter str to url or suc - why? why not?
def handle_ipfs( str, normalize:    true,
                      ipfs_gateway: Artbase.config.ipfs_gateway )

  if normalize && str.start_with?( 'https://ipfs.io/ipfs/' )
    str = str.sub( 'https://ipfs.io/ipfs/', 'ipfs://' )
  end

  if str.start_with?( 'ipfs://' )
    str = str.sub( 'ipfs://', ipfs_gateway )   # use/replace with public gateway
  end
  str
end



puts Artbase::Module::Cocos.banner    # say hello




