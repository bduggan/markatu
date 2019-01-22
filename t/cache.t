#!/usr/bin/env perl6

use Markatu::Grammar;
use Node;
use Markatu::Actions;
use Test;

my $in  = q:to/X/;
  +OUTPUT hello.p6
  X

%*ENV<MARKATU_CACHE_DIR> = $*TMPDIR.child(".markatu-cache-{$*PID}");

my $g = Markatu::Grammar.new;
my $actions = Markatu::Actions.new;
my @calls;
&QX.wrap: -> |c { @calls.push(c); callsame; }

indir $?FILE.IO.sibling('mt'), {
  my $match = $g.parse($in,:$actions);
  my $out = $match.made;
  like $out, /'hello world'/, 'first time ok';
}

indir $?FILE.IO.sibling('mt'), {
  my $match = $g.parse($in,:$actions);
  my $out = $match.made;
  like $out, /'hello world'/, 'second time ok';
}

is +@calls, 1, '1 call';
is @calls[0], \"perl6 hello.p6", 'right call';

done-testing;

