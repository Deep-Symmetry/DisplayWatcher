# Change Log

All notable changes to this project will be documented in this file.
This change log follows the conventions of
[keepachangelog.com](http://keepachangelog.com/).

## [Unreleased][unreleased]

Nothing so far.

## 2.0.1 - 2019-09-07

### Changed

- Updated project files so they can be opened with a current version
  of Xcode with the help of my colleague Marc, who had an old enough
  computer and Xcode version that he could read them. (My Xcode
  thought they were from a future version!)
- Fixed build process and project configuration warnings enough that
  the code would build properly as a 64 bit executable. There are
  still many deprecation warnings, the goal was just to get it working
  again for people who wanted to be able to use it in Catalina.
- Imported old project into Git. So far no historical commits have
  been copied, because the CVS server that hosted the old project is
  offline. If anyone really wants those it might be possible to bring
  it back up and migrate them, but it seems like a lot of effort for
  files that aren't compatible with current build tools.

## 1.1 - 2006-02-12

### Changed

- Recompiled as a Universal Binary using Apple’s new Xcode tools, so
  that it can operate properly and at native speeds on Intel-based
  Macs. Yes, it really was as easy as Apple promised it would be. It
  continues to work fine on Leopard as well.

## 1.0.2 - 2004-07-13

### Changed

- Recompiled in non-debug mode so the code would work properly on
  other machines.

> I hope the third time is the charm. Apparently the builds that I had
> posted previously were compiled for debugging in such a way that
> they would run properly only on my own machine. That’s what happens
> when you’re just learning how to use a development environment...
> I’ve heard that the 1.0.2 builds do run, so please give them a try
> if you’ve had trouble with the others.

## 1.0.1 - 2004-07-12

### Fixed

- On-wake script execution was not working in the initial release.

> Oops. I couldn’t resist making some very nice improvements to the
> code right before posting it this weekend. My friend Mike Trent (as
> seen on CocoaDev.com) pointed out that there are now high-level
> AppKit events to replace some nasty low-level hackery I was using,
> which made the source a lot simpler, and enabled me to fix an
> irritating if minor limitation of the preference pane. But, that
> means the version I posted wasn’t the version I’d tested for so
> long, and it turned out I had broken the “on wake” detection. Dohh!
>
> If you downloaded version 1.0.0 on Sunday, July 11, please replace
> it with version 1.0.1, and accept my humble apologies (and stunned
> congratulations for having found this app so quickly)!

## 1.0 - 2004-07-11

Initial relase.

[unreleased]: https://github.com/brunchboy/wayang/compare/v2.0.1...HEAD
