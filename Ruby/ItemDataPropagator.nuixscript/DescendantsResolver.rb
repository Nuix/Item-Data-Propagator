class DescendantsResolver < PropagationTargetResolver
	def resolve_target_items(item)
		return item.getDescendants.select{|i|item_passes_filter(i)}
	end
end