use Node;

class Markatu::Actions {
    my $code-class = 'prettyprint skin-sunburst lang-perl6 linenums';
    my $output-class = 'w3-black w3-round w3-padding';
    has %.vars;
    sub escape($str) {
      $str.subst(/ '\\`'/, '`', :g)
          .subst('&','&amp;', :g)
          .subst('>','&gt;', :g)
          .subst('<','&lt;', :g)
          .subst('"','&quot;', :g)
    }
    sub touch-up($str) {
        $str.lines.grep({ $_ !~~ /'MONKEY'/ }).join("\n");
    }
    my %ran;
    sub runit($cmd) {
        return %ran{ $cmd } if %ran{ $cmd }:exists;
        if $cmd.ends-with('.p6') {
          note "running perl6 $cmd";
          %ran{ $cmd } = qqx[perl6 $cmd];
        } else {
          note "running '$cmd'";
          %ran{ $cmd } = qqx[$cmd];
        }
        %ran{ $cmd };
    }
    method TOP($/) {
      $/.make: $<blocks>.made
    }
    method blocks($/) {
      $/.make: Node.new:
           children => $<block>.map: { .made }
    }
    method block($/) {
        my $what = .made with $<p> // $<bare> // $<include-code> // $<include>
           // $<output> // $<tag> // $<codefence> // $<hr> // $<anchor> // $<list>;
        die "parser error: unknown blocktype for '$/'" without $what;
        $/.make: $what;
    }
    method list($/) {
      $/.make: Node.new: children => $<list-element>.map: *.made
    }

    method range($/) {
      $/.make: $<min>-1 .. $<max>-1
    }
    
    method include-code($/) {
      my $file = "$/".trim;
      $file.IO.e or note "Could not find $file";
      my $text = $file.IO.slurp.trim;
      with $<range> {
        $text = $text.lines[.made];
      }

      $/.make: Node.new:
          :tag<pre>,
          :text(touch-up escape $text.trim),
          :class($code-class),
          :inline;
    }

    method output($/) {
      $/.make: Node.new: :tag<pre>, :text((escape runit "$/").trim), :class($output-class), :inline;
    }
    method codefence($/) {
      my $indent = "$<indentation>";
      my $level = $indent.chars;
      my $class = .made with $<class-list>;
      $/.make: Node.new: :tag<pre>,
           :text(escape (~$/).indent(-$level)),
           |($class ?? :$class !! Empty),
           :inline;
    }
    method p($/) {
      $/.make: Node.new: :tag<p>, :text($<line>.map({.made}).join("\n"))
    }
    method bare($/) {
      $/.make: Node.new: :text($<bareline>.map({.made}).join("\n"))
    }
    method parse-label($/) {
      my %h;
      %h<tag> = ~$<tag>;
      %h<class> = .made with $<class-list>;
      %h<attrs><id> = ~$_ with $<id>;
      with $<key> -> $k {
        my @keys = $<key>.map(~*);
        my @vals = $<val>.map(~*);
        %h<attrs>{@keys} = @vals;
      }
      %h;
    }
    method class-list($/) {
      $/.make: "$/".split(',').join(" ");
    }

    method find-var($var) {
      my %h;
      my $found = %.vars{$var} or return;
      $found;
    }
    method tag($/) {
      my %args = self.find-var(~$<label><tag>) // self.parse-label($<label>);
      %args<text> = ~$_ with $<text>;
      my $node = Node.new: |%args;
      with $<blocks> {
        $node.children = $<blocks>.map: -> $x { |$x.made.children }
      }
      %.vars{~$_} = self.parse-label($<label>) with $<label><declare-variable>;
      $/.make: $node;
    }
    method line($/) {
      $/.make: Node.new: text =>
         ($<phrase> Z=> $<h>).map( { .key.made ~ .value }).join;
    }
    method bareline($/) {
      $/.make: Node.new: text =>
         ($<phrase> Z=> $<h>).map( { .key.made ~ .value }).join;
    }
    method phrase($/) {
      return $/.make(.made) with $<link>;
      return $/.make: Node.new: :tag<b>, :text("$_"), :inline with $<bold>;
      return $/.make: Node.new: :tag<u>, :text("$_"), :inline with $<underline>;
      return $/.make: Node.new: :tag<code>, :text(escape "$_"), :inline with $<code>;
      $/.make: Node.new: :text("$/");
    }
    method link($m) {
      given ("$m<linktext>") { 
          when /^ 'img' ['.' $<class>=[.*] ]? $/ {
            my $src = ~$m<href>;
            my %attrs = :$src;
            %attrs<class> = "$_" with $<class>;
            $m.make: Node.new: :tag<img>, :%attrs, :inline;
          }
          default {
            my $href = ~$m<href>;
            $href = "http://$href" unless
               $href.contains('://') || $href.starts-with('#') || $href.starts-with('^');
            $href = '#' ~ $href.substr(1) if $href.starts-with('^');
            my %attrs = :$href;
            %attrs<target> = 'blank' if $href.contains('://');
            $m.make: Node.new: :tag<a>, :text($_), :%attrs, :inline;
          }
      }
    }
    method hr($/) {
      $/.make: Node.new: :tag<hr>, :collapse;
    }
    method anchor($/) {
      $/.make: Node.new: :tag<a>, attrs => :name("$/");
    }
    method include($/) {
      my $file = "$/".trim;
      my $text = $file.IO.slurp;
      with $<range> {
        $text = $text.lines[.made].join("\n");
      }
      $text = escape $text;
      $/.make: Node.new: :tag<pre>, :$text, :inline;
    }

    method list-element($/) {
      $/.make: Node.new: :tag<li>, :children( $<phrase>.map({.made})  ), :inline
    }
}
