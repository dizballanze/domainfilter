INSTALLATION GUIDE
==================

Mac OS X
--------

-  Download and run [Node.js installer](http://nodejs.org/dist/v0.10.22/node-v0.10.22.pkg).
-  Download and run [git installer](https://code.google.com/p/git-osx-installer/downloads/list?can=3&q=&sort=-uploaded&colspec=Filename+Summary+Uploaded+Size+DownloadCount)
-  Open terminal and type: `sudo npm install -g dizballanze/domainfilter`
-  Type your password
-  After completion type in terminal: `domainfilter --help` to verify that installation succeed:

```
MacBook-Pro:~ yuri$ domainfilter --help
Usage:
  domainfilter [OPTIONS] domains-list.txt

Options: 
  -p, --pattern [STRING] word matching pattern (Default is n)
  -d, --domains STRING   allowed domains separated by commas
  -l, --max-length NUMBERmaximum allowed domain length
  -s, --skip-symbols NUMBERskip symbols count
  -m, --matches-file [PATH]pathname to file for saving matches (Default is ./matches.txt)
  -o, --others-file [PATH]pathname to file for saving not matched domains  (Default is ./others.txt)
      --ignore-digits BOOLignore digit symbols
      --include-dashes BOOLprocess domains with dashes
  -k, --no-color         Omit color from output
      --debug            Show debug information
  -h, --help             Display help and usage details

```

Word definitions
----------------

Word definitions can be found [here](http://wordnetweb.princeton.edu/perl/webwn).