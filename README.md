Wheelstreet Vega
=================

### Installation

1. Clone the repo via git clone command.
```git clone https://bitbucket.org/wheelstreet/vega.git```
2. Run the following command to install all the third-party libraries.
```pod install```

### Coding standards

Please follow the following guides and code standards:
[Swift Style Guide](https://github.com/linkedin/swift-style-guide)

### Git Branching Model

We use a variant of [nvie's git branching model](http://nvie.com/posts/a-successful-git-branching-model/) for our workflow.

The following main branches exist:

* __``master``__ always points to the latest stable release. Any merge into master must represent a stable release as far as we can tell.
* __``release``__ always points to the latest, stable, development code. This should theoretically always be production-ready, but that is not guaranteed.

There are also some "supporting branch" types. Any supporting branch must be reviewed before being merged.

* __Develop branches__. Naming convention: ``develop/<short_description>``. These branches originate from the release branch and may only receive bugfixes for release blockers (i.e. in the case of a blocker for the release, hotfix branch can be merged into develop branch). Essentially, they represent release candidates. The develop branch should be merged back into the ``release`` branch on a regular basis. When the release candidate is accepted, it will be merged into the release and master branch respectively. The master branch merge commit will be tagged with the new version number.

* __Hotfix branches__. Naming convention: ``hotfix/<short_description>``. These branches represent *severe bugs* in the master branch. They originate from the master branch and fix a specific issue. Once checked and confirmed, they are merged into the master branch as a new point release, as well as being merged into the current develop branch, or the release branch if no release is under way.

* __Feature branches__. Naming convention: ``feature/<short_description>``. These branches represent large new features - for example, a large refactor or major UI change. Feature branches may only originate from the ``develop`` branch and may only be merged into the ``develop`` branch.

* __Ticket branches__. Naming convention: ``ticket/<ticket_number>``. These branches represent tickets from the bug tracker which are not severe bugs in the master branch, and which have non-trivial solutions. Ticket branches may originate from ``release`` (if the ticket is a release blocker), a feature branch (if the ticket is specific to that feature) or a develop branch. They are merged into the branch they originated from.

Trivial fixes to tickets can be made directly to the relevant branch and should include the ticket number prominently in the commit message.

### Contact

For any further details contact [jd@wheelstreet.in](mailto:jd@wheelstreet.in)