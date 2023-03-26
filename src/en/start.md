
# Start

Before you start working with BondiFuzz, you have to complete authentication. Enter the login and password you received from the admin. You can change the password in the account settings later. Once authentication is complete, you will be redirected to the page with fuzzing test suite.

## Tabs

The web interface of BondiFuzz has the following tabs:

**Projects** — projects created by the user and a *default* project created when a new user was created.

**Fuzzers** — fuzzing test suites created by the user. The user can start and stop a fuzzing test suites, add new versions and delete them.

**FAQ** — frequently asked questions.

**Documentation** — BondiFuzz documentation.

**Trash** — deleted fuzzers go here.

The **Fuzzers** tab has the following tabs:

**Versions** — after applying changes to a fuzzing test suite, the user can create a new version. Thus, you can compare the results of the two versions or roll back to the previous one if the changes are unsatisfactory.

**Crashes** — crashes detected by a fuzzing test suites; they can be sorted by fuzzing test suite's version.

**Statistics** — the stats from the fuzzing results. It shows the metrics that represent the efficiency of fuzzing test suites. You can choose a fuzzing test suite's version and time period to view the stats for it.

You need the following files for fuzzing:

**Binaries** — the fuzzing test suite binary. 

**Seeds** — this is a directory with files whose content has to be valid for the target program or function. Seeds will undergo numerous mutations during fuzzing, which increases code coverage. During fuzzing, seeds are transformed into a corpus. A corpus is a set of test cases that has increased code coverage during the fuzzing of the target program or function. At first, a corpus contains seeds; then -- their mutations, the mutations' mutations, and so on.

**Options and environment** — additional options.

**Image** — agent's docker image. An agent is a program that is run when a container is started and starts the fuzzing test suite itself. An agent collects fuzzing results and stats.
