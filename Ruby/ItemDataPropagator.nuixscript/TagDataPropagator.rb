class TagDataPropagator < DataPropagator
	attr_accessor :grouped_by_tag
	attr_accessor :tags
	attr_accessor :apply_prefix
	attr_accessor :tag_prefix
	attr_accessor :apply_suffix
	attr_accessor :tag_suffix

	def initialize(tags,apply_prefix,tag_prefix,apply_suffix,tag_suffix)
		@tags = {}
		tags.each{|t|@tags[t]=true}
		@apply_prefix = apply_prefix
		@tag_prefix = tag_prefix
		@apply_suffix = apply_suffix
		@tag_suffix = tag_suffix
		@grouped_by_tag = Hash.new{|h,k|h[k]={}}
	end

	def name
		return "Tag Data Propagator"
	end

	def propagate_data(source_item,target_items)
		tags = source_item.getTags
		tags.each do |tag|
			next if !@tags[tag]
			target_items.each do |target_item|
				@grouped_by_tag[tag][target_item] = true
			end
		end
	end

	def finalize_operations(pd)
		annotater = $utilities.getBulkAnnotater
		@grouped_by_tag.each do |tag,items_hash|
			break if pd.abortWasRequested
			if @apply_prefix
				tag = "#{@tag_prefix}#{tag}"
			end
			if @apply_suffix
				tag = "#{tag}#{@tag_suffix}"
			end
			pd.setSubStatusAndLogIt("Applying to #{items_hash.keys.size} items: #{tag}")
			items = items_hash.keys
			annotater.addTag(tag,items) do |info|
				pd.setSubProgress(info.getStageCount,items.size)
			end
		end
	end
end