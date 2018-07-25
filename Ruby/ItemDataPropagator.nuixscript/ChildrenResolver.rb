class ChildrenResolver < PropagationTargetResolver
	def resolve_target_items(item)
		return item.getChildren.select{|i|item_passes_filter(i)}
	end
end