class FamilyResolver < PropagationTargetResolver
	def resolve_target_items(item)
		return item.getFamily.select{|i|item_passes_filter(i)}
	end
end