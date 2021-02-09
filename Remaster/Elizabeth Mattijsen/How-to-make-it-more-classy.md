# How to make it more classy

*Originally published on [8 November 2018](https://opensource.com/article/18/11/how-make-perl-more-classy) by Elizabeth Mattijsen.*

This is the seventh in a series of articles about migrating code from Perl to Raku. This article looks at how to create classes (objects) in Raku and how it differs from Perl.

Perl has a very basic form of object orientation, which you could argue has been bolted on as an afterthought. Several attempts have been made to improve that situation, most notably [Moose](https://metacpan.org/pod/distribution/Moose/lib/Moose/Manual.pod), which "is based in large part on the Raku object system, as well as drawing on the best ideas from CLOS, Smalltalk, and many other languages." And, in turn, the Raku object creation logic has taken a few lessons from Moose.

Moose has inspired a number of other modern object systems in Perl, most notably [Moo](https://metacpan.org/pod/Moo#DESCRIPTION) and [Mouse](https://metacpan.org/pod/Mouse#DESCRIPTION). Before you start a new project in Perl, I recommend reading *[Modern Perl](http://onyxneon.com/books/modern_perl/modern_perl_2016_a4.pdf)*; among other things, it describes how to use Moose to create classes/objects.

For simplicity, this article will describe the general differences between basic Perl and basic Raku object creation.

## How to make a 'Point'

A picture is worth more than a thousand words. So, let's start with defining a **Point** class with two immutable attributes, **x** and **y**, and a constructor that takes named parameters. Here's how it would look in Perl:

```` perl
# Perl 5
package Point {
    sub new {
        my $class = shift;
        my %args  = @_;  # maps remaining args as key / value into hash
        bless \%args, $class
    }
    sub x { shift->{x} }
    sub y { shift->{y} }
}
````

And in Raku:

```` raku
# Perl 6
class Point {
    has $.x;
    has $.y;
}
````

As you can see, the Raku syntax is much more declarative; there is no need to write code to have a **new** method, nor is code needed to create the accessors for **x** and **y**. Also note that instead of **package**, you need to specify **class** in Raku.

After this, creating a **Point** object is remarkably similar in Perl and Raku:

```` perl
# Perl 5
my $point = Point->new( x => 42, y = 666 );
````

```` raku
# Perl 6
my $point = Point.new( x => 42, y => 666 );
````

The only difference is Raku uses **.** (a period) to call a method instead of **->** (Hyphen+Greater-than symbol).

## Error checking

In an ideal world, all parameters to methods would always be correctly specified. Unfortunately, we don't live in an ideal world, so it is wise to add error checking to your object creation. Suppose you want to make sure that both **x** and **y** are specified and are integer values. In Perl, you could do it like this:

```` perl
# Perl 5
package Point {
    sub new {
        my ( $class, %args ) = @_;
        die "The attribute 'x' is required" unless exists $args{x};
        die "The attribute 'y' is required" unless exists $args{y};
        die "Type check failed on 'x'" unless $args{x} =~ /^-?\d+\z/;
        die "Type check failed on 'y'" unless $args{y} =~ /^-?\d+\z/;
        bless \%args, $class
    }
    sub x { shift->{x} }
    sub y { shift->{y} }
}
````

> Pardon the **/^-?\d+\z/** line noise. This is a regular expression checking for an optional (**?**) hyphen (**-**) at the start of a string (**^**) consisting of one or more decimal digits (**\d+**) until the end of the string **(\z)**.

That's quite a bit of extra boilerplate. Of course, you can abstract that into an **is_valid** subroutine, like this:

```` perl
# Perl 5
sub is_valid {
    my $args = shift;
    for (@_) {        # loop over all keys specified
        die "The attribute '$_' is required" unless exists $args->{$_};
        die "Type check failed on '$_'" unless $args->{$_} =~ /^-?\d+\z/;
    }
    1
}
````

Or you can use one of the many parameter-validation modules on CPAN, such as **[Params::Validate](https://metacpan.org/pod/Params::Validate#DESCRIPTION)**. In any case, your code would look something like this:

```` perl
# Perl 5
package Point {
    sub new {
        my ( $class, %args ) = @_;
        bless \%args, $class if is_valid(\%args,'x','y');
    }
    sub x { shift->{x} }
    sub y { shift->{y} }
}
Point->new( x => 42, y => 666 );     # ok
Point->new( x => 42 );               # 'y' missing
Point->new( x => "foo", y => 666 );  # 'x' is not an integer
````

If you use Moose, your code would look something like this:

```` perl
# Perl 5
package Point;
use Moose;
has 'x' => ( is => 'ro', isa => 'Int', required => 1);
has 'y' => ( is => 'ro', isa => 'Int', required => 1);
no Moose;
__PACKAGE__->meta->make_immutable;
Point->new( x => 42, y => 666 );     # ok
Point->new( x => 42 );               # 'y' missing
Point->new( x => "foo", y => 666 );  # 'x' is not an integer
````

Note that with an object system like Moose, you don't need to create a **new** subroutine, like in Raku.

In Raku, however, this is all is built-in. The **is required** attribute trait indicates that an attribute *must* be specified. And specifying a type (e.g., **Int**) automatically throws a type-check exception if the provided value is not an acceptable type:

```` raku
# Perl 6
class Point {
    has Int $.x is required;
    has Int $.y is required;
}
Point.new( x => 42, y => 666 );     # ok
Point.new( x => 42 );               # 'y' missing
Point.new( x => "foo", y => 666 );  # 'x' is not an integer
````

## Providing defaults

Alternately, you might want to make the attributes optional and have them initialized to **0** if they are not specified. In Perl, that could look like this:

```` perl
# Perl 5
package Point {
    sub new {
        my ( $class, %args ) = @_;
        $args{x} //= 0;  # initialize to 0 is not given
        $args{y} //= 0;
        bless \%args, $class if is_valid( \%args, 'x', 'y' );
    }
    sub x { shift->{x} }
    sub y { shift->{y} }
}
````

In Raku, you would add an assignment with the default value to each attribute declaration:

```` raku
# Perl 6
class Point {
    has Int $.x = 0;  # initialize to 0 if not given
    has Int $.y = 0;
}
````

## Providing mutators

In the class/object examples so far, an object's attributes have been immutable. They can't be changed by the usual means after the object has been created.

In Perl, there are various ways to create a mutator (a method on the object to change an attribute's value). The simplest way is to create a separate subroutine that will set the value in the object:

```` perl
# Perl 5
...
sub set_x {
    my $object = shift;
    $object->{x} = shift;
}
````

which can be shortened to:

```` perl
# Perl 5
...
sub set_x { $_[0]->{x} = $_[1] }  # access elements in @_ directly
````

so you could use it as:

```` perl
# Perl 5
my $point = Point->new( x => 42, y => 666 );
$point->set_x(314);
````

Some people prefer to use the same subroutine name for both accessing and mutating the attribute. Specifying a parameter then means the subroutine should be used as a mutator:

```` perl
# Perl 5
...
sub x {
    my $object = shift;
    @_ ? $object->{x} = shift : $object->{x}
}
````

which can be shortened to:

```` perl
# Perl 5
...
sub x { @_ > 1 ? $_[0]->{x} = $_[1] : $_[0]->{x} }
````

so you could use it as:

```` perl
# Perl 5
my $point = Point->new( x => 42, y => 666 );
$point->x(314);
````

Here is a way this is used a lot, but it depends on the implementation detail of how objects are implemented in Perl. Since an object in Perl is usually just a hash reference with benefits, you *can* use the object as a hash reference and directly access keys in the underlying hash. But this breaks the object's encapsulation and bypasses any additional checks that a mutator might do:

```` perl
# Perl 5
my $point = Point->new( x => 42, y => 666 );
$point->{x} = 314;  # change x to 314 unconditionally: dirty but fast
````

An "official" way of creating accessors that can also be used as mutators uses [lvalue subroutines](https://perldoc.pl/perlsub#Lvalue-subroutines), but this isn't used often in Perl for various reasons. It *is* however very close to how mutators work in Raku:

```` perl
# Perl 5
...
sub x : lvalue { shift->{x} }  # make "x" an lvalue sub
````

So you could use it as:

```` perl
# Perl 5
my $point = Point->new( x => 42, y => 666 );
$point->x = 314;  # just as if $point->x is a variable
````

In Raku, allowing an accessor to be used as a mutator is also done in a declarative way by using the **is rw** trait on the attribute declaration, just like with the **is required** trait:

```` raku
# Perl 6
class Point {
    has Int $.x is rw = 0;  # allowed to change, default is 0
    has Int $.y is rw = 0;
}
````

This allows you to use it in Raku like this:

```` raku
# Perl 6
my $point = Point.new( x => 42, y => 666 );
$point.x = 314;  # just as if $point.x is a variable
````

If you don't like the way mutators work in Raku, you can create your own mutators by adding a method for them. For example, the **set_x** case from Perl could look like this in Raku:

```` raku
# Perl 6
class Point {
    has $.x;
    has $.y;
    method set_x($new) { $!x = $new }
    method set_y($new) { $!y = $new }
}
````

But *wait*: What's that exclamation point doing in **$!x** ???

The **!** indicates the *real* name of the attribute in the class; it gives direct access to the attribute in the object. Let's take a step back and see what the attribute's so-called [twigil](https://docs.raku.org/language/variables#index-entry-Twigil) (i.e., the secondary sigil) means.

## The '!' twigil

A **!** in a declaration of an attribute like **$!x** designates that the attribute is *private*. This means you can't access that attribute from the outside unless the class' developer has provided a means to do so. This *also* means that it can *not* be initialized with a call to **.new**.

A method for accessing the private attribute value can be very simple:

```` raku
# Perl 6
class Point {
    has $!x;            # ! indicates a private attribute
    has $!y;
    method x() { $!x }  # return private attribute value
    method y() { $!y }
}
````

This is, in fact, pretty much what happens automatically if you declare the attribute with the **.** twigil:

## The '.' twigil

A **.** in a declaration of an attribute like **$.x** designates that the attribute is *public*. This means that an accessor method is created for it (much like the example above with the method for the private attribute). This also means the attribute can be initialized with a call to **.new**.

If you otherwise use the attribute form **$.x**, you are not referring to the attribute, rather to its *accessor*. It is syntactic sugar for **self.x**. But the **$.x** form has the advantage that you can easily interpolate inside a string. Furthermore, the accessor can be overridden by a subclass:

```` raku
# Perl 6
class Answer {
    has $.x = 42;
    method message() { "The answer is $.x" }  # use accessor in message
}
class Fake is Answer {   # subclassing is done with "is" trait
    method x() { 666 }   # override the accessor in Answer
}
say Answer.new.message;  # The answer is 42
say Fake.new.message;    # The answer is 666 (even though $!x is 42)
````

## Tweaking object creation

Sometimes you need to perform extra checks or tweaks to an object before it is ready for consumption. Without getting into the [nitty-gritty of creating objects in Raku](https://docs.raku.org/language/classtut), you can usually do all the tweaking that you need by supplying a **TWEAK** method. Suppose you also want to allow the value **314** to be considered as an alternative to **666**:

```` raku
# Perl 6
class Answer {
    has Int $.x = 42;
    submethod TWEAK() {
        $!x = 666 if $!x == 314;  # 100 x pi is also bad
    }
}
````

If a class has a **TWEAK** method, it will be called *after* all arguments have been processed and assigned to attributes, as appropriate (including assigning any default values and any processing of traits such as **is rw** and **is required**). Inside the method, you can do whatever you want to the attributes in the object.

> Note that the **TWEAK** method is best implemented as a so-called **submethod**. A **submethod** is a special type of method that can be executed only on the class itself and *not* on any subclass. In other words, this method has the visibility of a *subroutine*.

## Positional parameters

Finally, sometimes an interface to an object is so clear that you do not need named parameters at all. Instead, you want to use positional parameters. In Perl, that would look something like this:

```` perl
# Perl 5
package Point {
    sub new {
        my ( $class, $x, $y ) = @_;
        bless { x => $x, y => $y }, $class
    }
    sub x { shift->{x} }
    sub y { shift->{y} }
}
````

Even though object creation in Raku is optimized for using named parameters, you *can* use positional parameters if you want to. In this case, you'll have to create your own "**new**" method. By the way, there is nothing special about the **new** method in Raku. You can create your own, or you can create a method with another name to act as an object constructor:

```` raku
# Perl 6
class Point {
    has $.x;
    has $.y;
    method new( $x, $y ) {
        self.bless( x => $x, y => $y )
    }
}
````

This looks very similar to Perl, but there are subtle differences. In Raku, positional arguments are obligatory (unless they're declared to be optional). Making them optional with a default value works pretty much the same as with attribute declaration, as does indicating a type: you specify those in the signature of the **new** method:

```` raku
# Perl 6
...
method new( Int $x = 0, Int $y = 0 ) {
    self.bless( x => $x, y => $y )
}
````

The [bless](https://docs.raku.org/routine/bless) method provides the logic of object creation with given named parameters in Raku: its interface is the same as the default implementation of the **new** method. You can call it whenever you want to create an instantiated object of a class.

Don't repeat yourself ([DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)) is a principle you should always use. One example of making it easier to DRY in Raku is the syntactic sugar for **x => $x** (a [Pair](https://docs.raku.org/type/Pair) in which the key has the same name as the variable for the value). In Raku, this can be expressed as **:$x**. That would make the above **new** method look like the following:

```` raku
$ Perl 6
...
method new( Int $x = 0, Int $y = 0 ) { self.bless( :$x, :$y ) }
````

After this, creating a **Point** object is remarkably similar between Perl and Raku:

```` perl
# Perl 5
my $point = Point->new( 42, 666 );
````

```` raku
# Perl 6
my $point = Point.new( 42, 666 );
````

## Summary

Creating classes in Raku is mostly declarative, whereas object creation in standard Perl is mostly procedural. The way classes are defined in Raku is very similar in semantics to Moose. This is because Moose was inspired by the design of the Raku object creation model, and vice-versa.

Performance concerns about object creation have always been a focus in both Perl and Raku. Even though Raku provides more functionality in object creation than Perl, benchmarks show that Raku has recently become faster than Perl at creating and accessing objects.
