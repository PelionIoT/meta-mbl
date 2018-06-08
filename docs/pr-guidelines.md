# Pull Request Guidelines

Before you create a pull request from a branch, each commit on the branch
should be a logically self contained change and each commit message should
have:
* a subject and body conforming to [these guidelines][commit-message-guidelines];
* references for any relevant bugs, issues or tickets.

Once a pull request has been made, it must be reviewed before being accepted.
If further changes are required once the pull request has been made, these
changes must be related to the original subject of the pull request. Even small
changes in the same files that do not relate to the subject of the pull request
must be made in a different pull request. There are two allowed processes for
making changes to a pull request:

### 1. Squash Flow: When the pull request initially contains a single commit

If there is only one commit in a pull request:
* For each subsequent change to a pull request (e.g. arising from a reviewer's
  request for changes) a new commit is uploaded to the pull request.
  * I.e.: modify, `git add` and then `git commit`.
  * This allows the GitHub review tool to offer things like _“show me diffs since my last review”_.
  * Commit messages made at this point don't always have to conform the
    guidelines stated above because they will be squashed into the first commit
    on the PR later. The purpose of the change should still be obvious from the
    pull request comments and the commit message.
  * When you intend for a new commit on a pull request to be squashed into the
    previous commit, prefix the subject line of the commit message with "TO BE
    SQUASHED:".
* Once we are happy with the set of commits in a pull request we use the
  `squash and merge` feature of GitHub to merge the changes. At this point the
  message for the final squash commit is created, based on the messages for
  each commit in the (pre-squash) pull request with any necessary amendments.
* The reviewer is responsible for doing the final squash and merge into the
  target branch, including forming the final commit message.
* The reviewer may ask for an updated commit message. To avoid changing the
  commits on the pull request branch, this new commit message should be posted
  as a comment which the reviewer will use when forming the message for the
  final squash commit.

### 2. Force Push Flow: When the pull request initially contains multiple commits
If there are multiple commits in a pull request (and if it makes more sense to
have one pull request than multiple):
* We fall back to the force push methodology where the author amends their
  commits (using e.g. `git commit --amend` or an interactive rebase) then uses
  `git push --force` to update their remote branch.
* The reviewer should be informed before the force push so that they can
  download the original changes in order to easily see what is different after
  the force push.
* The reviewer is responsible for doing the final rebase and merge into the
  target branch.
* If a change to a commit message is requested by a reviewer, it should be
  changed by using an interactive rebase or `git commit --amend` followed by a
  force push.

## Reviewing pull requests with forced pushes

When a force push is made to a pull request branch, GitHub usually garbage
collects the commits that were on the branch before the force push. This makes
viewing the diff between the branch before the force push and after the force
push impossible without extra steps being taken by the reviewers before the
force push. A possible workflow for such reviews is as follows.
1. Before the force push, in a local repository, save the current state of the
   PR branch (`pr_branch`) in a local branch (`prxxx_head0`):
   ```
   git checkout pr_branch
   git pull
   git checkout -b prxxx_head0
   ```
2. After the force push, in the same local repository, save the new state of
   the PR branch in a local branch (`prxxx_head1`), rebase both `prxxx_head0`
   and `prxxx_head1` on `target_branch` (the target of the PR), and then
   compare them:
   ```
   git checkout target_branch
   git pull
   git checkout prxxx_head0
   git rebase target_branch
   git checkout pr_branch
   git pull
   git checkout -b prxxx_head1
   git rebase target_branch
   git diff prxxx_head0
   ```
The `git rebase target_branch` on the `prxxx_headN` branches is to account for
the possibility that `pr_branch` may be based on different commits of
`target_branch` before and after the force push - it stops unrelated commits to
`target_branch` being part of the diff.

[commit-message-guidelines]: https://gist.github.com/robertpainsi/b632364184e70900af4ab688decf6f53#file-commit-message-guidelines-md
