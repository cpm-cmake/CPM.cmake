<!-- omit in toc -->
# Contributing to CPM.cmake

First off, thanks for taking the time to contribute! ❤️

All types of contributions are encouraged and valued. See the [Table of Contents](#table-of-contents) for different ways to help and details about how this project handles them. Please make sure to read the relevant section before making your contribution. It will make it a lot easier for us maintainers and smooth out the experience for all involved. The community looks forward to your contributions. 🎉

> And if you like the project, but just don't have time to contribute, that's fine. There are other easy ways to support the project and show your appreciation, which we would also be very happy about:
> - Star the project
> - Tweet about it
> - Refer this project in your project's readme
> - Mention the project at local meetups and tell your friends/colleagues

<!-- omit in toc -->
## Table of Contents

- [I Have a Question](#i-have-a-question)
- [I Want To Contribute](#i-want-to-contribute)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Your First Code Contribution](#your-first-code-contribution)
- [Styleguides](#styleguides)



## I Have a Question

> If you want to ask a question, we assume that you have read the available [Documentation](https://github.com/cpm-cmake/CPM.cmake/blob/master/README.md).

Before you ask a question, it is best to search for existing [Issues](https://github.com/cpm-cmake/CPM.cmake/issues) that might help you. In case you have found a suitable issue and still need clarification, you can write your question in this issue. It is also advisable to search the internet for answers first.

If you then still feel the need to ask a question and need clarification, we recommend the following:

- Open an [Issue](https://github.com/cpm-cmake/CPM.cmake/issues/new).
- Provide as much context as you can about what you're running into.
- Provide project and platform versions (CMake, OS, etc), depending on what seems relevant.

We will then take care of the issue as soon as possible.

## I Want To Contribute

> ### Legal Notice <!-- omit in toc -->
> When contributing to this project, you must agree that you have authored 100% of the content, that you have the necessary rights to the content and that the content you contribute may be provided under the project license.

### Reporting Bugs

<!-- omit in toc -->
#### Before Submitting a Bug Report

A good bug report shouldn't leave others needing to chase you up for more information. Therefore, we ask you to investigate carefully, collect information and describe the issue in detail in your report. Please complete the following steps in advance to help us fix any potential bug as fast as possible.

- Make sure that you are using the latest version.
- Determine if your bug is really a bug and not an error on your side e.g. using incompatible environment components/versions (Make sure that you have read the [documentation](https://github.com/cpm-cmake/CPM.cmake/blob/master/README.md). If you are looking for support, you might want to check [this section](#i-have-a-question)).
- To see if other users have experienced (and potentially already solved) the same issue you are having, check if there is not already a bug report existing for your bug or error in the [bug tracker](https://github.com/cpm-cmake/CPM.cmake/issues?q=label%3Abug).
- Also make sure to search the internet (including Stack Overflow) to see if users outside of the GitHub community have discussed the issue.
- Collect information about the bug:
- Stack trace / Full CMake error output
- OS, Platform and Version (Windows, Linux, macOS, x86, ARM)
- Version of CMake, compiler or other tools used, depending on what seems relevant.
- Possibly any relevant environment / command line arguments used
- Can you reliably reproduce the issue? And can you also reproduce it with older versions?

<!-- omit in toc -->
#### How Do I Submit a Good Bug Report?

We use GitHub issues to track bugs and errors. If you run into an issue with the project:

- Open an [Issue](https://github.com/cpm-cmake/CPM.cmake/issues/new). (Since we can't be sure at this point whether it is a bug or not, we ask you not to talk about a bug yet and not to label the issue.)
- Explain the behavior you would expect and the actual behavior.
- Please provide as much context as possible and describe the *reproduction steps* that someone else can follow to recreate the issue on their own. This usually includes your code. For good bug reports you should isolate the problem and create a reduced test case.
- Provide the information you collected in the previous section.

Once it's filed:

- The project team will label the issue accordingly.
- A team member will try to reproduce the issue with your provided steps. If there are no reproduction steps or no obvious way to reproduce the issue, the team will ask you for those steps and mark the issue as `needs-repro`. Bugs with the `needs-repro` tag will not be addressed until they are reproduced.
- If the team is able to reproduce the issue, it will be marked `needs-fix`, as well as possibly other tags (such as `critical`), and the issue will be left to be [implemented by someone](#your-first-code-contribution).

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for CPM.cmake, **including completely new features and minor improvements to existing functionality**. Following these guidelines will help maintainers and the community to understand your suggestion and find related suggestions.

<!-- omit in toc -->
#### Before Submitting an Enhancement

- Make sure that you are using the latest version.
- Read the [documentation](https://github.com/cpm-cmake/CPM.cmake/blob/master/README.md) carefully and find out if the functionality is already covered, maybe by an individual configuration.
- Perform a [search](https://github.com/cpm-cmake/CPM.cmake/issues) to see if the enhancement has already been suggested. If it has, add a comment to the existing issue instead of opening a new one.
- Find out whether your idea fits with the scope and aims of the project. It's up to you to make a strong case to convince the project's developers of the merits of this feature. Keep in mind that we want features that will be useful to the majority of our users and not just a small subset. If you're just targeting a minority of users, consider writing an add-on/plugin library.

<!-- omit in toc -->
#### How Do I Submit a Good Enhancement Suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://github.com/cpm-cmake/CPM.cmake/issues).

- Use a **clear and descriptive title** for the issue to identify the suggestion.
- Provide a **step-by-step description of the suggested enhancement** in as many details as possible.
- **Describe the current behavior** and **explain which behavior you expected to see instead** and why. At this point you can also tell which alternatives do not work for you.
- **Explain why this enhancement would be useful** to most CPM.cmake users. You may also want to point out the other projects that solved it better and which could serve as inspiration.

### Your First Code Contribution

Please try to keep your individual changes as minimal and focussed on the issue as possible.
If you discover that the scope of your contribution is growing larger than expected you might want to split the changes into multiple separate contributions to allow a more focussed discussion and review.

It is usually a great idea and often required to add tests for your changes.
This allows us to quickly validate that the changes are working as intended and also guarantees that they won't be broken by other future updates.
For small and targeted functional changes, e.g. supporting a new URL schema, a [unit test](#unit-tests) may be enough.
For contributions that change large-scale behaviour, such as dependency caching features, an [integration test](#integration-tests) is more suited.
Depending on the changes, a combination of both test types may also be appropriate.

#### Unit tests

Unit tests are small CMake scripts that live in the [unit test directory](./test/unit/).
They usually make use of some of the helper assertions defined in the [testing.cmake](./cmake/testing.cmake) file.
An example unit test for checking the `cpm_get_version_from_git_tag` function could look like the following.

```cmake
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_get_version_from_git_tag("v1.2.3-a" VERSION)
assert_equal("1.2.3" ${VERSION})
```

This test can be run directly with CMake by providing the CPM source directory.

```bash
cmake -DCPM_PATH=$(pwd)/cmake -P <path to the test file>
```

We can also the [test directory's](./test/) CMakeLists to detect and run all unit tests using CMake's test runner.

```bash
cmake -Stest -Bbuild/test
cmake --build build/test --target test-verbose # or `test` for less noisy output 
```

#### Integration tests

The integration tests of CPM.cmake are written in Ruby. They use a custom integration test framework which extends the [Test::Unit](https://www.rubydoc.info/github/test-unit/test-unit/Test/Unit) library.

They require Ruby 2.7.0 or later.

To run all tests from the repo root execute:

```
ruby test/integration/runner.rb
```

For a detailed guide on integration tests, see the documentation in the [integration test directory](./test/integration/).

## Styleguides

This project uses automatic code styling using [clang-format](https://clang.llvm.org/docs/ClangFormat.html) and [cmake-format](https://github.com/cheshirekow/cmake_format).
The code style is enforced by the tools using the style options defined in the [.clang-format](./.clang-format) and [.cmake-format](./.cmake-format) configuration files.

To install the necessary tools for code styling we recommend using recent version of [Python/pip](https://www.python.org).

```bash
pip3 install clang-format==14.0.6 cmake_format==0.6.11 pyyaml
```

For convenience, we have a CMake project defined in the [test/style](./test/style/) directory that can be called to automatically apply the code styling to all files currently added in git.

```bash
# initialize the project
cmake -Stest/style -Bbuild/style
# apply the code styling to this repository
cmake --build build/style --target fix-format
```

<!-- omit in toc -->
## Attribution
This guide is based on the **contributing-gen**. [Make your own](https://github.com/bttger/contributing-gen)!
