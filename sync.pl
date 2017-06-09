#!/usr/bin/env perl
use v5.14;

# required core modules
use Term::ANSIColor;
use File::Temp qw(tempfile);
use File::Compare;
use File::Copy;
use autodie;
use File::Fetch;
use JSON::PP qw(decode_json);

my $nameRegex = qr{^[a-z][a-z0-9]*2[a-z][a-z0-9]*$};

# get list of installed XSLT scripts
my $url = "http://gsoapiwww.gbv.de/unapi/scripts_xslt";
my $json;
File::Fetch->new( uri => $url )->fetch( to => \$json ) or die;
#my $scripts = JSON::PP->new->decode($json) or die;
my $scripts = decode_json($json) or die;

# get modified scripts from unapi.gbv.de
foreach (grep { $_ =~ /$nameRegex/ } keys %$scripts) {
    my $xslfile = "$_/$_.xsl";

    my ($fh, $tempfile) = tempfile();
    binmode($fh, ':encoding(UTF-8)');
    my $xslt = $scripts->{$_}->{body};
    $xslt =~ s/\r\n/\n/g;
    print $fh $xslt;
    close $fh;

    if (compare($tempfile, $xslfile)) {
        mkdir $_ unless -d $_;
        copy($tempfile, $xslfile);
        say colored("$_ updated from unapi.gbv.de", "cyan");
    } else {
        say colored("$_ up to date", "green");
    }
}

# look for additional not installed scripts
foreach (glob('*')) {
    $_ =~ /$nameRegex/ and -e "$_/$_.xsl" or next;
    say STDERR colored("$_ not installed at unapi.gbv.de", "orange")
        unless $scripts->{$_};
}

