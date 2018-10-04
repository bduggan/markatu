use Grammar::PrettyErrors;

grammar Markatu::Grammar does Grammar::PrettyErrors {
#grammar Markatu::Grammar {
  regex TOP {
   <blocks>
   "\n"*
  }
  regex blocks {
   \s*
   [ <block>+? %% ["\n" "\n"+] ]
   \s*
  }
  token ws {
    # default: <!ww> \s*
    <!ww>
    \h*
  }
  regex block {
   [
        || <include-code>
        || <output>
        || <include>
        || <codefence>
        || <tag>
        || <p>
        || <hr>
        || <list-element>
        || <anchor>
    ]
  }
  token class-list { 
    <[\w] + [-] + [,]>+
  }
  regex codefence {:r
      \h*'```'
      [ '.' <class-list> ]?
      \n
      <( [
          | <-[`]>
          | '`'<-[`]>
          | '``'<-[`]>
         ]+? )>\n
      $<indentation>=\h*'```'$$
  }
  rule range {
    $<min>=\d+ '-' $<max>=\d+
  }
  rule include-code {
    \h*'+CODE ' <( \w+ ".p6" )> <range>?$$
  }
  rule include {
    \h*'+INCLUDE ' <( \S+ )>
  }
  token filename {
    \w <[\w] + [-] + [.]>*
  }
  rule output {
    \h*'+OUTPUT ' <( <.filename> )>
  }
  regex p {
    [ <line>+ % "\n" ]
  }
  token label {
    [
      $<tag>=[\w+]
      ['#' $<id>=\w+ ]?
      ['.' <class-list>]?
      [ '(' ~ ')' $<declare-variable>=\w+]?
      [ |'.'<{ fail "extra . in tag name" }> ]?
    ] |
    [
      $<declare-variable>=\w+ '='
      $<tag>=[\w+]
      ['#' $<id>=\w+ ]?
      ['.' <class-list>]?
    ]
  }
  rule tag {
    <label>
    [
      | ':' $<text>=\V*
      | '{' "\n"?
             [ <blocks> "\n"? ]+ % "\n"
        '}'
    ]
  }
  token h { \h* }
  regex line {
     ^^ \h* <?before \w> [ <phrase>+ %% <h> ] $$
  }
  regex phrase {
   <bold> || <code> || <link> || \S+
  }
  token bold {
    '*' <( <-[*]>+ )> '*'
  }
  token code {
    '`' <( <-[`]>+ )> '`'
  }
  token anchor {
    ^^ '^' <( \w+ )>
  }
  token hr {
    ^^ '--' \h*
  }
  token list-element {
    ^^ \h* '*' \h+ [ <phrase>+ %% <h> ] $$
  }
  token link {
    '<'
       $<linktext>=<-[:]>+ ':' $<href>=<-[>]>+
    '>'
  }
}

