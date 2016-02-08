from __future__ import print_function
import argparse
# see https://github.com/edsu/pymarc for pymarc documentation
from pymarc import Field, MARCReader


# command line arguments
parser = argparse.ArgumentParser(description='process MARC records & write results to a file')
parser.add_argument('input_file', help='a MARC file to operate upon')
parser.add_argument('--limit', type=int, help='number of records to process')
parser.add_argument('output_file', help='a file to write processed records to')
parser.add_argument('--verbose', action='store_true', help='print information while running')
args = parser.parse_args()

count = 0
output = open(args.output_file, 'wb')

# basic outline
with open(args.input_file, 'rb') as fh:
    # these parameters make pymarc more tolerant of the inevitable encoding errors
    reader = MARCReader(fh, to_unicode=True, force_utf8=True, utf8_handling='ignore')
    for record in reader:
        # stop if we're at the limit
        if count == args.limit:
            break
        else:
            count += 1
            # create a copy of the record
            new_record = record
            # loop over 856 fields
            for field in record.get_fields('856'):
                # first remove the field from the copied record...
                new_record.remove_field(field)
                # loop over u subfields
                for u in field.get_subfields('u'):
                    # if 856$u is a Harvard "page delivery service" URL, proxy it
                    if u.startswith('http://nrs.harvard.edu'):
                        new_u = Field(
                            tag='856',
                            indicators=['4', '1'],
                            # prepend (fake) proxy server URL to old URL
                            subfields=['u', 'https://proxy.example.com/login?url=' + u]
                        )
                        new_record.add_field(new_u)
                        if args.verbose:
                            print('added proxy prefix to URL:', u)
                    # if 856$u is an LoC table of contents, don't add it to the new record
                    elif u.startswith('http://www.loc.gov/catdir/toc/'):
                        if args.verbose:
                            print('deleted ToC URL:', u)
                        pass
                    # default to adding the field
                    else:
                        new_record.add_field(field)

            output.write(new_record.as_marc())


output.close()
