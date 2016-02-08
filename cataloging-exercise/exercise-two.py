#!/usr/bin/env python
from __future__ import print_function
import argparse
# see https://github.com/edsu/pymarc for pymarc documentation
from pymarc import MARCReader


# command line arguments
parser = argparse.ArgumentParser(description='delete all of a field or subfield from a set of MARC records')
parser.add_argument('input_file', help='a MARC file to operate upon')
parser.add_argument('-f', '--field', type=str, help='field to delete')
parser.add_argument('-s', '--subfield', type=str, help='subfield to delete')
parser.add_argument('output_file', help='a file to write processed records to')
parser.add_argument('--verbose', action='store_true', help='print information while running')
args = parser.parse_args()

if args.subfield and not args.field:
    print("Error: cannot pass a subfield without a field! I don't know what to do!")
    exit(1)

output = open(args.output_file, 'wb')

# basic outline
with open(args.input_file, 'rb') as fh:
    # these parameters make pymarc more tolerant of the inevitable encoding errors
    reader = MARCReader(fh, to_unicode=True, force_utf8=True, utf8_handling='ignore')
    for record in reader:
        # if we're removing a subfield
        if args.subfield:
            # loop over fields
            for field in record.get_fields(args.field):
                if args.subfield in field:
                    # delete each subfield
                    for subfield in field.get_subfields(args.subfield):
                        field.delete_subfield(args.subfield)
                        if args.verbose:
                            print('removed', args.field + '$' + args.subfield, 'from', record.title())
        # ...we're removing a field
        else:
            if args.field in record:
                # get_fields returns a list which we unpack with "*"
                record.remove_field(*record.get_fields(args.field))
                if args.verbose:
                    print('removed', args.field, 'from', record.title())

        output.write(record.as_marc())


output.close()
