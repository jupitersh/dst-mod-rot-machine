name = "Rot Machine"
description = "Foods in the Machine will spoil soon, which supply plenty of spoiled food to fertilize."

author = "辣椒小皇纸"

version = "1.1"

api_version = 10
api_version_dst = 10
dst_compatible = true

forumthread = ""

icon_atlas = "modicon.xml"
icon = "modicon.tex"

all_clients_require_mod = true
client_only_mod = false

server_filter_tags = {"Rot Machine"}

dont_starve_compatible = false

----------------------
-- General settings --
----------------------

configuration_options =
{
	{
		name = "language",
		label = "Language",
		hover = "",
		options =	{
						{description = "English", data = "en", hover = ""},
						{description = "中文", data = "chs", hover = ""},
					},
		default = "en",
	},
	{
		name = "spoiled_food",
		label = "Spoiled Foods Needed",
		hover = "Configure how many spoiled foods you need to craft a poop.",
		options =	{
						{description = "4", data = 4, hover = ""},
						{description = "5", data = 5, hover = ""},
						{description = "6", data = 6, hover = ""},
						{description = "7", data = 7, hover = ""},
						{description = "8", data = 8, hover = ""},
						{description = "9", data = 9, hover = ""},
						{description = "10", data = 10, hover = ""},
						{description = "11", data = 11, hover = ""},
						{description = "12", data = 12, hover = ""},
					},
		default = 8,
	},
}