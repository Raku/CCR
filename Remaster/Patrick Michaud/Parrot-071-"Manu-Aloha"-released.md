# Parrot 0.7.1 "Manu Aloha" released
    
*Originally published on [17 September 2008](https://use-perl.github.io/user/pmichaud/journal/37468/) by Patrick Michaud.*

On behalf of the Parrot team, I'm proud to announce Parrot 0.7.1
"Manu Aloha." Parrot is a virtual machine aimed at running all dynamic languages.

Parrot 0.7.1 is available via CPAN (soon), or follow the download
instructions.  For those who would like to develop on Parrot, or help
develop Parrot itself, we recommend using Subversion on
our source code repository to get the latest
and best Parrot code.

Parrot 0.7.1 News:

```
- Implementation
  + add -I and -L command line options
  + support for null strings in NCI calls
  + preliminary support for resumable exceptions
  + add '.hll_map' method for dynamic HLL type mapping
  + more parrot_debugger fixes
  + remove obsolete '.past' extension
- Languages
  + Rakudo (Raku)
    - now over 3300 passing spectests
    - precompiled modules
    - precompiled scripts  (--target=pir can now be executed standalone)
    - Support for @*INC and %*INC varialbes
    - additional builtin methods and subs
    - added 'fail' function, warnings on use of undefined values
    - m/.../ regexes
    - qq, qw, q quoting forms
    - run tests in parallel
    - gather/take
    - Perl6MultiSub
  + Cardinal (Ruby):
    - 'require' and precompiled modules
    - many new tests
    - all Array tests pass
    - regexes
    - default arguments to functions
    - new committer
- Compilers
  + PCT:
    - add :loadinit attribute for PAST::Block
  + PIRC:
    - major refactoring to allow all PIR keywords as identifiers
    - links to libparrot now, so all Parrot ops are recognized as such
    - implemented .loadlib, .HLL_map, .HLL
- Miscellaneous
  + add Xlib and Mysql modules and test programs to NCI examples
  + many updates and cleanups to PDD documents
```

Thanks to all our contributors for making this possible, and our sponsors
for supporting this project.  Our next release is 21 Oct 2008.

Enjoy!
