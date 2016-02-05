#!/usr/bin/perl -w

# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# It is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# To receive a copy of the GNU General Public License, please write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use MARC::Batch;
use Encode qw(encode decode);
use utf8;
use open qw( :std :utf8);
use IO::File;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;

my $VERSION = 'MARCgrep.pl 1.4.1 - Pontificia Università della Santa Croce - http://en.pusc.it/bib/MARCgrep';

my $arg_count = $#ARGV;
my $help;
my $wantcount     = '';
my $separator     = ',';
my $condition     = '...,.,.,.,.';    # matches any datafield
my $invert        = '';
my $output_format = 'inline';
my $version       = '';
my $controlfields = '';
my $field_list    = '';

GetOptions(
    'h'   => \$help,
    'c'   => \$wantcount,
    'e:s' => \$condition,
    'f:s' => \$field_list,
    'o:s' => \$output_format,
    's:s' => \$separator,
    'v'   => \$invert,
    'V'   => \$version
) or pod2usage(2);

pod2usage( -exitstatus => 0, -verbose => 2 ) if ( $help || $arg_count == -1 );

if ($version) {
    print "$VERSION\n";
    exit 1;
}

$controlfields = 1 if ( $condition =~ /^00/ || $condition =~ /^LDR/ );

my $batch;
my $fh =
  IO::File->new( $ARGV[$#ARGV] )
  ;    # don't let MARC::Batch open the file, as it applies the ':utf8' IO layer
$batch = MARC::Batch->new( 'USMARC', $fh );
$batch->warnings_off();
$batch->strict_off();    # don't die for errors in the input file

my $printed_records = 0;
my $records_read    = 0;

RECORD: while () {
    my $record;
    eval { $record = $batch->next() };
    if ($@) {
        print STDERR "Bad MARC record " . $records_read . ": skipped.\n";
        next;
    }
    last unless ($record);
    $records_read++;
    if ( !check( $record, $condition, $controlfields ) != !$invert ) {
        report( $record, $output_format, $field_list ) if ( !$wantcount );
        $printed_records++;
    }
}

print $printed_records. "\n" if ($wantcount);

# -----

sub check {
    my $original_record = shift;
    my $condition       = shift;
    my $controlfields   = shift;

    if ( !$controlfields ) {

        # check data fields
        my $record = $original_record->clone();
        my ( $tag, $ind1, $ind2, $sf, $value ) = split /\Q${separator}\E/,
          $condition;
        $tag  = '.' if ( !defined($tag)   || length($tag)==0 );
        $ind1  = '.' if ( !defined($ind1)  || length($ind1)==0 );
        $ind2  = '.' if ( !defined($ind2)  || length($ind2)==0 );
        $sf    = '.' if ( !defined($sf)    || length($sf)==0 );
        $value = '.' if ( !defined($value) || length($value)==0 );
        my @fields = $record->fields();

        foreach my $field (@fields) {
            if ( $field->is_control_field() ) {

                # controlfields are not allowed here
                $record->delete_field($field);
                next;
            }
            if ( $field->tag() !~ /$tag/ ) { $record->delete_field($field) }
            elsif ( $field->indicator(1) !~ /$ind1/ ) {
                $record->delete_field($field);
            }
            elsif ( $field->indicator(2) !~ /$ind2/ ) {
                $record->delete_field($field);
            }
            else {
                foreach my $subf ( $field->subfields() ) {
                    my $sfcode = @$subf[0];
                    $field->delete_subfield( code => $sfcode )
                      if ( $sfcode !~ /$sf/ );
                }
                if ( !$field->subfields() ) {

                    # delete field if without subfields
                    $record->delete_field($field);
                }
                else {

                    # check value
                    foreach my $subf ( $field->subfields() ) {
                        my $sfcode  = @$subf[0];
                        my $sfvalue = @$subf[1];
                        $field->delete_subfield( code => $sfcode )
                          if ( $sfvalue !~ /$value/ );
                    }
                    if ( !$field->subfields() ) {

                        # delete field if without subfields
                        $record->delete_field($field);
                    }
                }
            }
        }

        return 1 if ( $record->fields() );
        return 0;
    }
    else {

        # check control fields
        my $record = $original_record->clone();
        my ( $tag, $pos1, $pos2, $value ) = split /\Q${separator}\E/,
          $condition;
        return check00x( $record->leader(), $pos1, $pos2, $value )
          if ( $tag eq '000' || $tag eq 'LDR' );
        return check00x( $record->field($tag)->data(), $pos1, $pos2, $value );
    }
}

sub check00x {
    my $field_value = shift;
    my $pos1        = shift || 0;
    my $pos2        = shift || $pos1 || 0;
    my $value       = shift || '.';

    return 1
      if ( substr( $field_value, $pos1, $pos2 - $pos1 + 1 ) =~ /$value/ );
    return 0;
}

sub report {
    my $record        = shift;
    my $output_format = uc(shift);
	my $field_list    = shift;

    if ( ( $output_format eq 'INLINE' || $output_format eq 'LINE' )
        && $field_list )
    {
        foreach my $f ( split /,/, $field_list ) {
			if ($f =~ /^#/) {
				# print tag and number of occurrences
				my $tag = substr($f,1,3);
				my @ff = $record->field($tag);
				print '#',$tag,'   ',scalar @ff,"\n";
			}
			
            if ( $f eq '000' || $f eq 'LDR' ) {
                print $record->leader() . "\n";
            }
            elsif ( $record->field($f) ) {
                if ( $record->field($f)->is_control_field() ) {
                    print $f. ' ' . $record->field($f)->data() . "\n";
                }
                else {
					my @ff = $record->field($f);
					for (my $i = 0; $i < scalar @ff; $i++) {
						# for each occurrence of $f
						my $f = $ff[$i];
		                print $f->tag(). ' '
		                  . $f->indicator(1)
		                  . $f->indicator(2) . ' ';
		                my $blanks = '';
		                foreach my $subfield ( $f->subfields() ) {
		                    if ( $output_format eq 'INLINE' ) {
		                        print '$'
		                          . @$subfield[0] . ' '
		                          . @$subfield[1] . ' ';
		                    }
		                    else {
		                        print $blanks. '_'
		                          . @$subfield[0] . ' '
		                          . @$subfield[1] . "\n";
		                        $blanks = '       ';
		                    }
		                }
		                print "\n" if ( $output_format eq 'INLINE' );
					}
                }
            }
        }
        print "\n";
        return;
    }
    print $record->as_usmarc()             if ( $output_format eq 'MARC' );
    print $record->as_formatted() . "\n\n" if ( $output_format eq 'LINE' );
    as_formatted_inline($record)           if ( $output_format eq 'INLINE' );
    return;
}

sub as_formatted_inline {
    my $record = shift;

    print 'LDR     ' . $record->leader() . "\n";
    foreach my $field ( $record->fields() ) {
        print $field->tag() . ' ';
        if ( $field->is_control_field() ) {
            print '    ' . $field->data() . "\n";
        }
        else {
            print $field->indicator(1) . ' ' . $field->indicator(2) . ' ';
            foreach my $subfield ( $field->subfields() ) {
                print '$' . @$subfield[0] . ' ' . @$subfield[1] . ' ';
            }
            print "\n";
        }
    }
    print "\n";
}

=head1 MARCgrep.pl

Extracts MARC records that match a condition on fields. Count and invert are available.
 
=head1 SYNOPSIS
 
MARCgrep.pl [options] [-e condition] file.mrc
 
 Options:
   -h   print this help message and exit
   -c   count only
   -e   condition
   -f   comma separated list of fields to print
   -o   output format "marc" | "line" | "INLINE"
   -s   separator string for condition, default ","
   -v   invert match

 Condition:
   -e  'tag,indicator1,indicator2,subfield,value'
 
=head1 OPTIONS
 
=over 8
 
=item B<-h>
 
Print this message and exit.
 
=item B<-c>

Count and print number of matching records

=item B<-e>

The condition to match in the record. 
 For data fields, the syntax is:

   tag,indicator1,indicator2,subfield,value

 where tag, indicator1, indicator2, subfield, and value are regular expressions patterns.
 Do not put spaces around the separators.

 For control fields, the syntax is:

   tag,pos1,pos2,value

 where tag starts with '00' (use '000' or 'LDR' for leader), pos1 is the starting position, 
 pos2 is the ending position, both 0-based. Value is a regular expression.

 Default condition (-e not specified) matches any data field.
 For control fields, only the tag is mandatory.

 Examples: -e '100,,,a,^A' will match records that contain 100$a starting with 'A'
           -e '008,35,37,(ita|eng)' will match records with language ita or eng in 008
           -e '(1|7)(0|1)(0|1),,2' will match 100,110,111,700,710,711 with ind2=2

=item B<-f>

Comma separated list of fields (tags) to print if output format is "line" or "inline". Default is any field.
 Note that if a tag is preceded by '#' sign (like in '#nnn'), a count of occurrences will be printed instead.

 Examples: -f '100,245' will print field 100 and 245
           -f '400,#400' will print all occurrences of 400 field as well as the number of its occurrences

=item B<-o>

Output format: "marc" for ISO2709, "line" for each subfield in a line, "inline" (default) for each field in a line.

=item B<-s>

Specify a string separator for condition. Default is ','.

=item B<-v>

Invert the sense of matching, to select non-matching records.

=item B<-V>

Print the version and exit.

=item B<file.mrc>

The mandatory ISO2709 file to read. Can be STDIN, '-'.

=back
 
=head1 DESCRIPTION
 
Like grep, the famous Unix utility, B<MARCgrep.pl> allows to filter MARC bibliographic
 records based on conditions on tag, indicators, and field value.

Conditions can be applied to data fields, control fields or the leader.

In case of data fields, the condition can specify tag, indicators, subfield and value using regular
 expressions. In case of control fields, the condition must contain the tag name, the starting
 and ending position (both 0-based), and a regular expressions for the value.

Options -c and -v allow respectively to count matching records and to invert the match.

If option -c is not specified, the output format can be "line" or "inline" (both human readable),
 or "marc" for MARC binary (ISO2709). For formats "line" or "inline", the -f option allows to specify
 fields to print.

You can chain more conditions using 

./MARCGgrep.pl -o marc -e condition1 file.mrc | ./MARCGgrep.pl -e condition2 -

=head1 KNOWN ISSUES

Performance.

Accepts and returns only UTF-8.

Checks are case sensitive.

=head1 AUTHOR

Pontificia Universita' della Santa Croce <http://www.pusc.it/bib/>

Stefano Bargioni <bargioni@pusc.it>

=head1 SEE ALSO

marktriggs / marcgrep at <https://github.com/marktriggs/marcgrep> for filtering large data sets

=head1 RELEASE NOTES

1.4.1  2015-05-22  Print number of ocurrences if a tag is followed by '#' in -f

1.4.0  2015-05-19  Print all occ of datafield (not only the first one) when -f is present

1.3.1  2012-01-20  Bad handling of undefined parts of the condition.

1.3    2012-01-04  Bad handling of '0' in indicators. Thanks to Pete Girling.

1.2    2011-12-05  Bad records handling. Thanks to Zeno Tajoli.

1.1    2011-12-02  Allow special regexp chars in separator. Thanks to Mark Triggs.

1.0    2011-11-28  Initial release.

=cut
