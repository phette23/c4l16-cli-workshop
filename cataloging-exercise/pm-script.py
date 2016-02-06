# see https://github.com/edsu/pymarc for pymarc documentation
from pymarc import MARCReader

# @TODO use argparse & make this script require input file, output file, & limit parameters
input_file = 'example.mrc'
output_file = 'processed.mrc'
limit = 100
count = 0
output = open(output_file, 'wb')

# basic outline
with open(input_file, 'rb') as fh:
    # these parameters make pymarc more tolerant of the inevitable encoding errors
    reader = MARCReader(fh, to_unicode=True, force_utf8=True, utf8_handling='ignore')
    for record in reader:
        # stop if we're at the limit
        if count == limit:
            break
        else:
            count += 1
            # loop over 856 fields
            for field in record.get_fields('856'):
                # get _only the first_ $u, yes there could be more, we ignore that
                u = field.get_subfields('u')[0]
                # if the URL starts with HTTP...
                if u.startswith('http://'):
                    # delete it & add it back with HTTPS
                    field.delete_subfield('u')
                    field.add_subfield('u', u.replace('http', 'https'))
            output.write(record.as_marc())


output.close()
