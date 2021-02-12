# Parrot 0.5.1 &quot;Hatachi&quot; Released!
    
*Originally published on [18 December 2007](https://use-perl.github.io/user/JonathanWorthington/journal/35137/) by Jonathan Worthington.*

````
Lebennin

Silver flow the streams from Colos to Erui
In the green fields of Lebennin!
Tall grows the grass there. In the wind from the Sea
The white lilies sway,
And the golden bells are shaken of mallos and alfirin
In the green fields of Lebennin,
In the wind from the Sea!
````

On behalf of the Parrot team, I'm proud to announce Parrot 0.5.1 "Hatachi" [Parrot](http://parrotcode.org/) is a virtual machine aimed at running all dynamic languages.

Parrot 0.5.1 can be obtained via [CPAN](http://search.cpan.org/dist/parrot)
(soon), or [follow the download instructions](http://parrotcode.org/source.html).
For those who would like to develop on Parrot, or help develop Parrot itself,
we recommend using [Subversion](http://subversion.tigris.org/)
or [SVK](http://svk.bestpractical.com/)
on [our source code repository](https://svn.raku.org/parrot/trunk/)
to get the latest and best Parrot code.

Parrot 0.5.1 News:
````
- Documentation
  + PDD19 (PIR) - reflect state on the ground; incorporate old IMCC docs
  + PDD25 (Concurrency) - launch out of draft
  + Improve documentation of deprecated parrot features.
- Compilers
  + PCT: Parrot Compiler Toolkit redesigned and updated
  + NQP: major updates, including support for namespaces,
    module/class declarations, methods
  + IMCC: remove .sym as alias for .local. Remove .pcc_
    prefix for calling directives (.pcc_begin became .begin_call).
  + PIRC: creates an AST during the parse.
  + PGE: more updates to match S05 syntax.
- Languages
  + raku: re-implemented using PCT and NQP, new object subsystem
  + abc: re-implemented using PCT and NQP
  + eclectus: initial implementation
  + plumhead: add PCT variant
  + punie: re-implemented using PCT and NQP, extended to handle subroutines
    Happy 20th Birthday, Perl!
  + pynie: re-implemented using PCT and NQP
  + PIR: start conversion to NQP (under construction)
- Implementation
  + new opcodes: 'die', 'addhandler', 'copy'
  + Initial implementation of Concurrency PDD
  + Add 'arity' method to Sub and NCI PMCs
- Miscellaneous
  + Bug cleanup
  + consting, attribute marking, warnings cleanup, memory leaks, GC...
  + dead code removal (includes some defunct languages)
````

Thanks to all our contributors for making this possible, and our
sponsors for supporting this project.

Enjoy!
