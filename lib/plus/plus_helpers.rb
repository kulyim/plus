require 'plus/plus'
module PlusHelpers
	def op(thing,*args)
			asymbol = kind_for(Symbol,thing)
			aproc = kind_for(Proc,thing)	
			if asymbol 
					meth = method(asymbol).to_proc
					arity = meth.arity
					if arity > 1
						meth.curry(arity)[*args]
					else
						thing
					end
			end
	end

	def kind_for cls,obj
		if _kf(cls,obj) 
			 block_given? ? yield(obj) : obj
		end
	end

	def kind_for! cls, obj
		_kf(cls,obj) ||throw( "!!! #{obj.class} != #{cls}" )
	end

	def _kf cls,obj
		catch(self.object_id) do|sub|
			if obj.kind_of?cls
				obj
			else
				throw self.object_id,nil 
			end
		end
	end

	def _data meth,en
		kind_for!(Enumerable,en).send(meth)
	end

	def data en
		op(:_data,:each).call(en)
	end

	def func head,*tail
		kind_for! Enumerable, head 
		head +  sequence(*tail)
	end

	def foreach head,*tail,&how
		kind_for! Enumerable, head 
		work = sequence(*tail)
		spy = how || _id
		head.collect do |v| 
			func(data(spy.call(v)),work)
		end.force
	end
	
	def source head
		sane(Enumerable,head).first
	end

	def workers head,*rest
		rs = sane(Proc,head,*rest)
		sequence(*rs)
	end

	def sane cls,head,*rest
			ok_or_nil = op(:kind_for,cls)
			[head,rest].flatten.collect(&ok_or_nil).compact
	end

	def sequence *args,&how
		work = how || _id	
    args.length < 2  ? args.first : args.flatten.collect(&work).reduce(:+)
	end

	def _id show=false
		lambda{|a|p [:id,a] if show; a}
	end
end
