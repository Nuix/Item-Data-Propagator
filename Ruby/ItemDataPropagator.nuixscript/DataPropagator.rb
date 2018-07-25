class DataPropagator
	def name
		return self.class.name
	end

	def propagate_data(source_item,target_items)
		raise "#{__method__} need to be overriden in derived class"
	end

	#Can be optionally overriden in derived class, provides class with
	#a chance to finalize any propagation pending.  Allows a class to
	#store results and perform them in bulk at the end.
	def finalize_operations
	end
end