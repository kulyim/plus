require 'plus/plus'
require 'plus/plus_obj'
require 'csv'

class CSVData < PlusObj

	attr_reader :header
	attr_reader :src

	def initialize filename
	  @src =  CSV.new(File.open(filename,'r'),{})
	  @header = src.take(1).first.collect{|h| h.strip}.compact
	  throw "There is something wrong with this header" if @header.empty?
		super()
	end

	def to_hash row
	 Hash[header.zip(row.collect{|r| r.strip})]
	end

	def hash_operation head ,operation
		hashes =  data( head)  + op(:to_hash)
		foreach(hashes, operation).collect do|work|
			 Hash[work.collect(&_id).force]
		end
	end

	def rows 
		 data(src)
	end

	def _synth name
    if prc =  kind_for(Proc,name)
      op(prc)
    elsif sym = kind_for(Symbol,name)
      if md = sym.to_s.match( /^(keys|values)_(.*)/)
        kind,mess = md.captures
         {
          'keys' =>  lambda{|pair|  a,b=pair;[a.send(mess.to_sym),b]},
          'values' =>  lambda{|pair| a,b=pair;[a,b.send(mess.to_sym)]}
        }[kind]
      else
        throw "Name should \"keys_|values_\"methodname, not: #{sym}"
      end
    end
	end

  def make_work(*operations)
		ops =  operations.collect(&op(:_synth))
		workers(*ops)
  end

	def process *operations ,&b
    work = (operations.empty?) ? _id : make_work(*operations)
    if b
      func(data(op(:hash_operation,src).call(work)) ,b)
    else
		  data(op(:hash_operation,src).call(work))
    end
	end

end
