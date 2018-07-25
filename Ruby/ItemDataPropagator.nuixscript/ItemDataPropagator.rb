require_relative "Nx.jar"
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

load "#{File.dirname(__FILE__)}\\PropagationManager.rb"
load "#{File.dirname(__FILE__)}\\PropagationTargetResolver.rb"
load "#{File.dirname(__FILE__)}\\Md5DuplicatesResolver.rb"
load "#{File.dirname(__FILE__)}\\ChildrenResolver.rb"
load "#{File.dirname(__FILE__)}\\DescendantsResolver.rb"
load "#{File.dirname(__FILE__)}\\FamilyResolver.rb"
load "#{File.dirname(__FILE__)}\\PathResolver.rb"
load "#{File.dirname(__FILE__)}\\TopLevelResolver.rb"
load "#{File.dirname(__FILE__)}\\ParentResolver.rb"
load "#{File.dirname(__FILE__)}\\PhysicalFileResolver.rb"
load "#{File.dirname(__FILE__)}\\SamePhysicalFileResolver.rb"
load "#{File.dirname(__FILE__)}\\AncestorResolver.rb"
load "#{File.dirname(__FILE__)}\\DataPropagator.rb"
load "#{File.dirname(__FILE__)}\\TagDataPropagator.rb"
load "#{File.dirname(__FILE__)}\\CustomMetadataPropagator.rb"
load "#{File.dirname(__FILE__)}\\TextDataPropagator.rb"

#===============#
# Define Dialog #
#===============#
dialog = TabbedCustomDialog.new("Item Data Propagation")

#==========================#
# Settings for input items #
#==========================#
input_items_tab = dialog.addTab("input_items","Input Items")
items_selected = false
if !$current_selected_items.nil? && $current_selected_items.size > 0
	items_selected = true
end

if items_selected
	input_items_tab.appendRadioButton("input_use_selected_items","Use #{$current_selected_items.size} selected items","input_group",items_selected)
end
input_items_tab.appendRadioButton("input_use_query","Use Query","input_group",!items_selected)
input_items_tab.appendTextArea("input_query","Query","")
input_items_tab.enabledOnlyWhenChecked("input_query","input_use_query")
if !items_selected
	input_items_tab.getControl("input_use_query").setEnabled(false)
end

#===============================#
# Settings for propagation type #
#===============================#
propagation_type_tab = dialog.addTab("propagation_type","Propagation Type")
target_choices = [
	"Duplicates (MD5)",
	"Immediate Children",
	"Descendants",
	"Family",
	"Path Items",
	"Top Level Item",
	"Parent Item",
	"Ancestor Item",
	"Physical File Item",
	"Same Physical File",
]
propagation_type_tab.appendComboBox("target_method","Propagation Method",target_choices)
propagation_type_tab.appendCheckBox("target_filter_with_query","Filter Target Items with Query",false)
propagation_type_tab.appendTextField("target_filter_query","Filter Query","flag:audited")
propagation_type_tab.enabledOnlyWhenChecked("target_filter_query","target_filter_with_query")

propagated_data_tab = dialog.addTab("propagated_data","Propagated Data")
propagated_data_tab.appendCheckBox("propagate_item_text","Propagate Item Text by Appending",false)
propagated_data_tab.appendCheckBox("propagate_tags","Propagate Tags",false)
propagated_data_tab.appendCheckableTextField("prefix_applied_tag",false,"tag_prefix","Propagated|","Prefix Propagated Tag with")
propagated_data_tab.enabledOnlyWhenChecked("prefix_applied_tag","propagate_tags")
propagated_data_tab.enabledOnlyWhenChecked("tag_prefix","propagate_tags")
propagated_data_tab.appendCheckableTextField("suffix_applied_tag",false,"tag_suffix"," Propagated","Suffix Propagated Tag with")
propagated_data_tab.enabledOnlyWhenChecked("suffix_applied_tag","propagate_tags")
propagated_data_tab.enabledOnlyWhenChecked("tag_suffix","propagate_tags")
propagated_data_tab.appendStringChoiceTable("tags_to_propagate","Tags",$current_case.getAllTags)
propagated_data_tab.enabledOnlyWhenChecked("tags_to_propagate","propagate_tags")
propagated_data_tab.getControl("tags_to_propagate").getTableModel.checkDisplayedChoices

propagated_data_tab.appendCheckBox("propagate_custom_metadata","Propagate Custom Metadata",false)
custom_metadata_update_methods = [
	"Apply only if target is missing value",
	"Replace existing value on target but append strings",
	"Replace existing value on target",
]
propagated_data_tab.appendComboBox("custom_metadata_propagation_method","Update Method",custom_metadata_update_methods)
propagated_data_tab.enabledOnlyWhenChecked("custom_metadata_propagation_method","propagate_custom_metadata")

#================================#
# Settings for reviewing results #
#================================#
review_tab = dialog.addTab("review","Review")
review_tab.appendCheckBox("open_tab_with_resolved_items","Open new workbench tab with resolved items",false)

review_tab.appendCheckBox("tag_resolved_items","Tag resolved items",false)
review_tab.appendTextField("resolved_items_tag","Tag","ResolvedItems_#{Time.now.strftime("%Y%m%d_%H-%M-%S")}")
review_tab.enabledOnlyWhenChecked("resolved_items_tag","tag_resolved_items")

#===================#
# Dialog Validation #
#===================#

dialog.validateBeforeClosing do |values|
	#Warn only probably incorrectly chosen propagate text
	if values["target_method"] != "Top Level Item" && values["propagate_item_text"]
		message = "WARNING!!!\nYou have chosen to propagate text but your target is not \"Top Level Item\".\n"
		message << "This will likely produce unuseful results!\n"
		message << "Are you really sure you wish to do this?"
		if !CommonDialogs.getConfirmation(message)
			next false
		end
	end

	#Ancestor resolver requires a filter query
	if values["target_method"] == "Ancestor Item" && (values["target_filter_with_query"] == false || values["target_filter_query"].strip.empty?)
		CommonDialogs.showError("You must provide a filter query when using 'Ancestor Item'.")
		next false
	end

	#Warn if using query for input and query is blank (all items)
	if values["input_use_query"] && values["input_query"].strip.empty?
		message = "WARNING!!!\nYou have provided an empty input query.\n"
		message << "This will result in an input set of all items in the case!\n"
		message << "Are you really sure you wish to do this?"
		if !CommonDialogs.getConfirmation(message)
			next false
		end
	end

	#Warn if user selected to use filtering query but provided an empty query value
	if values["target_filter_with_query"] && values["target_filter_query"].strip.empty?
		message = "WARNING!!!\nYou have provided an empty filtering query.\n"
		message << "This will result in no propagation target filtering.\n"
		message << "Are you really sure you wish to do this?"
		if !CommonDialogs.getConfirmation(message)
			next false
		end
	end

	#Fail if user said to apply a tag but provided no tag
	if values["tag_resolved_items"] && values["resolved_items_tag"].strip.empty?
		CommonDialogs.showError("You must supply a non-empty tag to apply.")
		next false
	end

	next true
end

#============================#
# Display dialog and do work #
#============================#
dialog.display
if dialog.getDialogResult == true
	values = dialog.to_map

	manager = PropagationManager.new

	#Load up target resolver
	target_method = values["target_method"]
	case target_method
	when "Duplicates (MD5)"
		manager.target_resolver = Md5DuplicatesResolver.new
	when "Immediate Children"
		manager.target_resolver = ChildrenResolver.new
	when "Descendants"
		manager.target_resolver = DescendantsResolver.new
	when "Family"
		manager.target_resolver = FamilyResolver.new
	when "Path Items"
		manager.target_resolver = PathResolver.new
	when "Top Level Item"
		manager.target_resolver = TopLevelResolver.new
	when "Parent Item"
		manager.target_resolver = ParentResolver.new
	when "Ancestor Item"
		manager.target_resolver = AncestorResolver.new
	when "Physical File Item"
		manager.target_resolver = PhysicalFileResolver.new
	when "Same Physical File"
		manager.target_resolver = SamePhysicalFileResolver.new
	end

	propagate_tags = values["propagate_tags"]
	tags_to_propagate = values["tags_to_propagate"]
	propagate_custom_metadata = values["propagate_custom_metadata"]
	custom_metadata_propagation_method = values["custom_metadata_propagation_method"]
	input_query = values["input_query"]
	target_filter_with_query = values["target_filter_with_query"]
	target_filter_query = values["target_filter_query"]
	tag_resolved_items = values["tag_resolved_items"]
	resolved_items_tag = values["resolved_items_tag"]
	prefix_applied_tag = values["prefix_applied_tag"]
	tag_prefix = values["tag_prefix"]
	suffix_applied_tag = values["suffix_applied_tag"]
	tag_suffix = values["tag_suffix"]

	#Load up data propagators
	manager.data_propagators << TagDataPropagator.new(tags_to_propagate,prefix_applied_tag,tag_prefix,suffix_applied_tag,tag_suffix) if propagate_tags
	if propagate_custom_metadata
		only_when_missing = false
		append_strings = false
		if custom_metadata_propagation_method == "Apply only if target is missing value"
			only_when_missing = true
		end
		if custom_metadata_propagation_method == "Replace existing values on target but append strings"
			append_strings = true
		end
		manager.data_propagators << CustomMetadataPropagator.new(only_when_missing,append_strings)
	end
	manager.data_propagators << TextDataPropagator.new if values["propagate_item_text"]

	ProgressDialog.forBlock do |pd|
		pd.setTitle("Item Data Propagation")
		pd.setAbortButtonVisible(true)

		# Resolve the set of input items which will in turn be resolved to target items
		items = nil
		if items_selected
			items = $current_selected_items
			pd.logMessage("Using #{items.size} selected items")
		elsif input_query
			pd.logMessage("Input Item Query: #{input_query}")
			pd.setMainStatusAndLogIt("Obtaining items...")
			items = $current_case.search(input_query)
			pd.logMessage("Using #{items.size} responsive items")
			pd.setMainStatus("")
		end

		# Report some of the settings we're going to use
		pd.logMessage("Propagation Method: #{target_method}")
		pd.logMessage("Propagate Tags: #{propagate_tags}")
		if propagate_tags
			tags_to_propagate.each do |tag_name|
				pd.logMessage("  #{tag_name}")
			end
		end
		pd.logMessage("Propagate Custom Metadata: #{propagate_custom_metadata}")
		if propagate_custom_metadata
			pd.logMessage("Custom Metadata Propagation Method: #{custom_metadata_propagation_method}")
		end

		# If user is filtering the target items with a query we need to obtain the filter items to
		# later compare against the resolved items
		pd.logMessage("Filter Target Items with Query: #{target_filter_with_query}")
		target_filter_items = nil
		if target_filter_with_query && !target_filter_query.nil? && !target_filter_query.strip.empty?
			pd.logMessage("Target Items Filter Query: #{target_filter_query}")
			pd.setMainStatusAndLogIt("Obtaining filter items...")
			target_filter_items = $current_case.searchUnsorted(target_filter_query)
			pd.logMessage("Obtained #{target_filter_items.size} filtered items")
			pd.setMainStatus("")
		end
		
		# Perform the actual resolution of target items and propagation of tags, custom metadata and text
		# based on the settings the user provided
		pd.setMainStatusAndLogIt("Calculating propagation items...")
		all_resolved_items = manager.perform_propagation(items,target_filter_items,pd)
		pd.logMessage("Resolved #{all_resolved_items.size} propagation items")

		# If user requested we tag target items we perform that opreation here
		if tag_resolved_items
			if all_resolved_items.size > 0
				pd.setMainStatusAndLogIt("Tagging resolved items with: #{resolved_items_tag}")
				annotater = $utilities.getBulkAnnotater
				annotater.addTag(resolved_items_tag,all_resolved_items) do |info|
					pd.setMainProgress(info.getStageCount,all_resolved_items.size)
				end
			end
		end

		# If user requested we open a workbench tab with the resolbed target items we do that here,
		# if they applied a tag to those items we can just use a query to that tag, otherwise we
		# need to build a GUID query to each of those items (tag will perform better)
		if values["open_tab_with_resolved_items"]
			if all_resolved_items.size > 0
				final_query = nil
				if tag_resolved_items
					final_query = "tag:\"#{resolved_items_tag}\""
				else
					guid_query = all_resolved_items.map{|i|i.getGuid}.join(" OR ")
					final_query = "guid:(#{guid_query})"
				end
				$window.openTab("workbench",{"search" => final_query})
			else
				CommonDialogs.showMessage("Was going to open workbench tab but total resolved items is 0.")
			end
		end

		# Finalize the progress dialog state
		if pd.abortWasRequested
			pd.setMainStatusAndLogIt("User Aborted")
		else
			pd.setCompleted
		end
	end
end