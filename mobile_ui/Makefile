fmt:
	dart format --fix -l 1000

test:
	flutter test

local:
	flutter run -d 64d62136f5ae --dart-define-from-file=dart_defines/local.env

emulator:
	flutter run -d emulator-5554

dev:
	flutter build android --dart-define-from-file=dart_defines/dev.env

prod:
	flutter build android --dart-define-from-file=dart_defines/prod.env

icons:
	flutter pub run flutter_launcher_icons:main
