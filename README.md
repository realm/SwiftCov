# SwiftCov

A tool to generate test code coverage information for Swift.

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
Usage: swiftcov generate [swiftcov options] xcodebuild [xcodebuild options]
```

```shell
$ swiftcov generate \
  xcodebuild test \
  -project Example.xcodeproj -scheme 'Example' \
  -configuration Release -sdk iphonesimulator
```

If you change the destination directory, specify the `output` options.
If you think the coverage generation process is slow, you can specify the `threshold` option. It makes running faster to limit the count of the number of executions.

**Currently, the default value of threshold option is 1 for performance reasons. Since some test cases may take a very long time generating coverage data, especially if some code paths are frequently hit (as is the case with loops).**

```shell
$ swiftcov generate --output ./coverage --threshold 1 \
  xcodebuild test \
  -project Example.xcodeproj -scheme 'Example'
  -configuration Release -sdk iphonesimulator
```

#### Options

- `--output OUTPUT_DIR` specify output directory for generated coverage files
- `--threshold LIMIT_COUNT` specify limitation for counting hit count (for performance)
- `--debug` Output very verbose progress messages

### help

Display general or command-specific help

### version

Display the current version

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

Please see [the generated coverage file](https://github.com/realm/SwiftCov/blob/master/Examples/ExampleFramework/results/Calculator.swift.gcov)!

## Advanced use cases

### Convert to HTML output with [Gcovr](http://gcovr.com/guide.html)

```shell
$ gcovr --root . --use-gcov-files --html --html-details --output coverage.html --keep
```

See [the generated coverage file](https://github.com/realm/SwiftCov/blob/master/Examples/ExampleFramework/results/coverage.html).

### How it works

It is that to trace the execution using LLDB.

1. Set breakpoints in all lines of target's source code.
  (Those breakpoints does not stop the tests running. It will record hitting the line instead.)
2. Run the tests attached LLDB.
3. After the tests are finished, collect the information of the breakpoints and report to coverage file format.

## Limitations

- Running on iOS devices is not supported (Simulator or OSX only)
- Application projects are not supported (Framework projects only)
- Running on Travis CI is not supported (It works on Circle CI!)
- Debugging SwiftCov is not supported. If you launch SwiftCov from Xcode, it may fail. https://github.com/realm/SwiftCov/issues/6
- Make sure you do not debug for the same target. It may fail since multiple debuggers cannot attach same target.

## License

MIT licensed.
