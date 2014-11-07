# serverprint - sometimes you just need to it yourself

Printing to a server via an ssh-connection without performing
cups-integration stuff.

## Usage

- `serverprint file/to/print.pdf`
  - server (SSH Host) will default to `stuga`
  - printer name will default to `Stuga`
  - Number of copies will default to `1`
  - It will automatically try to convert pdf-files if it needs
    to.

### Options

- `-p printername` will use the printer with the given name
- `-s servername` will connect to servername (will be passed to scp)
- `-n number-of-copies`
- `-f path/to/file` the file to be printed
- `-o "lpr-arguments"` will allow to pass lpr arguments to the command
  - The arguments must be enclosed in quotation marks (in order to group them together as one argument)
  - Example: `-o '-o sides=two-sided-long-edge'`
- `-c` or `--convert` will allow pdf-file conversion if necessary
  - It is determined necessary if the page dimensions do not match Din A4
  - or if the PDF-Version is bigger than `1.4`
  - It is activated by default
- `--no-convert` deactivates the convert-capability
- `--two-sided` Print on front and back (default)
- `--one-sided` Print only on the front of the page
- `--no-side` Do not pass side-information to the print-server
  (use its default)
- `--pages-per-print-page` takes a number as argument to
  represent how many document-pages should be printed per
  printed-page. It should be divideable by two, or equal to one.

## Dependencies

  - **perl**
  - For convert-support (activated by default)
    - **ghostscript**: for the `ps2pdf` binary
    - **poppler** or **xpdf**: for the `pstopdf` binary and the `pdfinfo` binary

[1]: https://rightsrestricted.com
