Item Data Propagator
====================

![Last tested in Nuix 7.4](https://img.shields.io/badge/Nuix-7.4-green.svg)

View the GitHub project [here](https://github.com/Nuix/Item-Data-Propagator) or download the latest release [here](https://github.com/Nuix/Item-Data-Propagator/releases).

# Overview

**Written By:** Jason Wells

This scripts provides a way to propagate tags, custom metadata and text from a given selection of items to related items.

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Settings

### Input Items

Here you can choose to use the items selected in the results view (if items were selected when script was ran) or a query as the set of input items.

### Propagation Type

Here you can choose how related items are resolved to the input items (the target items).  For a given input item, the selected data (tags,custom metadata, text) will be propagated to that items related target items.

| Type | Description |
|------|-------------|
| **Duplicates (MD5)** | Target items for a given item will be duplicates of that item. |
| **Immediate Children** | Target items for a given item will be the immediate children of that item.  An example of this could be a zip file attached to an email, but not its contents. |
| **Descendants** | Target items for a given item will be all the descendants of that item.  An example of this could be a zip file attached to an email, including the contents of the zip file. |
| **Family** | Target items for a given item will be all the members of that item's family. |
| **Path Items** | Target items for a given item will be all items in that item's path up to and including the root evidence container item. |
| **Top Level Item** | Target item for a given item will be that item's top level item (if it has one). |
| **Parent Item** | Target item for a given item will be that item's immediate parent item. |
| **Ancestor Item** | Similar to **Path Items** this resolves to the *first item* which matches the query provided for **Filter Query**.  Note that using this propagation type requires that you check **Filter Target Items with Query** and that you provide a value for **Filter Query**. |
| **Physical File Item** | Target item for a given item will be that item's ancestor item which responds to the query `flag:physical_file` (if there is one). |
| **Same Physical File** | Target items for a given item will be all items which share the common physical file ancestor as would be calculated by **Physical File Item**. |

Additionally you can further filter target items by checking **Filter Target Items with Query** and providing a Nuix query to **Filter Query**.  A common example of using this might be you have selected as your propagation method **Descendants**, but you only want to propagate to material/audited descendants.  You could then provided a **Filter Query** of `flag:audited` which means that target items for a given item would be that item's descendants which are also responsive to the search `flag:audited`.

### Propagated Data

Here you choose what data will be propagated from input items to their target items.

| Type | Description |
|------|-------------|
| **Propagate Item Text by Appending** | Enabling this will propagate item text from each given item to its target item.  Item's text will be appended to any existing text of target item.  Note that this is intended mostly to propagate descendant text to ancestors.  Going the other direction will likely yield undesired results.  The script will warn you if you are attempting to resolve text to anything but **Top Level Item** (although it will allow you to proceed anyways). |
| **Propagate Tags** | Enabling this will propagate the one or more selected tags from each given input item to its target items. |
| **Prefix Propagated Tag** | Allows you to apply a prefix to tags applied to target items.  For example if the input item has a tag `Status|In Review` and the prefix is `Propagated|` then the resulting tag on the target items would be `Propagated|Status|In Review`.  This setting is provided as a way to distinguish tags propagated to items from items that already had those tags. |
| **Suffix Propagated Tag** | Allows you to apply a suffix to tags applied to target items.  For example if the input item has a tag `Status|In Review` and the suffix is ` Propagated` then the resulting tag on the target items would be `Status|In Review Propagated`.  This setting is provided as a way to distinguish tags propagated to items from items that already had those tags. |
| **Propagate Custom Metadata** | Custom metadata values will be copied from each given input item to its target items.  See below for more details. |

When propagating custom metadata there are several options regarding how replacement of existing values is handled.

| Update Method | Description |
|---------------|-------------|
| **Apply only if target is missing value** | Custom metadata from an input item will only be written to a target item if the target item does not already have a value for the given custom metadata field. |
| **Replace existing value on target, but append strings** | Custom metadata from an input item will always overwrite existing values on target items, except when the custom metadata value on the input item is a string, in which case the input item's value will be appended to the existing value on the target item. |
| **Replace existing value on target** | Custom metadata from an input item will always overwrite any value present on a target item. |

### Review

Here you can specify some options to review the results when the script completes.

| Option | Description |
|--------|-------------|
| **Open new workbench tab with resolved items** | Opens a new workbench tab with a query displaying all the target items resolved by the selected propagation method. |
| **Tag resolved items** | Tags all target items  resolved by the selected propagation method. |

# License

```
Copyright 2018 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```