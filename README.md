# serverprint - sometimes you just need to it yourself

Printing to a server via an ssh-connection without performing
cups-integration stuff.

## Usage

- `serverprint -f file/to/print.pdf`
  - server (SSH Host) will default to `stuga`
  - printer name will default to `Stuga`
  - Number of copies will default to `1`

### Options

- `-p printername` will use the printer with the given name
- `-s servername` will connect to servername (will be passed to scp)
- `-n number-of-copies`
- `-f path/to/file` the file to be printed
- `-o "lpr-arguments"` will allow to pass lpr arguments to the command
  - The arguments must be enclosed in quotation marks (in order to group them together as one argument)
  - Example: `-o '-o sides=two-sided-long-edge'`
- `-c` will allow pdf-file conversion if necessary
  - It is determined necessary if the page dimensions do not match Din A4
  - or if the PDF-Version is bigger than `1.4`

[1]: https://rightsrestricted.com
