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

## LICENSE

([The MIT License][mit])

Copyright © 2014:

- [Tim Reddehase][1]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[mit]: http://opensource.org/licenses/MIT
[1]: https://rightsrestricted.com
