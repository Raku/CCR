# November 13 2009 — crying wolf and slinging mud
    
*Originally published on [14 November 2009](http://strangelyconsistent.org/blog/november-13-2009-crying-wolf-and-slinging-mud) by Carl Mäsak.*

> 24 years ago, mud traveling at extremely high speeds flooded the [town of Armero](https://en.wikipedia.org/wiki/Armero_tragedy) and killed over 20,000 inhabitants:

The night the volcano erupted, a fluidized mass of rock fragments and gases fell into the Lagunilla river, creating a megatsunami of mud, ash and water. It is estimated that the wave was traveling at 300 miles per hour as it hit Armero. Traveling through the narrow Lagunilla river, it gained speed and power as it hit the plains of the city of Armero. It took less than 15 minutes from the time of the eruption, to the time when the city was gone.

Gigantic rocks embedded in the bottom of the Lagunilla river were moved from their prehistoric positions and started travelling along with the wave, helping to destroy everything in its path. After the first few hours, a lesser secondary wave caused further damage. The next morning, the pilot of a plane transmitting to Colombia's Civil Defense system, overflying what was supposed to be Armero, is known to have remarked: *"Dios mio, Armero ha sido borrado del mapa"* ("Oh my God, Armero has been erased from the map").

The saddest thing? People had cried wolf over the volcano erupting, so in the weeks leading up to the eruption, even though geologists warned about the dangers, officials (including the mayor) told the inhabitants that the town was safe.

Dear November diary: today I wrote a pastebin using Web.pm technology.

Actually, I wrote the third of one. But I'm very pleased about how little code I needed for that third.

Here are the three things I consider necessary for it to be called a pastebin.

- A form lets you enter text, and when you press the Submit button...
- ...you get to a page that says "lolyoumadeapaste" and gives you an URL...
- ...whose page contains the paste you made.

I did the third part. You can look at pastes, but you can't make them. :)

Here's the code I used to 'seed' the database with a paste:

```raku
use v6;
use Squerl;
my $DB = Squerl.sqlite('pastes.db');
$DB.create_table: 'pastes',
    'id'    => 'primary_key',
    'title' => 'String',
    'body'  => 'String',
 ;
my $pastes = $DB<pastes>;
$pastes.insert(314, 'This is a test', "This paste is a test\nLine 2");
```

And here's the code that shows the paste:

```raku
use Web::Request;
use Squerl;
my $DB = Squerl.sqlite('pastes.db');
my $pastes = $DB<pastes>;
my $req = Web::Request.new(%*ENV);
my $id = $req.GET<id>;
my @found = $pastes.filter('id' => $id).llist;
if @found {
    say @found[0][2];
}
else {
    say "Paste not found";
}
```

(**Update 2009-12-06:** It's now `say @found[0]<body>;` — see comments below.)

I'm pleased about how little code was needed for this. There's a few glue bash-script and Apache-config files to make it all work, but nothing out of the ordinary.

The paste is live here, unless you're coming to this blog post from the future, in which case it's probably long dead. Enjoy it while it lasts.

I expect to do more pastebin hacking in the near future.
