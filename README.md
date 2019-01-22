# Markatu: another lightweight markup language

[![Build Status](https://travis-ci.org/bduggan/markatu.svg?branch=master)](https://travis-ci.org/bduggan/markatu)

Quick example:

```
html {
 head {
  meta[charset="UTF-8"]:
 }

 title: markatu
 link[rel=stylesheet,href="w3.css"]:
 link[rel=stylesheet,href="index.css"]:

 body {
  mydiv=div.w3-content,w3-display-container,w3-padding,w3-border,w3-card,w3-round-large,w3-margin,w3-white {
    This is *markatu*!
  }
  mydiv {
    This is still markatu.
 
    ul {
      * This is a list
      * of
      * things
      li {
        This list item
        goes on and on
     }
    }

    +INCLUDE example_file.txt

  }
  }
}

```

## Some features

* Curly braces for blocks
* macros for defining sets of classes
* Include other files
* Run code and show the results
* Cache the output of code that was run

For the full set of features take a look at the test suite
here: https://github.com/bduggan/markatu/tree/master/t/mt

## INSTALLATION

1. Install [Perl 6](https://perl6.org) and [zef](https://github.com/ugexe/zef)
2. zef install Terminal::ANSIColor
3. Clone this repo, add `bin/` to your PATH and `lib/` to your PERL6LIB
4. Done.  Run `mt` to convert `.mt` files to HTML.

## Status

Current status: works for me, but highly unstable and experimental.

## See Also

https://blog.matatu.org/markatu

Contributions welcome!
