require 'plus/plus_obj'
# This module  adds a '+'
# to a few key Ruby classes

# This module adds our '+' 
# to an including class

module Plus
	def +(other)
    PlusObj.new.plus(self,other)
	end
end

class Proc 
	include Plus
	def for_lazy
			lambda{|y,args| y << self.call(args) }	
	end
end

class Enumerator
	include Plus
	def for_lazy
			lambda{|y,args| y << self.call(args) }	
	end
end

class Enumerator::Lazy
	include Plus
	def for_lazy
		self
	end
end

