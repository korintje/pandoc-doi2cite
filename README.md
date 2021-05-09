# pandoc-doi2cite
This pandoc lua filiter allows you to put references in a document using DOI tags.
What the filter do are as follows:
    1. Search citations with DOI tags in the document
    2. Get bibtex data of the DOI from http://api.crossref.org
    3. Add reference data to a .bib file (default: "./bib_from_doi.bib". It can be designated in the yaml header)
    4. Replace citation to the correspoinding bib key.

# DOI tags
Following DOI tags can be used:
    - @DOI:
    - @doi:
    - @https://doi.org/
    - @doi.org/

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

**# Introduction**
Electrophoresis is one of the most usable methodologies to separate proteins.[@https://doi.org/10.1038/227680a0]
By the way, Einstein is genius.[@doi.org/10.1002/andp.19053221004;  @doi:10.1002/andp.19053220806; @DOI: 10.1002/andp.19053220607]

</pre>

Command:

```sh
pandoc --lua-filter doi2cite --citeproc -s example.md -o example.pdf
```
