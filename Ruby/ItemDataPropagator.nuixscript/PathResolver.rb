class PathResolver < PropagationTargetResolver
	def resolve_target_items(item)
		return item.getPath.select{|i|item_passes_filter(i)}
	end
end