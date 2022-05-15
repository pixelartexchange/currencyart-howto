
module Artbase
class Base     ## "abstract" Base collection - check -use a different name - why? why not?



def make_composite
  ### use well-known / pre-defined (default) grids
  ##        (cols x rows) for now - why? why not?

  composite_count = @count - @excludes.size
  cols, rows = case composite_count
               when   100 then   [10,  10]
               when   150 then   [15,  10]
               when   500 then   [25,  20]
               when  1000 then   [25,  40]
               when  4000 then   [100, 40]    ## or use 50x80 - why? why not?
               when  5000 then   [100, 50]    ## or use 50x100 - why? why not?
               when  5555 then   [100, 56]   # 5600 (45 left empty)
               when  6969 then   [100, 70]   # 7000 (31 left empty)
               when 10000 then   [100, 100]
               else
                   raise ArgumentError, "sorry - unknown composite count #{composite_count}/#{@count} for now"
               end

  composite = ImageComposite.new( cols, rows,
                                  width:  @width,
                                  height: @height )

  ## note: use "private" _range helper
  ##          e.g.  (0+@offset...@count+@offset)
  ##         collection may start at 0 (offset) or 1 (offset)
  ids = _range
  ids.each do |id|
    next  if @excludes.include?( id )

    puts "==> #{id}"
    img = Image.read( "./#{slug}/#{@width}x#{@height}/#{id}.png")

    composite << img
  end

  composite.save( "./#{@slug}/tmp/#{@slug}-#{@width}x#{@height}.png" )
end




def calc_attribute_counters  ## todo/check: use a different name _counts/_stats etc - why? why not?

  attributes_by_count = { count: 0,
                          by_count: Hash.new(0)
                        }
  counter = {}


  each_meta do |meta, id|   ## todo/fix: change id to index
    traits = meta.traits
    # print "#{traits.size} - "
    # pp  traits

    print "#{id}.."   if id % 100 == 0  ## print progress report

    attributes_by_count[ :count ] +=1
    attributes_by_count[ :by_count ][ traits.size ] += 1

    traits.each do |trait_type, trait_value|
        trait_type  = _normalize_trait_type( trait_type )
        trait_value = _normalize_trait_value( trait_value )


        rec = counter[ trait_type ] ||= { count: 0,
                                          by_type: Hash.new(0)
                                        }
        rec[ :count ] +=1
        rec[ :by_type ][ trait_value ] += 1
    end
  end

  print "\n"
  puts

  ## return all-in-one hash
  {
    total:  attributes_by_count,
    traits: counter,
  }
end


def dump_attributes
  stats = calc_attribute_counters

  total    = stats[:total]
  counter  = stats[:traits]

  puts
  puts "attribute usage / counts:"
  pp total
  puts

  puts "#{counter.size} attribute(s):"
  counter.each do |trait_name, trait_rec|
     puts "  #{trait_name}  #{trait_rec[:count]}  (#{trait_rec[:by_type].size} uniques)"
  end

  puts
  pp counter
end




##  order - allow "custom" attribute order export
##  renames - allow renames of attributes
def export_attributes(
   order: [],
   renames: {}
)

  ## step 1: get counters
  stats = calc_attribute_counters

  total    = stats[:total]
  counter  = stats[:traits]

  puts
  puts "attribute usage / counts:"
  pp total
  puts

  puts "#{counter.size} attribute(s):"
  counter.each do |trait_name, trait_rec|
     puts "  #{trait_name}  #{trait_rec[:count]}  (#{trait_rec[:by_type].size} uniques)"
  end


  trait_names = []
  trait_names += order    ## get attributes if any in pre-defined order
  counter.each do |trait_name, _|
      if trait_names.include?( trait_name )
         next    ## skip already included
      else
         trait_names  << trait_name
      end
  end


  recs = []


  ## step 2: get tabular data
  each_meta do |meta, id|   ## todo/fix: change id to index

    traits = meta.traits
    # print "#{traits.size} - "
    # pp  traits

    print "#{id}.."   if id % 100 == 0  ## print progress report

    ## setup empty hash table (with all attributes)
    rec = {}

    ## note: use __Slug__& __Name__
    ##         to avoid conflict with attribute names
    ##         e.g. attribute with "Name" will overwrite built-in and so on

    rec['__Slug__'] = if respond_to?( :_meta_slugify )
                       _meta_slugify( meta, id )
                  else
                     ## default to id (six digits) as string with leading zeros
                     ##    for easy sorting using strings
                     ##   e.g.  1 => '000001'
                     ##         2 => '000002'
                       '%06d' % id
                  end

    rec['__Name__'] = meta.name

    ## add all attributes/traits names/keys
    trait_names.reduce( rec ) { |h,value| h[value] = []; h }
    ## pp rec

    ## note: use an array (to allow multiple values for attributes)
    traits.each do |trait_type, trait_value|
       trait_type  = _normalize_trait_type( trait_type )
       trait_value = _normalize_trait_value( trait_value )

       values = rec[ trait_type ]
       values << trait_value
    end
    recs << rec
  end
  print "\n"

  ## pp recs

  ## flatten recs
  data = []
  recs.each do |rec|
     row = rec.values.map do |value|
                  if value.is_a?( Array )
                     value.join( ' / ' )
                  else
                     value
                  end
             end
     data << row
  end


  ## sort by slug
  data = data.sort {|l,r| l[0] <=> r[0] }
  pp data

  ### save dataset
  ##  note: change first colum Slug to ID - only used for "internal" sort etc.
  headers = ['ID', 'Name']
  headers += trait_names.map do |trait_name|   ## check for renames
                                renames[trait_name] || trait_name
                             end


  path = "./#{@slug}/tmp/#{@slug}.csv"
  dirname = File.dirname( path )
  FileUtils.mkdir_p( dirname )  unless Dir.exist?( dirname )

  File.open( path, 'w:utf-8' ) do |f|
    f.write(  headers.join( ', ' ))
    f.write( "\n" )
    ## note: replace ID with our own internal running (zero-based) counter
    data.each_with_index do |row,i|
      f.write( ([i]+row[1..-1]).join( ', '))
      f.write( "\n" )
    end
  end
end




#############
#  "private" helpers

def _normalize_trait_type( trait_type )
  if @patch && @patch[:trait_types]
    @patch[:trait_types][ trait_type ] || trait_type
  else
     trait_type
  end
end

def _normalize_trait_value( trait_value )
  if @patch && @patch[:trait_values]
    @patch[:trait_values][ trait_value ] || trait_value
  else
    trait_value
  end
end




end  # class Base
end  # module Artbase
