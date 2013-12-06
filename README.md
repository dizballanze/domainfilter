domainfilter
============

Simple domain filters cli-tool.

Parameters:
-----------

List of acceptable parameters, default values and description.

-  `-p --pattern n` - word matching pattern. Value is a sequense of following letters:
    -  `n` - nouns
    -  `a` - adjectives
    -  `v` - verbs
    -  `d` - adverbs
-  `--skip-symbols -s 0` - skip symbols count
-  `--matches-file -m ./matches.txt` - pathname to file for saving matches
-  `--others-file -o ./others.txt` - pathname to file for saving not matched domains
-  `--ignore-digits` - ignore digit symbols 
-  `--include-dashes` - process domains with dashes
-  `pathname.txt` - pathname of file with domains list

Example of usage:
-----------------

```
domainfilter -p na -s 2 -m ./success.txt -o fail.txt /Users/johndoe/PoolDeletingDomainsList.txt
```