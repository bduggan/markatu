class Node {
    has $.tag;
    has $.text = '';
    has @.children;

    method render {
          "<$.tag>"
        ~ @.children.map({ .render }).join
        ~ $.text
        ~ "</$.tag>";
    }
}

say Node.new( :tag<div>,
      children => (
        Node.new(:tag<p>, :text<hello>),
        Node.new(:tag<pre>, :text<world>)
      )
    ).render;


