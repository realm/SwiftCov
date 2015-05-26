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

## License

MIT licensed.
