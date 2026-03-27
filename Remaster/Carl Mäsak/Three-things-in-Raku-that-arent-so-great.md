# Three things in Raku that aren't so great
    
*Originally published on [22 July 2009](http://strangelyconsistent.org/blog/three-things-in-perl-6-that-arent-so-great) by Carl Mäsak.*

I keep repeating how great Raku is, because it is. But there are things I wish were different, and that I feel are accidents of history. Maybe they will change before Christmas rolls around, maybe not. But at least to my mind, they stand out as *emergent mistakes*, good features that combine to make something pretty bad.

Here they are:

- Methods and Pod
- Form syntax and string interpolation
- Comments in the beginning of lines

Below, I'll go through each problem in detail.

## Methods and Pod

Raku has two ways of declaring package-like entities such as classes, roles and modules. One way is familiar from Perl, and looks like a single statement:

```raku
class Austria;
# code here
```

The other is familiar from some other languages, and looks like a block:

```raku
class Austria {
   # code here
}
```

For the purposes of this blog post, let's call these the *statement form* and *block form*, respectively.

The block form is supposed to be the general one, and you can tell from the spec because that's the one that doesn't have any restrictions to it. The statement form is restricted so that it may only occur once in a file, preferably (one might assume) somewhere at the top. In practice, this means that if you have one file with several classes in it, you'll have to use the block form. That's OK, because people like the block form anyway; that's the one they tend to use when no-one tells them not to.

Now, enter [Pod](https://github.com/Raku/old-design-docs/blob/master/S26-documentation.pod). Just like in Perl, the Pod directives are written on the leftmost column of the file, no exceptions. This has to do with parsing and stuff; it should be really easy to tell what's a Pod comment and what isn't. But look what happens: people will tend to use the block form for their classes, they will want to document them with Pod, and the result — indented methods and non-indented Pod — will be too hideously ugly for the poor Raku programmer to bear. So they will have to use the more restricted statement form. They will cry a little, because they like the block form. But in the end, they will switch back to the statement form, because the alternative will be too ugly to think about.

There hasn't been much of an uproar about this, because people haven't started Pod-documenting their methods in earnest yet. I did it with the Druid classes, and went through all the above stages: shocked realization, sadness, and then switching to the statement form on a massive scale, at least if they decide to keep their method Pod.

We never had this problem in Perl, because Perl doesn't have the block form. We haven't started having the problem in Raku, because Pod is in [a state of limbo](A-code-review-of-podparser-written-by-mberends.html), and people don't really know how to use it to document their methods anyway. But Pod and the block form for declaring classes (and stuff) don't mix well.

## Form syntax and string interpolation

E07 was written long ago, in Internet years. Some time after that, the string interpolation changed, and `{...}` was appropriated to mean "this part of the string isn't part of the string".

So people will be bitten every time they use an interpolating string with the `form` function. This error will be caught as a syntax error at compile time, so it's not a critical flaw, just bloody annoying.

Matt-*W*++ is still building [Form.pm](https://github.com/mattw/form/) for Raku, so this also hasn't become a real annoyance for people yet. But there's a corresponding thing with `eval` and interpolating strings that bites people all the time.

It's kinda double-edged: we all like `{...}` in interpolated strings, but it keeps coming back and biting us too, because we forget it's special syntax.

## Comments in the beginning of lines

There was a long bikeshedding discussion about this some years ago. Raku introduces *embedded comments*, comments which start with a `#` and then a bracketing character, with all the Unicode smorgasboard to choose from.

However, it was soon realized that people who commented things out by putting `#`s at the absolute beginning of lines might accidentally create embedded comments by placing their `#` next to a curly brace or a parenthesis or a bracket. So anything that looks like an embedded comment at the beginning of a line is now treated as a syntax error.

At this point I would like to add that this does not bother me very much. I have come to terms with this particular oddity of the language. But it took me a while, and I can still feel a lingering sense of dissatisfaction with Raku causing me to (*gasp*) *change a habit*, and one I don't think is a particularly bad one to begin with. Perl is supposed to accomodate a large range of common programming styles, and quickly commenting out some lines by prefixing them with `#`s is pretty common.

I've now learned to put `##` at the beginning of lines I want to comment out instead of just `#`. This takes care of any unintended embedded comments. So things are fine over here; I'm just worried that a lot of people will feel significant pain when they go through the same process of realization.

I'm not sure embedded comments are all that useful. I seem to find a use for them sometimes in one-liners, but very seldom in other circumstances. Are they really worth the special-casing of a common development technique?

## In conclusion

Raku (the spec) is lovely, except in spots. It also isn't finished yet. I like the fact that I can complain like this in a blog post, and smart people will pick my arguments apart, or mull over them and propose improvements for the synopses. All the above three misfeatures are hard to solve because they arise as consequences of features we want, and so fixing the emergent problems would mean going back and changing the features somehow. That's hard.

As usual, feel free to comment. I'm the only one I know who has been severely bitten by the first and the last things, but I'd love to hear if others have too, and how they felt about it.
