# Pull Request Guidelines

Before you create a pull request from a branch, each commit on the branch
should be a logically self contained change and each commit message should
have:
* a subject and body conforming to [these guidelines][commit-message-guidelines];
* references for any relevant bugs, issues or tickets.

When you create a pull request, please provide the following additional
information in the PR description or in a comment:
* A description of any testing that you have done.

Once a pull request has been made, it must be reviewed before being accepted.
If further changes are required once the pull request has been made, these
changes must be related to the original subject of the pull request. Even small
changes in the same files that do not relate to the subject of the pull request
must be made in a different pull request. There are two allowed processes for
making changes to a pull request:

### 1. Squash Flow: When the pull request initially contains a single commit

This should be the most common case (we prefer small pull requests) and is
strongly preferred.

When there is initially only one commit in a pull request:
* For each subsequent change to a pull request (e.g. arising from a reviewer's
  request for changes) a new commit is uploaded to the pull request.
  * I.e.: modify, `git add` and then `git commit`.
  * Commit messages made at this point don't always have to conform the
    guidelines stated above because they will be squashed into the first commit
    on the PR later. The purpose of the change should still be obvious from the
    pull request comments and the commit message.
  * When you intend for a new commit on a pull request to be squashed into the
    previous commit, prefix the subject line of the commit message with "TO BE
    SQUASHED:".
* There is an exception to the previous guideline when a pull request branch
  contains merge conflicts. In this case, you can fix merge conflicts
  by doing a rebase locally followed by a force-push. The force-push should
  only be used to fix merge conflicts and subsequent changes to the pull
  request branch should follow the previous guideline. You may also use
  GitHub's online merge conflict resolution process.
* Once we are happy with the set of commits in a pull request we use the
  `squash and merge` feature of GitHub to merge the changes. At this point the
  message for the final squash commit is created, based on the messages for
  each commit in the (pre-squash) pull request with any necessary amendments.
* The reviewer may ask for an updated commit message. To avoid changing the
  commits on the pull request branch, this new commit message should be posted
  as a comment which the reviewer will use when forming the message for the
  final squash commit.

### 2. Force Push Flow: When the pull request initially contains multiple commits

This should be the less common case (we prefer small pull requests) and is
strongly discouraged.

If there are initially multiple commits in a pull request that shouldn't be
squashed, and it makes more sense to have one pull request rather than
multiple:
* We fall back to the force push methodology where the author amends their
  commits (using e.g. `git commit --amend` or an interactive rebase) then uses
  `git push --force` to update their remote branch.
* If a change to a commit message is requested by a reviewer, it should be
  changed by using an interactive rebase or `git commit --amend` followed by a
  force push.

[commit-message-guidelines]: https://gist.github.com/robertpainsi/b632364184e70900af4ab688decf6f53#file-commit-message-guidelines-md
