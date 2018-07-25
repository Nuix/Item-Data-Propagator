class TopLevelResolver < PropagationTargetResolver
	def resolve_target_items(item)
		return nil if item.isTopLevel
		return [item.getTopLevelItem].select{|i|item_passes_filter(i)}
	end
end