class PhysicalFileResolver < PropagationTargetResolver
	attr_accessor :physical_item_lookup

	def initialize
		@physical_item_lookup = {}
	end

	def resolve_target_items(item)
		if !@physical_item_lookup.has_key?(item)
			physical_item = nil
			reversed_path_items = item.getPath.to_a.reverse
			reversed_path_items.each do |path_item|
				if path_item.isPhysicalFile
					physical_item = path_item
					break
				end
			end
			if !physical_item.nil?
				physical_item.getDescendants.each do |descendant|
					@physical_item_lookup[descendant] = physical_item
				end
				return [physical_item]
			else
				return []
			end
		else
			return [@physical_item_lookup[item]]
		end
	end
end