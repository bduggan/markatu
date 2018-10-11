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

For the full set of features take a look at the test suite
here: https://github.com/bduggan/markatu/tree/master/t/mt

## INSTALLATION



Current status: works for me, but highly unstable and experimental

Contributions welcome!

See also:  https://blog.matatu.org/markatu
