# Command line tools for archivists

There are numerous ways archivists can benefit from command line tools. In particular, the exercises below will cover conversion of character encoding, as well as batch renaming of files. Parts of the cataloger and webdev exercises will likely be of interest, too; be sure to check those out after you're finished here!

OK, here we go!

## Setup

(Get a tarball with junkfiles.py and anything else I need you to have. Untar it. Get to the right directory.)

## File formatting issues

Let's say you've got some files that aren't in the right character set. They're in ASCII, but you need them to be in UTF-8 Unicode. Or they're in UTF-8 but they need to be in UTF-16.

You can look at what format your file is with the `file` command.

Navigate to (SOME DIRECTORY) and type the following:

`file -bi lorem.txt`

The `-b` flag tells it to be brief, not to put the filename at the beginning of the output.

Including `-i` changes the format of its output to include (MIME type)[https://en.wikipedia.org/wiki/Media_type] along with, if applicable, the character encoding. To see the difference, go ahead and also type

`file -b lorem.txt` or `file lorem.txt`

Sometimes having the more precise output is helpful, so getting in the habit of using `-bi` is not a bad choice.

So we know our file is UTF-8. 

Look inside the file. There are a number of ways to do this, but my favorite is `more`. Here's the command for that:

`more lorem.txt`

You can scroll slowly by hitting Enter, or quickly by hitting the spacebar. If you are tired of scrolling, just type the letter `q`.

Digression: the command `clear` will remove all the old commands and files you've viewed from your field of view, giving you a nice, clean command line interface. Feel free to use it at any point. You can hit the up arrow to get to your last command, and use up and down to scroll back through earlier commands.

You can change the formatting of a file with `iconv`.

`iconv -f UTF-8 -t UTF-16  lorem.txt > lorem2.txt`

(THIS IS NOT VERY USEFUL, THOUGHTS?)

(MAYBE MORE USEFUL? 
`echo "Êàêèå-òî êðàêîçÿáðû" | iconv -t latin1 | iconv -f cp1251 -t utf-8` outputs Какие-то кракозябры)

## Batch renaming files

Let's pretend you have volunteered to archive all of the data from all the Code4Lib conferences up to now. Thanks! Unfortunately, the data were put together by lots of really enthusiastic volunteers, who were not given a complete file naming convention ahead of time. (Let’s pretend there aren’t a ton of metadata experts in the Code4Lib community who would prevent that from happening.) Everything is in CSV (comma-separated values) format.

Navigate to the folder (SOME FOLDER) Run the following command:

`./junkfiles.py`

Now, change directory (`cd`) to the `c4lfiles` directory, and look at what's in there (`ls`).

As you can see, there are about 100 files there, all from different years. They're kind of a mess. Renaming all of these files to all use the same naming convention would be tedious and take quite a while to do by hand, but we're going to clean this whole thing up with less than five minutes of work.

Now, there are a number of ways to do bulk edits of filenames on a CLI, including writing a script in Python or bash, or doing clever things with UNIX's find command. These are all totally valid. We’ll be using the `rename` command today.

### Rename

Rename uses something called "regular expressions," or as they are commonly referred to, "regex," to match on and change filenames. We are not going into regex in depth today, but we will use some fairly simple regular expressions, which will be explained along the way, to do the work we need to do. `rename` uses the Perl flavor of regular expressions.

```rename -[flags] [regular expression] files```

There's one super important flag you should know about, `-n`. That allows you to look at what the command will do, without actually running the command, which can save you from a LOT of pain. It is SO GOOD.

### Regex

This is by no means a complete tutorial on regular expressions. You won't walk away, today, as a regex witch or wizard (unless you walked _in_ that way), and that's OK. I'm not one, either. 

The cool thing about regular expressions is that they're used a whole lot, so if you're trying to do something, you can Google the thing you're trying to do, and someone probably already wrote the regex you need; today's workshop will hopefully at least give you enough of a background to look at someone else's regex and judge whether it might work for you or not. 

It's beyond of the scope of what we're doing today, but, if you'd like to play with regular expressions on your own, [RegExr](http://regexr.com/) is a really nice interface for doing so. If you're already comfortable with regular expressions, you might enjoy [Regex Golf](http://regex.alf.nu/) or [Regex Crossword](https://regexcrossword.com/).

Here's a list of the regular expression syntax we'll use today (and maybe one we won't, but it's good to know), so you can reference them as we're doing examples:
- `s/x/y/` - You may have seen this one around various tech chats, used as a shorthand for "I meant y, not x." This takes out x and replaces it with y ("s" is for "substitute," but the s/x/y/ pattern is referred to as a "switch statement")
- `.` - this is a special character in regex and means "any character"
- `\` - this is the escape character, allowing you to use a special character as a literal (if you want to match on a period, use `\.`)
<!---
- `^` - means "not," in any case we'll use it today; it can also mean "beginning of line"
-->
- `$` - means "the end of the string" (if it's in the first half of a switch statement)
- `[]` - means "character class," or "match one thing out of what's inside the brackets"; it changes the behavior of special characters, too 
- `()` - means "group" and allows a match to be referred to later
- `$` - refers to a previously matched group (e.g. `$1`) (if it's in the second half of a switch statement)
- `*` - means "match the preceding thing any number of times"
- `?` - means "the preceding thing is optional" (match 0 or 1 times)
- `+` - means "match one or more times"

This doesn't have to make a lot of sense to you right now (or ever); it's just a reference, as you think about the examples below.

#### Make the file extensions consistent

Some of the volunteers who made all of these files didn't know CSV was a thing, so they saved their files full of comma-separated values as text files, ending in .txt. It's cool, we can fix that right up. 

What we want to do is to find every file that ends in ".txt" and change it so it ends in ".csv" instead. __Don't type it in yet__, but the command for that is

`rename 's/\.txt$/.csv/' *.txt`

You have to look at it out of order, to understand what it's doing:

`rename [some regex] *.txt` tells `rename` to operate only on files that end in .txt. This is important and possibly confusing: the `*.txt` at the end of the command is __not__ a regular expression. This is the usage of `*` that you're more used to from library databases: it's a wildcard. We're telling `rename` to match on every filename that ends in .txt, no matter what characters come before it.

As you can no doubt imagine, wildcards are really useful on the command line.

We could still put qualifiers into the regular expression (the middle part of the command that we're ignoring right now) that would make the `rename` command skip certain filenames, and we will; but it's important to understand what that third argument in the command is doing.

Now let's look at the middle argument: `'s/\.txt$/.csv/'` - the single-quotes around the regular expression tell the command line interpreter that it's all one statement. 

The `s/x/y/` pattern is a switch statement, meaning that we want to swap one thing for another (take out x, put in y). 

`.txt` is what we're looking for, and we specify that it needs to be at the end of the string (filename) with `$`. But `.` has a specific meaning ("any character") if it's not escaped, so we have to add the `\` in front of it. 

`.csv` is refreshingly straightforward, right? It puts a literal ".csv" in where the .txt was removed from.

Look at what the command would do if you executed it by typing

`rename -n 's/\.txt$/.csv/' *.txt`

The `-n` flag prevented it from actually running; it just showed you what it _would_ do. So, now you should type the same command without the flag (-n) to execute it.

Look at your list of files (`ls`), and you should see that they all end in ".csv"

Other places this might come in handy: 
- JPEGs mixed in with your JPGS (`rename 's/\.jpeg$/.jpg/' *.jpeg` -- though keep in mind that this will only match on lowercase ".jpeg", just as `rename 's/\.JPEG$/.jpg/' *.JPEG` will only match on uppercase)
- HTM files mixed in with your HTML files (`rename 's/\.htm$/.html/' *.htm`)

#### Change the various delimiters to underscores

Our volunteers' delimiters (the things that split "code4lib," the year, and what kind of thing is in the file) are all over the place. There are plus signs, dashes, spaces, and underscores.

I like underscores, so let's standardize on that.

This can be done with three commands:

`rename 's/-/_/g' *`

`rename 's/\+/_/g' *`

`rename 's/\ /_/g' *`

Let's break these down. This pattern will start to become very familiar. 😃 First off, notice we're matching on every file, this time (the last argument in each command is a wildcard, `*`). 

The first command is a super straightforward switch statement (say that five times fast!): take out `-` and replace with `_`. The `g` on the end of the switch statement says to do it "globally," which means if we have the file "code4lib-2001-thing.csv", it will replace both dashes. If you leave off the `g`, it will only replace the first dash. (Try it! Remember to use the `-n` flag to see what the output would be, without actually running the command.)

The second command is very similar, but because `+` is a special character for regular expressions, we have to escape it. Again, we want to do the swap more than once if we have a filename with multiple plusses, so we include the `g` flag.

A slight digression: __spaces in filenames are problematic__. To explain why, let's say you have a file named "that file.txt", and you want to view what's in it. If you type `more that file.txt`, your interpreter will think `that` is one argument and `file.txt` is another. That's not what you want.

We can work around it, but we always have to use quotes around it (single or double quotes, doesn't matter), or else escape every space. So, to view the contents of `that file.txt`, any of these commands  would do:
`more that\ file.txt`
`more 'that file.txt'`
`more "that file.txt"`

Spaces have to be escaped both in normal command line usage _and_ in regular expressions (_usually_, more on that below).

So, the third command, above: it makes sense, now, right? That's an escaped space in the first half of the switch statement, and it's replaced with an underscore, globally. 👍

What's kind of cool, though, is that this whole character swapping deal can also be done with a single command:

`rename 's/[ +-]/_/g' *`

The brackets are a game changer. They make what's inside them into what's known as a "character class," meaning that the regular expression will match one time, on any one thing inside them (_just_ one time, unless you use a modifier like `*`). They also change the rules, because, notice: the space and plus sign aren't escaped. I know, believe me, I _know_. But just roll with it, believe me, try each example for yourself (trust but verify!), and see that it works.

Now, run either the three separate commands or the combined command (using `-n` to see the output before you commit to it).  

#### Make everything lowercase

The volunteers all capitalized Code4Lib differently, just as they likely were split on how it's pronounced. Capitalization can affect how things are alphabetized in some systems, and it just looks messy; so let's make everything lowercase, shall we?

Note: This (apparently) won't work on a Mac, because Macs seem to have case-insensitive file naming. (I'm not bitter. This didn't waste _hours_ of my time. Nope.) It works fine on Nitrous and many other systems with command line interfaces, so it's definitely worth your time to find out about. Just know that, on some systems, it'll fail with a message along the lines of "'Code4Lib_programs_2014.csv' not renamed: 'code4lib_programs_2014.csv' already exists."

Anyway, the command:

`rename 's/([A-Z])/\L$1/g' *`

You see that we're calling `rename` on every file in the directory. You see the switch statement and the "global" flag (`g`).

Now, "A-Z" is maybe the most intuitive statement you'll see in a regex. It means just what you'd think, and when it's put into a character class like that, it means "any single character between A and Z." It won't match on a lowercase character; that would be `[a-z]`. 

Now we end up in a bit of a bind. We can't replace every character we find with the same thing, like we've done above. (Every .txt became a .csv. Every space, plus sign, or dash became an underscore.) If we find a capital "C", we want to replace it with a lowercase "c", but then we don't want a capital "L" to _also_ be replaced with a lowercase "c", right?

Notice that our character class is inside parentheses. That allows us to grab the thing that is matched (a bit like _this_ in some programming languages, if that helps you), in something called a "group" (yes, in this case, it is one character, but it wouldn't have to be; it could be any number of characters). Now look at the second half of the switch statement; that $1 is a variable saying "the first group we grabbed." 

And `\L` says "the lowercase of," so that `\L$1` is "the lowercase of that group we grabbed."

Run the command, and see the beauty of all-lowercase filenames!

#### Make the year appear in the same order in every filename

The volunteers seemed to split halfway on whether they named their files "code4lib-year-type.csv" or "code4lib-type-year.csv", but worry not; we can fix it with a simple(?) `rename` command.

This is the only example that relies on the others all having been run first; the others could have been done in any order. This one assumes everything is lowercase and all of the delimiters are underscores. So make sure you ran all the others first.

`rename 's/([a-z]*)_([a-z]*)_([0-9]*)/$1_$3_$2/' *`

Nothing in this command is new, except for using multiple groups. It's just more complex-_looking_.








