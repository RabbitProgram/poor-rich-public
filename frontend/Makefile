init:
	fvm install
	fvm flutter clean
	fvm flutter pub get

lint-fix:
	fvm dart fix --apply

gen:
	fvm dart run build_runner clean
	fvm dart run build_runner build --delete-conflicting-outputs

gen-icon:
	fvm dart run flutter_launcher_icons
