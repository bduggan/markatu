use Node;

class Markatu::Actions {
    my $code-class = 'prettyprint skin-sunburst lang-perl6 linenums';
    my $output-class = 'w3-black w3-round w3-padding';
    has %.vars;
    sub escape($str) {
      $str.subst('&','&amp;', :g)
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
        note "running perl6 $cmd";
        %ran{ $cmd } = qqx[perl6 $cmd];
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
        my $what = .made with $<p> // $<include-code> // $<include>
           // $<output> // $<tag> // $<codefence> // $<hr> // $<anchor> // $<list-element>;
        die "parser error: unknown blocktype for '$/'" without $what;
        $/.make: $what;
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
    method parse-label($/) {
      my %h;
      %h<tag> = ~$<tag>;
      %h<class> = .made with $<class-list>;
      %h<attrs><id> = ~$_ with $<id>;
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
      my $made = '';
      for ($<phrase> Z=> $<h>) {
        $made ~= .key.made ~ .value
      }
      $/.make: Node.new: text => $made;
    }
    method phrase($/) {
      return $/.make(.made) with $<link>;
      return $/.make: Node.new: :tag<b>, :text("$_"), :inline with $<bold>;
      return $/.make: Node.new: :tag<code>, :text(escape "$_"), :inline with $<code>;
      $/.make: Node.new: :text("$/");
    }
    method link($/) {
      my $href = ~$<href>;
      $href = "http://$href" unless
         $href.contains('://') || $href.starts-with('#') || $href.starts-with('^');
      $href = '#' ~ $href.substr(1) if $href.starts-with('^');
      my %attrs = :$href;
      %attrs<target> = 'blank' if $href.contains('://');
      $/.make: Node.new: :tag<a>, :text(~$<linktext>), :%attrs, :inline;
    }
    method hr($/) {
      $/.make: Node.new: :tag<hr>, :collapse;
    }
    method anchor($/) {
      $/.make: Node.new: :tag<a>, attrs => :name("$/");
    }
    method include($/) {
      $/.make: Node.new: :tag<pre>, :text(escape "$/".IO.slurp.trim), :inline;
    }

    method list-element($/) {
      $/.make: Node.new: :tag<li>, :children( $<phrase>.map({.made})  ), :inline
    }
}