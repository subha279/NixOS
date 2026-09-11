-- JSONL / NDJSON support

vim.filetype.add({
	extension = {
		jsonl = "jsonl",
		ndjson = "jsonl",
	},
})

-- JSONL uses the JSON Treesitter grammar.
vim.treesitter.language.register("json", "jsonl")
