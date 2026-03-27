# Asking #perl about Modern Perl
    
*Originally published on [21 June 2009](http://strangelyconsistent.org/blog/asking-perl-about-modern-perl) by Carl Mäsak.*

This is my first Perl post ever. 哈哈 

```
<masak> while I'm here, I'd like to talk about <a href='http://www.modernperlbooks.com/mt/2009/01/why-modern-perl.html'>Modern Perl</a>.
<masak> in y'all's opinion, what are the modules a Modern Perl user should be aware of?
<masak> I'm thinking of things like <a href='http://search.cpan.org/dist/Moose/'>Moose</a>, <a href='http://search.cpan.org/dist/Scalar-List-Utils/'>List::Util</a>, maybe <a href='http://search.cpan.org/dist/Catalyst-Runtime/'>Catalyst</a>...
<claes> it all depends on what the task is
<lucs> masak: <a href='http://dev.perl.org/perl5/news/2007/perl-5.10.0.html'>5.10</a> in general maybe
<claes> using <a href='http://perldoc.perl.org/warnings.html'>warnings</a>, <a href='http://perldoc.perl.org/strict.html'>strict</a> and perhaps <a href='http://search.cpan.org/dist/indirect/'>indirect</a> pragmas
<masak> I think things that we take for granted as good time-savers all qualify.
<masak> so maybe stuff like <a href='http://search.cpan.org/dist/Getopt-Long/'>Getopt::Long</a> too.
<claes> personaly I don't use Moose because I haven't had any use for it yet
<masak> for me as a Raku user, it's not that difficult to see the use for Moose.
<masak> I saw a blog post recently that said that Moose even helped the blogger <a href='http://elliotlovesperl.com/2009/06/16/moose-as-documentation/'>document things more succinctly</a>.
<masak> that is, even when he wasn't using Moose, he was using habits gained from it to write better documentation.
<Hinrik> <a href='http://search.cpan.org/dist/Perl-Critic/'>Perl::Critic</a>, definitely
<claes> <a href='http://search.cpan.org/dist/Devel-NYTProf/'>Devel::NYTProf</a> 
<Hinrik> some of the eventy things (<a href='http://search.cpan.org/dist/AnyEvent/'>AnyEvent</a>, <a href='http://search.cpan.org/dist/Coro/'>Coro</a>, <a href='http://search.cpan.org/dist/POE/'>POE</a>) too, if that's what your app requires
<Hinrik> and the various Test::* modules, of course
<masak> Hinrik: which ones, more exactly?
<Hinrik> <a href='http://search.cpan.org/dist/Test-Simple/'>Test::More</a> usually works for me, along with some other specialized ones depending on the typo of app
<Hinrik> e.g. <a href='http://search.cpan.org/dist/Test-Script/'>Test::Script</a> to test if scripts compile
<Hinrik> masak: oh, and <a href='http://search.cpan.org/dist/Devel-Cover/'>Devel::Cover</a> is also quite helpful in determining test coverage
<cfedde> see also <a href='http://search.cpan.org/dist/Modern-Perl/'>Modern::Perl</a> 
<cfedde> I think that the standard template will become 'use Modern::Perl; use Moose'
```

Feel the need to add something to the list? The comments are open.
