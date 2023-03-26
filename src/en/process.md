
# How fuzzing test suites work in the farm

To start working with a fuzzing test suite, you have to upload `tar.gz` archives (fuzzing test suite's binary and seeds) and the config file tp the farm. Only the binary is mandatory.

Once the files are uploaded, file types and the json's validity are verified. At this point, the fuzzing test suite is in `Unverified OK` state. To start the verification process, click `Start`, and the fuzzing test suite will be moved to the queue of unverified fuzzing test suites. This queue has priority over the main one, so if there are fuzzing test suites that require verification, they will be executed first.

When it's time to run the fuzzing test suite, it will be run in the `firstrun` mode with the limit of 10000 executions. This is done to make sure that the uploaded binary file is valid. If the fuzzing test suite finds a crash in this mode, it will be reflected in the output. If there are any errors, you will be notified about them.

Then, the fuzzing test suite is moved to the main queue to be executed in the regular mode.

The fuzzing farm has a system of evaluating a fuzzing test suite's relevance: each fuzzing test suite has its weight. If a fuzzing test suite finds new crashes and/or code coverage grows, its coverage is increased. As the weight increases, the fuzzing test suite is run more frequently. The more often a fuzzing test suite is run, the more crashes it finds and the faster code coverage grows.

If a fuzzing test suite has been working without new crashes or increasing code coverage for a while, its weight is decreased. If a fuzzing test suite's weight continues to drop, it will only find crash duplicates and not the new ones.