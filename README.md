# Workshop – Build A Journaling Package

In this workshop, we'll create a package that makes it easier to keep a journal when using Atom.

We'll store our journal as a directory of simple text files on disk, so it's easy to open in other tools and version control with git. Our top-level journal directory will contain nested directories for each year, which will in turn contain further nested directories for each month. In each month's directory we'll have a markdown file for each day.

```
/my-journal
  /2015
    /04
      13.md
      14.md
      15.md
```

Inside markdown file, each entry from the file's day will begin with its own markdown style h1 heading, containing a timestamp and an optional title.

my-journal/2015/04/13.md:
```markdown
# 10:45 AM – Hanging out in Marlborough, NZ

It's a bit cloudy, but we had some fantastic wine yesterday and are enjoying the
unspoiled serenity of the New Zealand landscape. It's good to be back here...

# 8:00 PM

That was a really great day. Tomorrow I need to make some progress on my talk...
```

By building a handful of simple features around these conventions, we can make Atom a more convenient tool for keeping a journal. In part 1, we'll focus on making it easier to create new journal entries. Then, in part 2, we'll add a feature for browsing existing entries.

## Part 0 – Foundation

The `master` branch of this repository contains all the code we'll be writing. So before we start, let's clone it, install it into Atom, and try it out in its completed form. Then we'll reset back to the beginning and walk through how to build it.

First, let's clone the repository and `apm link` it so that Atom loads it as a package.

```
git clone https://github.com/nathansobo/journal.git
cd journal
apm link
```

Now any new Atom window should have our package installed and active. Existing windows will need to be reloaded by selecting `View > Reload` from the application menu. You can check that it's loaded by opening the command palette with `ctrl-shift-P` and typing `journal`. You should see a `Journal: New Entry` command and a `Journal: List Entries` command.

Now we'll create a branch and reset it to a much earlier state in the project so we can build the journal package out together.

```
git checkout -b workshop
git reset --hard part-0
```

Every part of this workshop is represented as a tagged commit in this git repository, which I'll be referencing throughout this guide. If you ever get off track want to jump to a particular state of the project, you can use `git reset --hard <tag>` on your `workshop` branch to blow away all your current state and jump straight there.

## Part 1 – Creating entries

In part 1, we'll be implementing the `journal:new-entry` command, accessible from the command palette. This will automatically open a markdown file with a path based on the current date and insert a heading based on the current time.

### Part 1.1 – Add a basic test

[View commit on GitHub](https://github.com/nathansobo/journal/commit/c1a8a3a9abc58fa5838b2860a8b86b312d170e00)

In this step, we add an integration test for our command on the main module of our package.

* Before the package activates, we assign a `journal.path` configuration variable to point at our fixtures directory.
* We build a Date object frozen at a particular point in time and mock the `getCurrentDate` method on the main module to return it. This method will be used by the implementation so we can control the time for testing purposes.
* We dispatch the command on the workspace element.
* We wait for the dispatched command to cause an editor to be opened to the expected path. Since the command is asynchronous, we have to wait for this condition rather than asserting it.

If we run package specs with `View > Developer > Run Package Specs`, our spec should wait 5 seconds and then fail.

### Part 1.2 – Add a schema for our configuration variable

[View commit on GitHub](https://github.com/nathansobo/journal/commit/187b2f2da4737ac659d60e4304ba344d771bb12a)

In this step, we add a schema for the configuration variable we assigned in the spec, `journal.path`.

### Part 1.3 – Lay the groundwork for the new-entry command

[View commit on GitHub](https://github.com/nathansobo/journal/commit/011f353b7304df49b762e8e3683e765320c8f8d9)

Now we get part of the way to making the test pass.

* We create a `Journal` class to represent our journal on disk. It has a `createNewEntry` method that we leave unimplemented with some logging, and a `getPath` method that pulls from the configuration variable we just defined.
* We require our new `Journal` class in the main module of the package. When the package is activated, we add a new *command* that calls the `createNewEntry` method on the journal instance.
* We add a `getCurrentDate` method, which just constructs and returns a date object. It is used by our command implementation so we can easily control the date in our tests.

Once we complete this step, we should be able to try out our `journal:new-entry` command after reloading the current Atom window. If we open the developer tools with `View > Developer > Toggle Developer Tools`, we should see our log statements when we run the command from the command palette.

### Part 1.4 – Implement the new-entry command

[View commit on GitHub](https://github.com/nathansobo/journal/commit/23ce7435f18ad2a45334bfaa12d7e8f52111995b)

Now we replace the logging with some real code.

* We call `atom.workspace.open` with a path that we construct based on the date in the `entryPathForDate` method.
* In `entryPathForDate`, we pad single-digit months and days with leading zeroes, then combine them with the journal path from the configuration to construct a path to the today's entry.

If we run package specs with `View > Developer > Run Package Specs` they will now pass.

### Part 1.5 – Extend the test to expect a heading

[View commit on GitHub](https://github.com/nathansobo/journal/commit/85b7f42c6e758da0f206cdb243a4dc4cfbfa8893)

Now we extend our test to expect an entry heading based on the time to be inserted.

* We add a `runs` block, which won't run until our `waitsFor` condition is satisfied.
* Inside the block, we assert that the first line of the opened editor has a heading and that the cursor is two lines below the heading at the beginning of the line, ready to type an entry.

If you run this test, it should fail.

### Part 1.6 – Make the test pass again by inserting a heading

[View commit on GitHub](https://github.com/nathansobo/journal/commit/13b58e5be14a128bc050793cfa367d3ef5615fdd)

Now we update our implementation to insert a heading.

* The `workspace.open()` call returns a `Promise` object. We add a resolution callback to this promise with `then` that inserts a heading followed by two newlines into the opened editor.
* We add a new `formattedTimeForDate` method that switches our time to a 12 hour clock and zero-pads the minutes.

The test should now pass.

### Part 1.7 – Handle multiple entries on the same day

[View commit on GitHub](https://github.com/nathansobo/journal/commit/265b22da670c0d6cf28782fed4ac198ef89afb9d)

Our current code works well for the first entry of the day, but falls down when we want to start adding multiple entries. Here we add some tests and make them pass in the same commit.

Starting at the bottom, in the test:

* We add an `editor` variable to the top of the test so we can share it across `waitsFor` and `runs` blocks.
* We insert some text in the first entry, then move the cursor to the middle of the inserted text to simulate something that could occur in real life: The cursor doesn't always get left at the end of the last entry.
* Then we advance our fake clock and dispatch the command again.
* We expect our new heading to be inserted on row 4.

If you run this test now, it should time out because we don't insert the heading cleanly.

### Part 1.8 – Insert snippets for entry headings

[View commit on GitHub](https://github.com/nathansobo/journal/commit/cf90d1039be0cefd19bacdbfbafbc44c88e358e7)

The current implementation inserts times correctly, but it doesn't give us a chance to type an entry title. We can use the snippets package to create a slick workflow around inserting an optional title. Let's start with the tests:

* In the `beforeEach`, we also wait to activate the `snippets` package.
* We change the expectations to expect a ` – ` separator to be inserted after the time.
* We dispatch `snippets:next-tab-stop` commands on the editor to test our tab stop locations.

Now the implementation.

* Whenever we use one package from another, we do so via a semantically versioned *service*. We declare our use of the `snippets` service in the `consumedServices` section of the `package.json`.
* When we consume a service, we specify a method on our main module that will be called with the service when it becomes available. Here we wire the `snippets` service to be passed to the `consumeSnippetsService` method.
* In `consumeSnippetService`, we assign the service on the journal object. Then we construct and return a `Disposable` instance with a function to be called when the service is deactivated. We just clear the service on the journal object so we don't attempt to use it after its gone.
* In our command implementation, we now use the `@snippetsService` instance variable if it's available, calling `insertSnippet` with a specially formatted snippet string that includes our desired tab stops.

### Part 1 Complete

This concludes part 1. If you want to test it out, configure a journal directory (the default is `~/journal`) and run the command. An editor should open with the correct path and a heading at the top.

## Part 2 – Listing existing journal entries

Part 1 allowed us to easily create new entries. This section will focus on making it easy to browse and open existing entries.

### Part 2.1 – Adding a unit test for Journal::listEntries

[View commit on GitHub](https://github.com/nathansobo/journal/commit/d1ae21360e991c1e9454a5816d64f9bb90464229)

Again, we start with a test. But this time its a unit test on our `Journal` class for a new method, `Journal::listEntries`. This method will return a promise that resolves with information about all current journal entries.

* We create a `fixtures` directory with some sample journal entries.
* In our test, we set the journal path configuration variable to point at our `fixtures` directory, then call our method.
* We make an assertion about the result of our method based on the data on disk. Note that each entry includes the `displayText` property, which is what we want to show in our listing. It also includes the `filePath` and `row` for the entry.

If you run this test, it will fail.

### Part 2.2 – Implementing Journal::listEntries

[View commit on GitHub](https://github.com/nathansobo/journal/commit/58b622dd664bbd31425254b84fd4cd264f8b4962)

Now we make our test pass. This feature requires us to pull in a library called `scandal` as a dependency to help us scan our journal directory for every entry. To add `scandal` to your `package.json` and install it at the same time, run the following in your package directory on the command line:

```
npm install --save scandal
```

Now in the `listEntries` method, we'll use objects from `scandal` to build up a search:

* First, we build `PathScanner` and `PathSearcher` instances that will be used in a call to `search` at the end of the method.
* We start with a `PathScanner` instance rooted at the journal's directory and configured with a glob pattern to only include paths matching our expected format: four digits for the year, a `/`, two digits for the month, another `/`, and two digits for the day followed by the `.md` extension.
* We don't build our `PathSearcher` with any special parameters, but do subscribe to any results it finds. We'll return to this results handler in a second.
* At the bottom of the method, we return a `Promise` that only resolves once our search is completed. Inside the promise, we run a search for lines matching the format of our journal entry headings, then resolve the promise with the `entries` array once the search is complete.
* We build up the `entries` array as each result is found. We extract the date from the `filePath`, the time and title from the `lineText` of each match. Each match from `scandal` also includes the `range` of the match, which we can use to determine the `row`. Since `scandal` searches in chronological order and we want our entries in reverse chronological order, we `unshift` each result onty the array.

Now if you run the test from the previous step, it should pass.

### Part 2.3 – Listing entries in a modal panel

[View commit on GitHub](https://github.com/nathansobo/journal/commit/4ff281e354f48983459449167513893d976bcfa2)

This step adds a second dependency, `atom-space-pen-views`, which contains a fuzzy-filtering select list we will use use to list the entries. Again, you can install it as follows:

```
npm install --save atom-space-pen-views
```

First, we add a simple test for the `journal:list-entries` command. This doesn't test everything about our entry list, but covers that it basically works. Since most of the behavior is provided by a library, it should be enough coverage.

* We attach the workspace to the DOM so we can test how focus is handled.
* We dispatch the command.
* We wait for the `entryListPanel`, which we expect to save as a property on the main module, to be visible.
* Then we wait for its items to be populated and assert that it is focused once this occurs.

Now, we implement the entry list:

* We start by adding an `EntryList` view class as a subclass of `SelectListView`, which we require from the `atom-space-pen-views` library we just installed. The `SelectListView` implements most of the behavior we want already, but we customize it in a few ways.
* We override `initialize` to call `cancel` when the view loses focus.
* We implement `viewForItem` to translate objects from our `::listEntries` method to HTML elements.
* We implement `getFilterKey` to tell the select list which property to use to filter results.
* We add an empty implementation of the `confirmed` method, which handles one of the entries being selected. We'll add an implementation in the next step.

Then we add the command:

* When `journal:list-entries` is invoked, we call `showEntryList`.
* This calls `createEntryList`, which builds the list if it hasn't already been constructed. We'll display the list in a *modal panel*, hiding the panel and refocusing the currently active pane whenever the list is cancelled.
* Then, in `showEntryList`, we show the panel, invoke `Journal::listEntries` to scan all the current entries, and assign items on the list when the scan operation completes.

This should be enough to pass the test. If you populate your journal directory with some entries, you should be able to try this out after reloading your Atom window.

### Part 2.4 – Opening listed entries

[View commit on GitHub](https://github.com/nathansobo/journal/commit/d311c77dbf95640d1c0a3725a911e83b84a46fa3)

The final step is to allow entries to be opened when they are selected.

* Again, we'll start with the tests. We extend the last test to select the second entry and confirm our selection. We then add another `waitsFor` block to wait for the entry to be opened. We then assert we're on the expected row.
* The implementation is actually pretty easy. In the previously-empty `confirmed` method on our `EntryList`, we simply call `atom.workspace.open` with the selected path, passing the `initialLine` option with the row number of our entry so we jump straight to it upon opening.

## Complete!

Congratulations. There are lots of ways this package could be enhanced, but what you've built here is useful enough to make keeping a daily journal in Atom a lot more convenient. Even better, we've explored many different techniques that will be useful in building other kinds of packages. Good luck!
