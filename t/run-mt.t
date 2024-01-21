#!/usr/bin/env raku

use Markatu::Grammar;
use Node;
use Markatu::Actions;
use Test;

my $g = Markatu::Grammar.new;

%*ENV<NO_PRETTY_COLOR_ERRORS> = 1;

chdir $?FILE.IO.parent.child('mt');

for dir(test => / '.mt'$/).sort -> $f {
  my $in = $f.slurp;
  ok $g.parse($in), $f.basename;
  my $actions = Markatu::Actions.new;
  my $match = $g.parse($in,:$actions);
  ok $match, "parse { $f.basename } with actions";
  my $out = $match.made;
  ok $out, "made something { $f.basename }";
  my $html = $out.render;
  ok $html, "Rendered { $f.basename }";
  my $file = $?FILE.IO.parent.child('html').child($f.basename ~ '.html');
  my $want = $file.slurp;
  is $html.trim, $want.trim, "got html for { $f.basename }";
}

done-testing;
