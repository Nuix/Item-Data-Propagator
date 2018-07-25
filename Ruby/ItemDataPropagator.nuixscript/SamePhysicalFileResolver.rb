class SamePhysicalFileResolver < PropagationTargetResolver
	def initialize
		@physical_file_resolver = PhysicalFileResolver.new
	end

	def resolve_target_items(item)
		physical_item = @physical_file_resolver.resolve_target_items(item)
		return nil if physical_item.nil?
		return physical_item.first.getDescendants.select{|i|item_passes_filter(i)}
	end
end