# Parametric Roles
    
*Originally published on [17 January 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38308/) by Jonathan Worthington.*

I meant to blog about what I was working on a bit more this week, but have ended up with my head in the code all week instead. The end result of this "codeathon" is that I'm now much further forward on my Hague grant. While some of the smaller tasks scheduled for December remain to be done, I have taken parametric roles from non-existent to doing everything I aimed to get them to do during January and some of the February aspects of them now work too. I've also done some work on the dispatcher refactor, got us distinguishing different routine types and have also used the end result to get submethod dispatch working as it should too. So, some details on the parametric roles.

In Raku, roles can take parameters. Roles exist to enable greater re-use of code than we could get through having plain old classes, and by allowing them to be parameterized we open the door to even more re-use. Taking a simple example, imagine we wanted to factor out a `greet` method into a role, which takes somebody's name and greets them. We want to parameterize it on the greeting.

```` raku
role Greet[Str $greeting] {
    method `greet` { say "$greeting!"; }
}
class EnglishMan does Greet["Hello"] { }
class Slovak does Greet["Ahoj"] { }
class Lolcat does Greet["OH HAI"] { }
EnglishMan.new.`greet`; # Hello
Slovak.new.`greet`; # Ahoj
Lolcat.new.`greet`; # OH HAI
````

Similarly, we could do a role for requests.

```` raku
role Request[Str $statement] {
    method request($object) { say "$statement $object?"; }
}
class EnglishMan does Request["Please can I have a"] { }
class Slovak does Request["Prosim si"] { }
class Lolcat does Request["I CAN HAZ"] { }
EnglishMan.new.request("yorkshire pudding");
Slovak.new.request("borovicka");
Lolcat.new.request("CHEEZEBURGER");
````

Sadly, the Slovak output sucks here. Borovicka is the nominative form of the word, and we need to decline it into the accusative case. But some languages don't care about that, and we don't want to have to make them all supply a transform. Thankfully, you can write many roles with the same short name, and a different signature, and multi-dispatch will pick the right one for you. So we write something to produce the accusative case in Slovak and pass it in. Here's the new code.

```` raku
role Request[Str $statement] {
    method request($object) { say "$statement $object?"; }
}
role Request[Str $statement, &transform] {
    method request($object) {
        say "$statement " ~ transform($object) ~ "?";
    }
}
module Language::Slovak {
    sub accusative($nom) {
        # ...and before some smartass points it out, I know
        # I'm missing some of the masculine animate declension...
        return $nom.subst(/a$/, 'u');
    }
}
class EnglishMan does Request["Please can I have a"] { }
class Slovak does Request["Prosim si", &Language::Slovak::accusative] { }
class Lolcat does Request["I CAN HAZ"] { }
EnglishMan.new.request("yorkshire pudding");
Slovak.new.request("borovicka");
Lolcat.new.request("CHEEZEBURGER");
````

Which means we can now properly order our borovicka in Slovakia, which is awesome. Until you do it in a loop and find the Headache['very bad'] role got mixed into yourself overnight, anyway...

I'll post more on the other bits I'm working on, or have worked on, soon. But parametric roles are the biggy. I'm not at all finished with them yet, but all of the code examples I gave here today now work. :-)
