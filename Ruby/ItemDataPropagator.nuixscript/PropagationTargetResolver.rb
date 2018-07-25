class PropagationTargetResolver
	attr_accessor :filter_items

	def resolve_target_items(item)
		raise "#{__method__} need to be overriden in derived class"
	end

	def item_passes_filter(item)
		return true if @filter_items.nil? || @filter_items.size < 1
		return $utilities.getItemUtility.intersection([item],@filter_items).size == 1
	end
end