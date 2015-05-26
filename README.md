# SwiftCov

Super early tool (read: not working) to generate test code coverage information
for Swift.

## Usage

```shell
$ swiftcov generate xcodebuild -project RealmSwift.xcodeproj -scheme 'Example' -configuration Release -sdk iphonesimulator test
```

```shell
$ swiftcov generate --output ./coverage --threshold 1 xcodebuild -project RealmSwift.xcodeproj -scheme 'Example' -configuration Release -sdk iphonesimulator test
```

### Options

- `--output` specify output directory for generated coverage files
- `--threshold` specify limitation for counting hit count (for performance)

## How to run example project

```shell
$ make install
```

```shell
$ cd Examples/ExampleFramework/
```

```shell
$ swiftcov generate --output coverage \
  xcodebuild -project ExampleFramework.xcodeproj \
  -scheme ExampleFramework \
  -sdk iphonesimulator \
  -configuration Release \
  test
```

Please see [the generated coverage file](https://github.com/realm/SwiftCov/blob/master/Examples/ExampleFramework/coverage/Calculator.swift.gcov)!

## License

MIT licensed.
