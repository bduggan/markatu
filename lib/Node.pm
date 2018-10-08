class Node {
    has $.text = '';
    has $.tag;
    has %.attrs;
    has Node:D @.children is rw;
    has @.class;
    has Bool $.inline;
    has Bool $.collapse;
    method Str { self.render }
    method attr-string {
      return '' unless %.attrs;
      return (join '', %.attrs.sort.map: -> (:$key,:$value) { qq[ $key="$value"] });
    }
    method start-tag($indent) {
      return '' unless $.tag;
      %!attrs<class> = @.class.join(' ') if @.class;
      ("<" ~ $.tag ~ self.attr-string ~ ">").indent($indent)
    }
    method close-tag($indent) {
      return '' unless $.tag;
      "</$.tag>".indent($indent);
    }
    method render(Node:D: :$indent = 0) {
        return "<$.tag" ~ self.attr-string ~ "/>".indent($indent) if $!collapse;
        if $.text and not $.tag {
            return $.text.indent($indent)
        }
        my $rendered = self.start-tag($indent);
        $rendered ~= "\n" unless $.inline;
        my $next-level = $indent;
        $next-level += 2 if $.tag;
        $rendered ~= @.children.map({
                 .render(:indent($next-level)) // "[nothing rendered for {.gist}]"
              }).join("\n");
        if $.inline {
          $rendered ~= $.text;
        } else {
          $rendered ~= $.text.indent($next-level);
        }
        $rendered ~= "\n" unless $.inline;
        $rendered ~= self.close-tag($indent);
        return $rendered;
    }
}

