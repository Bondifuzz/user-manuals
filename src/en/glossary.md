
# Terms

**Fuzzing** is a technique of automated testing where a program is fed specially crafted input that would trigger an error state or undefined behavior.



**Input** is data specifically prepared and fed to a tested function during fuzzing. 

**Seeds** are sets of input data used to initiate fuzzing. In a nutshell, seeds are samples of valid input for the tested function. Seeds transform into a corpus during fuzzing.

**Corpus** is a set of test cases that have increased code coverage during fuzzing, which potentially can result in a program crash.

**Crash** refers to input that caused the fuzzing test suite to crash or freeze.

**Duplicate** is a crash that looks like an already detected one.

**Coverage** describes how much of the code is covered by fuzzing test suite(s) (i.e., tests).

**Corpus merging/minimization** refers to choosing a minimum amount of files and sizes of corpora granting maximum coverage.

**Mutator** is responsible for processing input. If mutated data increase the coverage, they are added to the corpus.

**Weight** is a value that increases with each successful execution of a fuzzing test suite. The more the weight, the more often the fuzzing test suite will be started.

**Crash reproduction** is a process that is initiated after a crash to check for false-positives.