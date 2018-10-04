#!/usr/bin/env perl6

use lib 'lib';

use Markatu::Grammar;
use Node;
use Markatu::Actions;

use Test;
my $g = Markatu::Grammar.new;

%*ENV<NO_PRETTY_COLOR_ERRORS> = 1;

my $match = @*ARGS[0];

for "t".IO.dir(test => / '.mt'$/).sort -> $f {
  next if $match and $f !~~ / "$match" /;
  my $in = $f.slurp;
  ok $g.parse($in), "$f" or exit
}
