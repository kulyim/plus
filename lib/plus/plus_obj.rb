require 'plus/plus_helpers'

class PlusObj
  class PlusArgumentError < ArgumentError;end

	include PlusHelpers
	def initialize
		register(Symbol){|obj| method(obj).to_proc}
		register(Proc){|obj| obj}
		register(Regexp){|obj| lambda{|arg| obj === arg} }
	end
	def plus this,other
		en,_ = sane(Enumerable,this,other)
		p1,p2 = sane(Proc,this,other)
		#enum + proc => proc: proc gets values from enum
		#proc + proc1  => proc: output of proc is input to proc1
		#proc + enum => (same as first case)
    if en && p1
      Enumerator::Lazy.new(en,&p1.for_lazy)
    elsif p1 && p2 
      lambda {|arg| p2.call(p1.call(arg))} 
    else
      throw PlusArgumentError.new "Can't plus #{this} and #{other}" 
    end
	end

	def register *args,&b 
				@type_registry ||= {}
				@type_registry[args.first] = b	
				@type_registry
	end

  # Redefined to use our registry to create
  # 'op's
	def op thing,*args
			meth = register[thing.class].call(thing) 
			arity = meth.arity
			if arity > 1
				meth.curry(arity)[*args]
			else
				meth	
			end
	end

end


