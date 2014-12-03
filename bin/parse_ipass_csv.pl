#!/opt/local/bin/perl

use warnings;
use strict;

use IO::File;

my $filename=shift @ARGV;
die 'no file specified' unless($filename);
my $input_fh=IO::File->new("< $filename");
die "Could not open file $filename" unless($input_fh);

my $header_line=$input_fh->getline;
chomp $header_line;
my @field_names=split(/,/, $header_line);

my @entries;
while(my $line=$input_fh->getline) {
    #print $line;
    chomp $line;

    my @parts;
    while($line) {
        #print qq(line: $line\n);
        my ($part)=($line=~/^(.[^"]+)"/);
        $part=$line unless($part);
        if($part=~/^"/) {
            $part.='"';
            $line=~s/^"//;
        }
        push @parts, $part;
        #print qq(part: $part\n);
        substr($line, 0, length($part))='';
    }

    #print qq(end line $line\n);
    #print map {qq($_\n)} @parts;
    my @fields;
    foreach my $part (@parts) {
        if($part=~/^"/) {
            $part=~s/^"//;
            $part=~s/"$//;
            push @fields, $part;
        } else {
            push @fields, split(/,/, $part);
        }
    }

    my %records;
    foreach my $i (0..$#fields) {
        #print qq($field_names[$i] $fields[$i]\n);
        $records{$field_names[$i]}=$fields[$i];
    }
    push @entries, \%records;

    #exit 0;
}

my $output_filename="out.csv";
my $out_fh=IO::File->new("> $output_filename") || die "could not open output file $output_filename";

$out_fh->print("Date,Payee,Category,Memo,Outflow,Inflow");
foreach my $record (@entries) {
    my ($date)=split(/\s+/, $record->{"Transaction date"});
    die "No date" unless($date);
    die 'no type' unless($record->{"Transaction type"});
    die 'no location' unless($record->{"Roadway"});
    my ($payee)=join(' ',
                     $record->{"Transaction type"},
                     $record->{"Roadway"},
                    );
    my $category='';
    die 'no location' unless($record->{"Location"});
    my $memo=join(' ',
                  $record->{"Transaction type"},
                  $record->{"Location"},
                 );
    my @change;
    my $amount=$record->{"Transaction amount"};
    die "no amount" unless(defined($amount));
    if($amount>0) {
        @change=[0, $amount];
    } else {
        @change=[-$amount, 0];
    }
    $out_fh->print(join(",",
                        $date,
                        $payee,
                        '',
                        $memo,
                        @change)."\n");
}
