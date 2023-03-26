
# Working with BondiFuzz CLI

## Installation

Python 3.7 or higher is required.

Clone the project:

`git clone https://github.com/bondifuzz/bondi-python.git`

Install it using `pip`:

`pip install bondi-python`

Once installed, run it using `--help`:

`bondi --help`

You can enable autocompletion of commands using an additional framework:

`bondi --install-completion`

## Configuration

Initialize server connection:

`bondi config init`

Enter the server URL, username, and password.

```
Server url: https://demo.bondifuzz.com
Username: username
Password: ***
OK - Initialization successful
```
You can refresh the connection with a command like this one:

`bondi config set username user_1`

```
OK - Config updated successfully
```

Get info about an established connection:

`bondi config show`

```
--------  ------------------
url       demo.bondifuzz.com
username  **************name
password  **************4321
--------  ------------------
```
Get the URL of the connected server:

`bondi config get url`  

`https://demo.bondifuzz.com`

Get the username of the account connected to the server:

`bondi config get username`  

`username`

## Managing projects

Create a new project:

`bondi projects create`

You need to give it a unique name and provide CPU and RAM values. A unique `id` will be assigned to the project automatically.

```
Name: project_1
Node cpu: 40
Node ram: 360
----  ---------
id    10550740
name  project_1
----  ---------
```

The CPU value is measured as the number of cores and can be: 2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96. You can `Tab` to choose a value.

The RAM value is measured in GiB and is equal to the CPU value times a coefficient of 1 to 16 but cannot be more than 640 GiB. You can `Tab` to choose a value.

Get project information:

`bondi projects get 10550740`

Provide the project's `id` or name.

```
-----  ---------
Project name    project_1
Description     Default project
Pool status     Ready
Node group      CPU per node: 4 cores, RAM per node: 8GB, Node count: 1
Pool resources  CPU in total: 3720 mcpu, RAM in total: 5714MB, Nodes ready: 1

-----  ---------
```

Get the list of projects with `id`'s and descriptions:

`bondi projects list`

```
+----------+--------------+------------------+
|       id | name         | brief            |
|----------+--------------+------------------|
| 10550740 | project_1    | My first project |
|  9845728 | project_2    | No description   |
|  8953832 | project_3    | No description   |
|  2755294 | default      | Default project  |
+----------+--------------+------------------+
```

Change project name:

`bondi projects update --id 10550740 --new-name project_2`

The table shows the new and old project names.

```
+------------+-----------+-----------+
| property   | old       | new       |
|------------+-----------+-----------|
| name       | project_1 | project_2 |
+------------+-----------+-----------+
```

Change project description:

`bondi projects update --id 10550740 --new-description no description`

The table shows the new and old project descriptions.

```
+-------------+-------+----------------+
| property    | old   | new            |
|-------------+-------+----------------|
| description | none  | no description |
+-------------+-------+----------------+
```

For convenience, you can set a current project as the default one, so you won't have to enter its name and it will be entered automatically.

`bondi projects set-default project_1`

View the default project:

`bondi projects get-default`

Cancel setting a project as default:

`bondi projects unset-default`

Delete project:

`bondi projects delete project_1`

Recover project from trash:

`bondi projects restore project_1`

Delete project completely:

`bondi projects erase project_1`

## Working with fuzzers

Create a fuzzer:

`bondi fuzzers create`

When creating a fuzzer, you must specify its type, programming language, and the project it's related to. A fuzzer's name has to be unique in the context of a project. Fuzzers related to different projects can be named the same. A fuzzer will be automatically assigned a unique `id`.

```
Name: fuzzer_1
Description: none
Fuzzer type: AFL
Fuzzer lang: Cpp
Project: project_2
----  --------
id    10591666
name  fuzzer_1
----  --------
```

Get fuzzer information:

`bondi fuzzers get fuzzer_1`

You will see all information about the fuzzer.

```
Fuzzer: fuzzer_1
--------------  --------
id              10591666
name            fuzzer_1
type            AFL
lang            Cpp
ci_integration  False
description     none
--------------  --------
```

Get the list of fuzzers (you have to provide the project name):

`bondi fuzzers list`

Get a list of possible configurations *programming language — fuzzer engine*:

`bondi fuzzers show-configurations`

```
------  --------------
C++     AFL, LibFuzzer
Go      LibFuzzer
Rust    LibFuzzer
Python  LibFuzzer
------  --------------
```

Change fuzzer name providing the project name:

`bondi fuzzers update fuzzer_1 -n fuzzer_2`

```
Project: project_2
+-----------------+-------------+-------------+
| Property name   | Old value   | New value   |
|-----------------+-------------+-------------|
| Project name    | fuzzer_1    | fuzzer_2    |
+-----------------+-------------+-------------+
```

Change fuzzer description providing the project name:

`bondi fuzzers update fuzzer_1 -d description`

```
Project: project_2
+-----------------+----------------+-------------+
| Property name   | Old value      | New value   |
|-----------------+----------------+-------------|
| Description     | No description | description |
+-----------------+----------------+-------------+
```

For convenience, you can set a current fuzzer as the default one, so you won't have to enter its name and it will be entered automatically.

`bondi fuzzers set-default fuzzer_1`

View the default fuzzer:

`bondi fuzzers get-default`

Cancel setting a fuzzer as default:

`bondi fuzzers unset-default `

Delete fuzzer:

`bondi fuzzers delete fuzzer_1`

Recover fuzzer from trash:

`bondi fuzzers restore fuzzer_1`

Delete fuzzer completely:

`bondi fuzzers erase fuzzer_1`

Download fuzzer corpus:

`bondi fuzzers download-corpus fuzzer_1`

## Creating fuzzer versions

Once a fuzzer is created, you have to create its first version and the next versions after that. This would allow to keep the original fuzzer while making changes to it and the tested code.

The CPU value is measured in mcpu and ranges from 500 to 2000.

The RAM value is measured in MiB and ranges from 500 to 5000.

The tmpfs value is measured in MiB and ranges from 100 to 2000.

Create a fuzzer version:

`bondi revisions create -n revision_1 -i 53823967 -f fuzzer_1 -p project_1 --cpu 600 --ram 1000 --tmpfs 300`

```
-------------  ----------
ID             64321403
Revision name  revision_1
-------------  ----------
```

If you do not provide a version name in the command, it will be generated automatically. A unique ID is assigned to a version as well.

View the list of all fuzzer versions:

`bondi revisions list`

Get information about a specific version:

`bondi revisions get revision_1 -f fuzzer_1`

For convenience, you can set the current fuzzer as the default one, so you won't have to enter its name and it will be entered automatically.

`bondi revisions set-default revision_1`

View the default version:

`bondi revisions get-default`

Cancel setting a version as default:

`bondi revisions unset-default`

Delete a version:

`bondi revisions delete revision_1`

Recover a version from trash:

`bondi revisions restore revision_1`

Delete a version completely:

`bondi revisions erase revision_1`

Fuzzer corpora can be copied and pasted between versions of the same fuzzer:

`bondi revisions copy-corpus revision_1 revision_2`

You can only paste to a version that hasn't been run yet.

## Images

You have to choose an image for every fuzzer. Here's how to view all available images:

`bondi images list-available -l Cpp -e LibFuzzer -p project_1`

Each image has a unique ID.

Currently, only farm admins can upload images. User can send requests for images through support.

## Uploading fuzzing test suite files

Create and tested files are uploaded to the farm with a command like this:

`bondi revisions upload-files -p project_1 -f fuzzer_1 revision_1 --binaries-path path_to_fuzzer/binaries.tar.gz --config-path path_to_fuzzer/config.json --seeds-path path_to_fuzzer/seeds.tar.gz`

`binaries  [####################################]  100%`  
`seeds  [####################################]  100%`  
`config  [####################################]  100%`  
`OK - Files uploaded successfully`  

You can go to the directory with fuzzing test suite files and user a simpler command:

`bondi revisions upload-files -p project_1 -f fuzzer_1 revision_1 --binaries binaries.tar.gz --config config.json --seeds seeds.tar.gz`

Download fuzzing test suite files:

`bondi revisions download-files revision_1 -f fuzzer_1 -p default`

## Working with fuzzers

Run the fuzzer:

`bondi revisions start revision_1`

If everything's okay, you will see this message: `OK - Revision started`

Note: the farm's architecture implies that a fuzzer versions is executed. You cannot run several versions of the same simultaneously, but you can run versions of different fuzzers.

Stop the fuzzed:

`bondi revisions stop revision_1`

Restart the fuzzer:

`bondi revisions restart revision_1`

Upon a restart all fuzzer data are cleared, only the corpus remains.

Corpora can be copied between fuzzer versions:

`bondi revisions copy-corpus revision_1 revision_2`

## Fuzzer results

To get a list of crashes for all fuzzer versions, provide the project name:

`bondi crashes list -f my_fuzzer -p project_1`

or use

`bondi crashes list`

You can also get list of crashes for a version:

`bondi crashes list -r revision_1`

To get crash data, enter the crash ID, fuzzer name and the related project name:

`bondi crashes get 10327133 -f my_fuzzer -p project_1`

To get detailed crash data, enter the crash ID, fuzzer name and the related project name:

`bondi crashes get-details 10327133 -f my_fuzzer -p project_1`

Here's the output:

```
INFO: Seed: 3128728610
INFO: Loaded 1 modules   (35943 inline 8-bit counters): 35943 [0xad8690, 0xae12f7), 
INFO: Loaded 1 PC tables (35943 PCs): 35943 [0x94f0e8,0x9db758), 
/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer: Running 1 inputs 2000000 time(s) each.
Running: /mnt/tempfs/binaries/leak-56aa9f9652536ca63aa8251540ae7007a017c735
==16==WARNING: invalid path to external symbolizer!
==16==WARNING: Failed to use and restart external symbolizer!

=================================================================
==16==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 32 byte(s) in 1 object(s) allocated from:
    #0 0x52447d  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x52447d)
    #1 0x6013fb  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6013fb)
    #2 0x6588c1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6588c1)
    #3 0x56afb8  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x56afb8)
    #4 0x55c810  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x55c810)
    #5 0x59f242  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59f242)
    #6 0x59a1d1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59a1d1)
    #7 0x556bcd  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x556bcd)
    #8 0x45d7c1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x45d7c1)
    #9 0x448ed2  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x448ed2)
    #10 0x44ef3e  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x44ef3e)
    #11 0x476a02  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x476a02)
    #12 0x7f38ee67ed09  (/lib/x86_64-linux-gnu/libc.so.6+0x26d09)

Indirect leak of 32 byte(s) in 1 object(s) allocated from:
    #0 0x52447d  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x52447d)
    #1 0x6013fb  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6013fb)
    #2 0x6588e1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6588e1)
    #3 0x56afb8  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x56afb8)
    #4 0x55c810  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x55c810)
    #5 0x59f242  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59f242)
    #6 0x59a1d1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59a1d1)
    #7 0x556bcd  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x556bcd)
    #8 0x45d7c1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x45d7c1)
    #9 0x448ed2  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x448ed2)
    #10 0x44ef3e  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x44ef3e)
    #11 0x476a02  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x476a02)
    #12 0x7f38ee67ed09  (/lib/x86_64-linux-gnu/libc.so.6+0x26d09)

SUMMARY: AddressSanitizer: 64 byte(s) leaked in 2 allocation(s).

INFO: a leak has been found in the initial corpus.

INFO: to ignore leaks on libFuzzer side use -detect_leaks=0.
```

To download crash data, enter the crash ID, fuzzer name and the related project name:

`bondi crashes download -c 10327133 -f my_fuzzer -p project_1`

All data will be saved to a .crash file.

```
crash  [####################################]  100%
OK - Saved to 10327133.crash

```

## Viewing stats

The fuzzing farm keeps the stats on fuzzers. 

You can view the stats for a fuzzer version:

`bondi statistics show -r revision_1 -f fuzzer_1 -p project_1`

For detailed stats you can view graphs for each of the following parameters:

- corpus_entries
- edge_cov
- execs_per_sec
- known_crashes
- unique_crashes
- corpus_size
- execs_done
- feature_cov
- peak_rss

`bondi statistics show-chart -c unique_crashes -r revision_1 -f fuzzer_1 -p project_1`

## Task tracker integration

The BondiFuzz CLI utility allows you to integrate task trackers.

To create a Jira integration, you have to provide a URL, the user's login/email and password/token, Jira project name, issue type, priority, integration name (it must be unique), integration type, and BondiFuzz project name.

`bondi integrations create --jira-url https://demo.jira.com --jira-username User@user.com --jira-password passw123 --jira-project MP --jira-issue-type Task --jira-priority Medium -n integration_1 -t Jira -p project_1`

The integration will get a unique ID.

Delete an integration:

`bondi integrations delete -p project_1 integration_1`

Disable an integration by providing the project name in the farm and the integration's ID/name:

`bondi integrations disable -p project_1 integration_1`

You can enable a previously disabled integration by providing the project name and integration ID/name:

`bondi integrations enable -p project_1 integration_1`

Для получения детальной информации об интеграции нужно указать ID/название интеграции и соответствующий проект:

`bondi integrations get -p project_1 17924052`

To get detailed information about an integration, provide its ID/name and project name:

`bondi integrations get-config -p project_1 17924052`

Get a list of integrations by project name:

`bondi integrations list -p project_1`

Change integration name:

`bondi integrations update -p project_1 17924052 -n integration_2`