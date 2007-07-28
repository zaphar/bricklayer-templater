use parser;
my $text = "<BKa>1<BKa>2</BKa></BKa><BKa>3</BKa>";

my $parsed = parser::parse_text($text);
