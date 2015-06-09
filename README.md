# serverprint - sometimes you just need to do it yourself

Printing to a server via an ssh-connection without performing
cups-integration stuff.

## Installation

The preferred way to install this, is via a package system. Currently only an
AUR-package (for Arch Linux) and a Homebrew-Formula (for OS X) are provided.

- AUR-package [serverprint](https://aur.archlinux.org/packages/serverprint)
- Homebrew-Formula
  [serverprint](colum://github.com/0robustus1/homebrew-rightsrestricted/blob/master/serverprint.rb)
  - Best to use the tap: `brew tap 0robustus1/rightsrestricted`, and then to
    install `brew install serverprint`

If you are not using one of these distributions/operating systems, you can
install it on your own.  Just download the current release, untar the tarball
and change into the directory:

- `cd serverprint-...`
- `sudo make install` will install the necessary files into the `/usr` hierarchy.

If you don't want to install into the `/usr` hierarchy, you can specify a
`prefix` instead.  So for example: `make prefix=~/.local install` would install
into the `~/.local` hierarchy.

You however need to manually ensure that the dependencies are being met.

### Dependencies

  - **perl**
  - For convert-support (activated by default)
    - **ghostscript**: for the `ps2pdf` binary
    - **poppler** or **xpdf**: for the `pstopdf` binary and the `pdfinfo` binary

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

## Configuration

One can also configure some of the more general settings with a
configuration file. This file should be located at `~/.serverprintrc`.

The config-file consists of key-value pairs. Each pair represents a line
inside of the config. Key and value are separated by the equals-sign `=`.
Trailing and leading white-space is allowed.

```
server-name = foobar
printer-name=Foobar
```

The following configuration-settings are supported:

- **server-name**
  - The name of the server to connect to. Should usually be the Host of an ssh-config. Corresponds to the `-s` switch.
- **printer-name**
  - No The name of the printer on the foreign host. Corresponds to the `-c` switch.
- **auto-convert**
  - Whether or not auto-convert should be tried on pdf-files. Needs a numeric argument, with `1` representing true/on and `0` representing false/off.
- **number-of-copies**
  - Sets the default number of copies for every print-task.

[1]: https://rightsrestricted.com
