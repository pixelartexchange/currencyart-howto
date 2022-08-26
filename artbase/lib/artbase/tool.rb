


module Artbase
class Tool

  def self.collection=(value)
    puts "  setting collection to:"
    pp value

    @collection = value
  end


  def self.main( args=ARGV )
    puts "==> welcome to collection tool with args:"
    pp args


    options = { faster: false  }

    parser = OptionParser.new do |opts|

      opts.on("--offset NUM", Integer,
              "Start counting at offset (default: 0)") do |num|
          options[ :offset]  = num
      end

      opts.on("--limit NUM", Integer,
              "Limit collection (default: ∞)") do |num|
          options[ :limit]  = num
      end

      ## todo/fix: unsupported argument type: Range
      ## opts.on("--range RANGE", Range,
      ##        "Range of collection (default: 0..∞") do |range|
      ##    options[ :range]  = range
      ## end

      opts.on( "--faster", "Use faster (optional) pixelate binary (default: off)") do
          options[ :faster ] = true
      end


      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    parser.parse!( args )
    puts "options:"
    pp options

    puts "args:"
    pp args

    if args.size < 2
      puts "!! ERROR - no command found - use <collection> <command>..."
      puts ""
      exit
    end

    name       = args[0]   ## todo/check - use collection_name/slug or such?
    command    = args[1]
    subcommand = args[2]


    path = if File.exist?( "./#{name}/config.rb" )
               "./#{name}/config.rb"
           else
               "./#{name}/collection.rb"
           end
    puts "==> reading collection config >#{path}<..."

    ## note: assume for now global const COLLECTION gets set/defined!!!
    ##   use/change to a script/dsl loader/eval later!!!
    load( path )

    ## pp COLLECTION

    ## configure collection  (note: requires self)
    self.collection = COLLECTION


    if ['d','dl','down', 'download'].include?( command )
      if subcommand
         if ['m', 'meta'].include?( subcommand )
           download_meta
         elsif ['i', 'img', 'image', 'images'].include?( subcommand )
           download_images
         end
      else
        download_meta
        download_images
      end
    elsif ['p', 'px', 'pix', 'pixel', 'pixelate'].include?( command )
      pixelate( offset: options[ :offset],
                faster: options[ :faster] )
    elsif ['m', 'meta'].include?( command )
      download_meta( offset: options[ :offset] )
    elsif ['i', 'img', 'image', 'images'].include?( command )
      download_images( offset: options[ :offset] )
    elsif ['conv', 'convert'].include?( command )
      convert_images
    elsif ['a', 'attr', 'attributes'].include?( command )
      dump_attributes
    elsif ['x', 'exp', 'export'].include?( command )
      export_attributes
    elsif ['c', 'composite'].include?( command )
      make_composite
    elsif ['strip'].include?( command )
      make_strip
    elsif ['t', 'test'].include?( command )
       puts "  testing, testing, testing"
    else
      puts "!! ERROR - unknown command >#{command}<, sorry"
    end

    puts "bye"
  end

  def self.make_composite
    puts "==> make composite"
    @collection.make_composite
  end

  def self.convert_images
    puts "==> convert images"
    @collection.convert_images( overwrite: false )
  end


  def self.make_strip
    puts "==> make strip"
    @collection.make_strip
  end


  def self.dump_attributes
    puts "==> dump attributes"
    @collection.dump_attributes
  end

  def self.export_attributes
    puts "==> export attributes"
    @collection.export_attributes
  end


  def self.download_meta( offset: )
      puts "==> download meta"

      range = if offset
                @collection._range( offset: offset )
              else
                @collection._range
              end

      @collection.download_meta( range )
  end


  def self.download_images( offset: )
     puts "==> download images"

    range = if offset
              @collection._range( offset: offset )
            else
              @collection._range
            end

     @collection.download_images( range )
  end


  def self.pixelate( offset:,
                     faster: )
    puts "==> pixelate"

    range = if offset
              @collection._range( offset: offset )
            else
              @collection._range
            end

    @collection.pixelate( range, faster: faster )
  end
end # class Tool


end # module Artbase



