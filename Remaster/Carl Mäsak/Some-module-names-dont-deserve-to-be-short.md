# Some module names don't deserve to be short
    
*Originally published on [11 December 2009](http://strangelyconsistent.org/blog/some-module-names-dont-deserve-to-be-short) by Carl Mäsak.*

*carlin*++ is doing some much-appreciated testing of the `installed-modules` branch of proto. He's now at the point where he's hunting down module name conflicts across projects.

Why are we interested in conflicts? Because the job of the `installed-modules` branch is to install Raku modules into a common modules directory, and then module name collisions suddenly become a reality.

Some collisions were due to modules both resting in the rakuxamples repo, and having moved out of it to separate repositories. Those were the easy ones to take care of. Nice to be rid of duplicates, too.

carlin dug up one collision that surprised me. There was a `Tags` module in November, and a `Tags` module in Web.pm. This never occurred to me before, despite the fact that I've witnessed the creation of both. The module in November handles the subject tagging of article pages in the wiki, as well as tag clouds (*ihrd*++). The module in Web.pm helps serialize HTML tags (*Tene*++). So this is not an easy case where one of the modules is a stale copy; they're actually non-homologous.

Yet the solution was clear after only a moment's thought: `Tags` in the Web.pm repo had the right to the short name (for now, at least), whereas `Tags` in November should really be `November::Tags`. I fixed that, and carlin could move on, unblocked.

Then I had a look at November, as if with new eyes. There are lots of modules there which really don't *deserve* such short names. Not in a connected world, that is, where a project suddenly needs to take other projects into account, and not just clobber namespaces willy-nilly.

These were the ones I decided to prefix with `November::`: `CGI`, `Cache`, `Config`, `Session`, `Tags`, `Utils`. Most of them because they simply *are* November-specific, so it makes more-than-sense to shove them into a `November::` namespace, for clarity as well as for civility.

The exception is `CGI`, which could actually be in its own repo and used by other projects. I chose to shove that into the `November::` namespace as a sort of social marker: `November::CGI` is our mess, we're getting rid of it as soon as we can, and we'd rather other people didn't use it.

Use [Web.pm](https://github.com/masak/web) instead. ☺
