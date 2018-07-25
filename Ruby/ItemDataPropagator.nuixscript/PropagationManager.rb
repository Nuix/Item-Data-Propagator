class PropagationManager
	attr_accessor :target_resolver
	attr_accessor :data_propagators

	def initialize
		@data_propagators = []
	end

	def perform_propagation(items,target_filter_items,pd)
		if items.nil? || items.size < 1
			pd.logMessage("!!! Input items collection is empty")
			return
		end
		if target_resolver.nil?
			raise "PropagationManager.target_resolver cannot be nil"
		end

		iutil = $utilities.getItemUtility
		all_resolved_items = {}
		@target_resolver.filter_items = target_filter_items

		last_progress = Time.now
		items.each_with_index do |item,item_index|
			break if pd.abortWasRequested
			target_items = @target_resolver.resolve_target_items(item)
			next if target_items.nil? || target_items.size < 1
			target_items.each{|i|all_resolved_items[i]=true}
			data_propagators.each do |data_propagator|
				pd.setSubStatus("#{data_propagator.name} propagating data to #{target_items.size} items")
				data_propagator.propagate_data(item,target_items)
			end
			if (Time.now - last_progress) > 1
				pd.setMainProgress(item_index+1,items.size)
				pd.setMainStatus("Resolving #{item_index+1}/#{items.size}")
				last_progress = Time.now
			end
		end
		pd.setMainProgress(items.size,items.size)
		pd.setMainStatus("Resolved #{items.size}/#{items.size}")

		data_propagators.each do |data_propagator|
			pd.setSubStatus("#{data_propagator.name} finalizing work")
			data_propagator.finalize_operations(pd)
		end

		return all_resolved_items.keys
	end
end