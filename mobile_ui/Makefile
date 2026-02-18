fmt:
	dart format --fix -l 1000

test:
	flutter test

local:
	flutter run -d emulator-5554 --dart-define-from-file=dart_defines/local.env

dev:
	flutter run -d 64d62136f5ae --dart-define-from-file=dart_defines/dev.env

prod:
	flutter build android --dart-define-from-file=dart_defines/prod.env

icons:
	flutter pub run flutter_launcher_icons:main

build:
	dart run build_runner build --delete-conflicting-outputs
