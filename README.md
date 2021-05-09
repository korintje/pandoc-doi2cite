# pandoc-doi2cite
This pandoc lua filiter helps users to insert references in a document with using some "DOI tagas".
With this filter, users do not need to make bibtex file by themselves. Instead, the filter automatically generate .bib file from the DOI tags, and convert the DOI tags into citation keys available by `pandoc-crossref`.
What the filter do are as follows:
1. Search citations with DOI tags in the document
2. Get bibtex data of the DOI from http://api.crossref.org
3. Add reference data to a .bib file
4. Replace DOI tags to the correspoinding citation keys.

# Prerequisites
- Pandoc version 2.0 or newer
- This filter does not need any external dependencies
- This filter must be executed before `pandoc-crossref` or `--citeproc`

# DOI tags
Following DOI tags can be used:
* @https://doi.org/
* @doi.org/
* @DOI:
* @doi:

# Specify auto-generated bibliography file path
The path of the auto-generated bibliography file can be designated in the document yaml header.
The yaml key is `bib_from_doi`.
Both of the string and array are acceptable(If it is given as an array, only first item will be used).
Note that users typically should add same file path also in `bibliography`, in order to be recognized by `--citeproc`.

# Example
Example paper.md:

<pre>
---
bibliography:
  - "doi_refs.bib"
  - "my_refs.bib"
bib_from_doi:
  - "doi_refs.bib"
---

# Introduction
Electrophoresis is one of the most usable methodologies to separate proteins.[@https://doi.org/10.1038/227680a0]
By the way, Einstein is genius.[@doi.org/10.1002/andp.19053221004; @doi:10.1002/andp.19053220806; @DOI: 10.1002/andp.19053220607]

</pre>

Command:

```sh
pandoc --lua-filter doi2cite --filter=pandoc-crossref --citeproc -s example.md -o example.pdf
```
