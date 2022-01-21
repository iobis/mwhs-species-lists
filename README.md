# mwhs-species-lists

This is a collection of scripts for compiling species lists for marine World Heritage sites.

## Data preparation

### Cocos Island National Park

This script does not produce a definitive species list, but it tries to extract taxon names from the included pdf. The script first used OCR to generate a text file for each page, then a neural network model provided by [TaxoNERD](https://github.com/nleguillarme/taxonerd) is used to extract taxon names.

:paperclip:	[taxa.txt](cocos_island/taxa.txt)

### Galápagos Islands

This script fetches all checklists from https://www.darwinfoundation.org/en/datazone/checklist.

:paperclip:	[taxa.txt](galapagos/taxa.txt)

### Other lists

This processes a set of species lists delivered in xlsx.

:paperclip:	[other_lists.csv](others/other_lists.csv)

## Synthesis

To do.