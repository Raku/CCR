# Introducing: Raku Marketing Assets Web App
    
*Originally published on [5 August 2018](https://perl6.party//post/Introducing-Perl-6-Marketing-Assets-Web-App) by Zoffix Znet.*

As some of you already may have known from occasional tweets and mentions in the [Weekly](https://rakudoweekly.blog), we have a [`raku/marketing` repo](https://github.com/raku/marketing) that contains some flyers and brochures for Raku.

With one of the Raku coredevs making a living as a Multi-Media Designer, the repo has seen a steady stream of new pieces designed, when inspiration strikes, or when someone makes a request. There are now several pieces available, but GitHub isn't the greatest interface for this sort of stuff.

## Introducing marketing.raku.org

To make it easier to see what we have available, we made a front-end for our marketing repo, that lets you browse all of the assets. It's hosted at [marketing.raku.org](https://marketing.raku.org)

## The Assets

Under the thumbnail of each asset, there are a few buttons that show you which formats are available for download. The last two buttons are the GitHub button and the pencil button. The former will lead you to GitHub to the folder that particular asset is at, where you can download any files that aren't shown on the front end (e.g. the source files). The latter will lead you to the New Issue page on the marketing repo, with title/ID of the piece pre-filled. This is in case you'd like to request different format, size, or some other changes for that piece.

Each piece has an ID number (a Unix timestamp, e.g `1516098660`).  If you want to refer to some piece, try to include its ID, as that's the easiest way for the designer to know what piece you're talking about.

[INB4](https://www.urbandictionary.com/define.php?term=inb4), the Camelia logo variants are so numerous because [the rules ](https://raw.githubusercontent.com/raku/mu/master/misc/camelia.txt) allow for her colours to be changed. Personally, I prefer transparent wings, as they're easier on my retinas than the default logo.

Keep in mind, you can request new pieces as well. Just [file a new Issue in the marketing repo](https://github.com/raku/marketing/issues/new), describing the content that you want, including the sizes/colour restrictions, and our volunteers will hook you up.

## The Prints

While files themselves are easy to make for free, the same isn't the case for hard copies. We (the volunteers handling the marketing repo) can't print any hardcopies for you. Unless you are able to use a local printing company and pay out of your own pocket, your best bet would be to contact [The Perl Foundation](https://www.perlfoundation.org/) and ask them if they can sponsor the prints. I know they made prints of the [*Introducing Raku* brochure](https://marketing.raku.org/id/1516098660/pdf_digital) for a conference in the past.

## Licenses

The assets shown in the marketing web app are licensed under [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).  The Camelia logo [is copyright by Larry Wall](https://raw.githubusercontent.com/raku/mu/master/misc/camelia.txt). Some of the pieces use purchased stock, which may have licenses that limit super-large print runs (50,000+ copies). Check the files in the repo or [contact Zoffix](https://twitter.com/zoffix) if you have an unusual usecase for the materials and wish to clarify the licensing.

The source files (InDesign/PhotoShop/Adobe Illustrator) themselves can be modified freely, under the terms of [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/). Any images/fonts/other assets used by those source files might have additional licensing restrictions, which will usually be noted in the directory for that asset.

## Conclusion

Going out for some tech meetup? Print out a few pieces from our [marketing web app](https://marketing.raku.org), hand them out, share the Raku love!

-Ofun
