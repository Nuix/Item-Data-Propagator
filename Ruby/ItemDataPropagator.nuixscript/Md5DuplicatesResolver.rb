class Md5DuplicatesResolver < PropagationTargetResolver
	def resolve_target_items(item)
		return item.getDuplicates.select{|i|item_passes_filter(i)}
	end
end