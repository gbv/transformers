#!/usr/bin/env perl
use v5.14;

use autodie;
use File::Fetch;
use JSON::PP qw(decode_json);

my $json;
my $url = "http://gsoapiwww.gbv.de/unapi/formats";
File::Fetch->new( uri => $url )->fetch( to => \$json ) or die;
my $formats = decode_json($json);

say "digraph unapi {";
say "  rankdir=LR;";
say "  node[shape=plaintext];";

my %dot;
foreach (values %$formats) {
    #my $key = $_->{key};
    #my $name = $key; 
    #$name =~ s/[^a-z0-9]/_/g;
    #say "  $name [label=\"$key\"];";

    my @steps = split /\s*,\s*/, $_->{filter};
    push @steps, "<b>".$_->{key}."</b>";

    @steps = map {
        my $node = $_; 
        $node =~ s/[^a-z0-9]/_/g;

        my $label = $_ =~ /^<.*>$/ ? "<$_>" : "\"$_\"";
        $dot{"  $node [label=$label];"}++;

        $node;
    } @steps;


    while (@steps) {        
        my $a = shift @steps;
        my $b = $steps[0] or last;
        $dot{"  $a -> $b;"}++;
    }
}

say $_ for keys %dot;

say "}";
