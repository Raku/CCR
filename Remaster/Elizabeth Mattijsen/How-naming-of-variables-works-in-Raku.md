How naming of variables works in Raku
=====================================

In the first four articles in this series comparing Perl to Raku, we looked into some of the issues you might encounter [when migrating code](Migrating-Perl-code-to-Raku.md), how [garbage collection works](Garbage-Collection-in-Raku.md), why [containers replaced references](Containers-in-Raku.md), and using [(subroutine) signatures](How-Subroutine-Signatures-work-in-Raku.md) in Raku and how these things differ from Perl.

Here, in the fifth article, we will look at the subtle differences in [sigils](https://www.perl.com/article/on-sigils/) (the symbols at the start of a variable name) between Perl and Raku.

An overview
-----------

Let's start with an overview of sigils in Perl and Raku:

**Sigil** |  **Perl**  | **Raku**
  **@**   |  Array     | Positional
  **%**   |  Hash      | Associative
  **&**   | Subroutine | Callable
  **$**   |  Scalar    | Item
  **\***  | Typeglob   | n/a

