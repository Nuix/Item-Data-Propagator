class ParentResolver < PropagationTargetResolver
	def resolve_target_items(item)
		return [item.getParent].select{|i|item_passes_filter(i)}
	end
end