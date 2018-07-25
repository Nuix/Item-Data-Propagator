class CustomMetadataPropagator < DataPropagator
	def initialize(only_if_missing,append_strings)
		@only_if_missing = only_if_missing
		@append_strings = append_strings
	end

	def name
		return "Custom Metadata Propagator"
	end

	def propagate_data(source_item,target_items)
		source_custom_metadata = source_item.getCustomMetadata
		if !@only_if_missing && !@append_strings
			annotater = $utilities.getBulkAnnotater
			source_custom_metadata.each do |key,value|
				annotater.putCustomMetadata(key,value,target_items,nil)
			end
		else
			target_items.each do |target_item|
				target_custom_metadata = target_item.getCustomMetadata
				source_custom_metadata.each do |key,source_value|
					# Does not make sense to carry shannon entropy across items
					next if key == "nuix.shannonEntropy"
					target_value = target_custom_metadata[key]
					next if @only_if_missing && (target_value.nil? || (target_value.is_a?(String) && target_value.strip.empty?))
					if @append_strings && target_value.is_a?(String)
						target_custom_metadata[key] += "\n"+source_value
					else
						target_custom_metadata[key] = source_value
					end
				end
			end
		end
	end

	def finalize_operations(pd)
	end
end