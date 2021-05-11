--------------------------------------------------------------------------------
-- Copyright © 2021 Takuro Hosomi
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Global variables --
--------------------------------------------------------------------------------
base_url = "http://api.crossref.org"
bibpath = "./bib_from_doi.bib"
bibkeylist = {};
doi_entry_map = {};


--------------------------------------------------------------------------------
-- Pandoc Functions --
--------------------------------------------------------------------------------
-- Get bibliography filepath from yaml metadata
function Meta(m)
    local bp = m.bib_from_doi
    if bp ~= nil then
        if bp[1].text ~= nil then
            bibpath = bp[1].text
        elseif bp[1][1] ~= nil then
            bibpath = bp[1][1].text
        else end
    end
    f = io.open(bibpath, "r")
    if f then
        entries_str = f:read('*all')
        if entries_str then
            doi_entry_map = get_doi_entry_map(entries_str)    
        end
        f:close()
    end
    f = io.open(bibpath, "w")
    f:close()
    print(bibpath .. " is created for bibliography from DOI.")
end

-- Get bibtex data of doi-based citation.id and make bibliography.
-- Then, replace "citation.id"
function Cite(c)
    for _, citation in pairs(c.citations) do
        local id = citation.id:gsub('%s+', ''):gsub('%%2F', '/')
        if id:sub(1,16) == "https://doi.org/" then
            doi = id:sub(17)
        elseif id:sub(1,8) == "doi.org/" then
            doi = id:sub(9)
        elseif id:sub(1,4) == "DOI:" or id:sub(1,4) == "doi:" then
            doi = id:sub(5)
        else
            doi = nil
        end
        if doi then
            local entry_str = get_bibentry(doi)
            if entry_str then
                entry_str = replace_symbols(entry_str)
                local entry_key = get_entrykey(entry_str)
                if not (Set(bibkeylist)[entry_key]) then
                    f = io.open(bibpath, "a")
                    f:write(entry_str .. "\n")
                    f:close()
                    bibkeylist[#bibkeylist+1] = entry_key
                end
                citation.id = entry_key
            else
                print("Failed to get ref from DOI: " .. doi)
            end
        end
    end
    return c
end


--------------------------------------------------------------------------------
-- Common Functions --
--------------------------------------------------------------------------------
-- Make boolean hashmap from given list. key = list item, value = boolean.
function Set (list)
    local set = {};
    for _, item in ipairs(list) do
        set[item] = true
    end
    return set
end

-- Get bib of DOI from http://api.crossref.org
function get_bibentry(doi)
    local entry_str = doi_entry_map[doi]
    if entry_str == nil then
        print("Request RefData of DOI = " .. doi)
        local url = base_url .. "/works/" .. doi .. "/transform/application/x-bibtex"
        mt, entry_str = pandoc.mediabag.fetch(url)
        entry_str = make_key_unique(entry_str)
    end
    return entry_str
end

-- Replace some symbols inorder to escape (maybe) bugs of pandoc/citeproc
function replace_symbols(string)
    local buggystrs = {};
    buggystrs["{\textendash}"] = "–"
    buggystrs["{\textemdash}"] = "—"
    buggystrs["{\textquoteright}"] = "’"
    buggystrs["{\textquoteleft}"] = "‘"
    for buggystr, altanative in pairs(buggystrs) do
        local string = string:gsub(buggystr, altanative)
    end
    return string
end

-- get bibtex entry key from bibtex entry string
function get_entrykey(entry_string)
    local key = entry_string:match('@%w+{(.-),') or ''
    return key
end

-- get bibtex entry doi from bibtex entry string
function get_entrydoi(entry_string)
    local doi = entry_string:match('doi%s*=%s*["{]*(.-)["}],?') or ''
    return doi
end

-- Make hashmap which key = DOI, value = bibtex entry string
function get_doi_entry_map(bibtex_string)
    local entries = {};
    for entry_str in bibtex_string:gmatch('@.-\n}\n') do
      local doi = get_entrydoi(entry_str)
      entries[doi] = entry_str
    end
    return entries
end

-- Replace entry key of "entry_string" to DOI-contained unique key 
function make_key_unique(entry_string)
    local key = get_entrykey(entry_string)
    local doi = get_entrydoi(entry_string)
    local unique_key = key.."_"..doi
    entry_string = entry_string:gsub('(@%w+{).-(,)', '%1'..unique_key..'%2')
    return entry_string    
end  


--------------------------------------------------------------------------------
-- The main function --
--------------------------------------------------------------------------------
return {
    { Meta = Meta },
    { Cite = Cite }
}