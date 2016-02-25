# Command line tools for archivists

prereqs: cd, pwd, ls, "what is bash", 

## Setup

(Get a tarball with junkfiles.py and anything else I need you to have. Unball(?) it. Get to the right directory.)

## Batch renaming files

You have volunteered to archive all of the data from all the Code4Lib conferences up to now. Thanks! Unfortunately, the data were put together by lots of really enthusiastic volunteers, who were not given a complete file naming convention ahead of time. (Let’s pretend there aren’t a ton of metadata experts in the Code4Lib community who would prevent that from happening.) Everything is in CSV (comma-separated values) format.

Navigate to the folder (SOME FOLDER) Look at what's in the folder (`ls`).

As you can see, there are about 100 files there, all from different years. They're kind of a mess. Renaming all of these files to all use the same naming convention would be tedious and take quite a while to do by hand, but we're going to clean this whole thing up with less than five minutes of work.

Now, there are a number of ways to do bulk edits of filenames on a CLI, including writing a script in Python or bash, or doing clever things with UNIX's find command. These are all totally valid. We’ll be using the `rename` command today.

### Rename

Rename uses something called "regular expressions," or as they are commonly referred to, "regex," to match on and change filenames. We are not going into regex in depth today, but we will use some fairly simple regular expressions, which will be explained along the way, to do the work we need to do. `rename` uses the Perl flavor of regular expressions.

```rename -[flags] [regular expression] files```

There's one super important flag you should know about, `-n`. That allows you to look at what the command will do, without actually running the command, which can save you from a LOT of pain. It is SO GOOD.

### Regex

This is by no means a complete tutorial on regular expressions. Someone please put that together for next year's preconferences, though, OK? 😃

These are all outside of the scope of what we're doing today, but, if you'd like to play with regular expressions on your own, [RegExr](http://regexr.com/) is a really nice interface for doing so. If you're already comfortable with regular expressions, you might enjoy [RegEx Golf](http://regex.alf.nu/) or [Regex Crossword](https://regexcrossword.com/).

Here's a list of the regular expressions we'll use today (and maybe one we won't, but it's good to know), so you can reference them as we're doing examples:
- `s/x/y/` - You may have seen this one around various tech chats, as a shorthand for "I meant y, not x." This takes out x and replaces it with y ("s" is for "substitute")
- `.` - this is a special character in regex and means "any character"
- `\` - this is the escape character, allowing you to use a special character as a literal (if you want to match on a period, use `\.`)
<!---
- `^` - means "not," in any case we'll use it today; it can also mean "beginning of line"
-->
- `$` - means "the end of the string"
- `[]` - means "character class," or "match one thing out of what's in the brackets" 
- `*` - means "match the preceding thing any number of times"
- `?` - means "the preceding thing is optional" (match 0 or 1 times)
- `+` - means "match one or more times"

This doesn't have to make a lot of sense to you right now; we have examples below.

#### Make the file extensions consistent

Our volunteers didn't all know .csv was a thing, so they saved their files full of comma-separated values as text files, ending in .txt. It's cool, we can fix that right up. 

What we want to do is to find every file that ends in ".txt" and change it so it ends in ".csv" instead. Don't type it in yet, but the command for that is

`rename 's/\.txt$/.csv/' *.txt`

You have to look at it out of order, kind of:

`rename [whocares] *.txt` means we're only going to match on files that end in ".txt". This is important and possibly confusing: the `*.txt` at the end of the command is _not_ a regular expression. This is the usage of `*` that you're more used to from library databases: it's a wildcard.

#### Change dashes to underscores

`rename 's/-/_/g' *`

#### Change plus signs to underscores

`rename 's/\+/_/g' *`

#### Change spaces to underscores

`rename 's/\ /_/g' *`

#### Make everything lowercase

This (apparently) won't work on a Mac, because Macs (appear to) have case-insensitive file naming. (I'm not bitter. This didn't waste any of my time. Nope.) It works fine on 

`rename 's/([A-Z])/\L$1/g' *`

#### Put the year second in the filename

`rename -n 's/([a-z]*)_([a-z]*)_([0-9]*)/$1_$3_$2/' *`






