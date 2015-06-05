# SwiftCov

A tool to generate test code coverage information for Swift.

[![Coverage Status](https://coveralls.io/repos/realm/SwiftCov/badge.svg)](https://coveralls.io/r/realm/SwiftCov)

## Installation

Install the `swiftcov` command line tool by running `git clone` for this repo followed by `make install` in the root directory.

## Usage

```shell
$ swiftcov help
Available commands:

   generate   Generate test code coverage files for your Swift tests
   help       Display general or command-specific help
   version    Display the current version of SwiftCov
```

### generate
Run the tests and generate code coverage files. You can write any xcodebuild command as arguments for testing your project.

```shell
$ swiftcov generate
Usage: swiftcov generate [swiftcov options] xcodebuild [xcodebuild options] (-- [swift files])
```

```shell
$ swiftcov generate \
  xcodebuild test \
  -project Example.xcodeproj -scheme 'Example' \
  -configuration Release -sdk iphonesimulator
```

Use the `--output` parameter to specify a destination directory for the coverage files.
If you think the coverage generation process is slow, you can specify the `threshold` option. It makes running faster to limit the count of the number of executions.

**Currently, the default value of threshold option is 1 for performance reasons. Since some test cases may take a very long time generating coverage data, especially if some code paths are frequently hit (as is the case with loops).**

```shell
$ swiftcov generate --output ./coverage --threshold 1 \
  xcodebuild test \
  -project Example.xcodeproj -scheme 'Example'
  -configuration Release -sdk iphonesimulator
```

#### Options

- `--output OUTPUT_DIR` specify output directory for generated coverage files.
- `--threshold LIMIT_COUNT` specify the maximum number of hits you wish to measure. Reducing this number can drastically speed up SwiftCov.
- `--debug` Output very verbose progress messages.
- `-- [swift files]` Pass a space-separated list of files for which to measure code coverage, with either relative or absolute paths, after the `--` at the end of your command.

### help

Display general or command-specific help.

### version

Display the current version.

## How to run example project

```shell
$ make install
$ cd Examples/ExampleFramework/
$ swiftcov generate --output coverage_ios \
  xcodebuild test \
  -project ExampleFramework.xcodeproj \
  -scheme ExampleFramework-iOS \
  -sdk iphonesimulator \
  -configuration Release
```

Please see [the generated coverage file](Examples/ExampleFramework/results/Calculator.swift.gcov)!

## Advanced usage

### Convert to HTML output with [Gcovr](http://gcovr.com/guide.html)

```shell
$ gcovr --root . --use-gcov-files --html --html-details --output coverage.html --keep
```

See [the generated coverage file](Examples/ExampleFramework/results/coverage.html).

### How SwiftCov works

SwiftCov traces the execution of your test code using LLDB by following these steps:

1. Set breakpoints in all lines of target's source code.
  (Those breakpoints only record when they are triggered. They do not stop the tests from running.)
2. Run the tests with LLDB attached.
3. After the tests have completed, collect the number of times each breakpoint was hit and generate `.gcov` files from those results.

## Limitations

- Running on iOS devices is not supported (Simulator or OS X only)
- Application projects are not supported (Framework projects only)
- Running on Travis CI is not supported (It works on Circle CI!)
- Debugging SwiftCov is not supported. If you launch SwiftCov from Xcode, it may fail. https://github.com/realm/SwiftCov/issues/6
- Make sure you do not debug for the same target. It may fail since multiple debuggers cannot attach same target.

## License

MIT licensed.
