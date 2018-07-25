class AncestorResolver < PropagationTargetResolver
	attr_accessor :ancestor_item_lookup

	def initialize
		@ancestor_item_lookup = {}
	end

	def resolve_target_items(item)
		ancestor_item = @ancestor_item_lookup[item]
		if ancestor_item.nil?
			reversed_path_items = item.getPath.to_a.reverse
			reversed_path_items.shift
			path_fails = []
			reversed_path_items.each do |path_item|
				if item_passes_filter(path_item)
					ancestor_item = path_item
					#Cache other items in path that would also resolve to this ancestor
					path_fails.each{|i|@ancestor_item_lookup[i] = ancestor_item}
					break
				else
					path_fails << path_item
				end
			end
		end
		
		if !ancestor_item.nil?
			return [ancestor_item]
		else
			return []
		end
	end
end