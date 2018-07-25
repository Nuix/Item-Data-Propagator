class TextDataPropagator < DataPropagator
	attr_accessor :items_grouped_by_destination

	def initialize
		@items_grouped_by_destination = Hash.new{|h,k|h[k]=[]}
	end

	def propagate_data(source_item,target_items)
		target_items.each do |target_item|
			@items_grouped_by_destination[target_item] << source_item
		end
	end

	def name
		return "Text Data Propagator"
	end

	def finalize_operations(pd)
		sorter = $utilities.getItemSorter
		$current_case.withWriteAccess do
			index = 0
			@items_grouped_by_destination.each do |destination_item,source_items|
				break if pd.abortWasRequested
				index += 1
				pd.setSubProgress(index,@items_grouped_by_destination.size)
				pd.setSubStatus("Text Data Propagator (#{index}/#{@items_grouped_by_destination.size})")
				text_chunks = []
				text_chunks << destination_item.getTextObject.toString || ""
				sorted_source_items = sorter.sortItemsByPosition(source_items)
				sorted_source_items.each_with_index do |source_item,source_item_index|
					source_text = source_item.getTextObject.toString
					next if source_text.nil? || source_text.strip.empty?
					text_chunks << source_text
				end
				destination_item.modify do |item_modifier|
					item_modifier.replaceText(text_chunks.join("\n"))
				end
			end
		end
	end
end