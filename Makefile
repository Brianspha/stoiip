# This help dialog.
help:
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
		IFS=$$'#' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf "%-30s %s\n" $$help_command $$help_info ; \
	done

# Build Commands
build_web:
	@flutter clean
	@flutter pub get
	@flutter build web --web-renderer html --csp --release

build_app:
	@make format_files
	@make fix_warnings
	@flutter clean
	@flutter pub get
	@flutter build appbundle --release
	@flutter build ipa --release
	@flutter build apk --release
	@make distribute_apk_no_build

build_ios:
	@flutter clean
	@flutter pub get
	@flutter build ipa --release

build_android:
	@flutter clean
	@flutter pub get
	@flutter build appbundle --release
	@flutter build apk --release
build_ios_no_clean:
	@flutter build ipa --release

build_android_no_clean:
	@flutter build appbundle --release
	@flutter build apk --release
# Unit Test and Lint
run_unit:
	@echo "╠ Running unit tests..."
	@flutter test || (echo "Error while running tests"; exit 1)

clean:
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@flutter clean
	@flutter pub get

fix_warnings:
	@echo "╠ Attempting to fix warnings..."
	@dart fix --dry-run
	@dart fix --apply

watch:
	@echo "╠ Watching the project..."
	@dart run build_runner watch --delete-conflicting-outputs

# Code Generation and Formatting
gen:
	@echo "╠ Generating the assets..."
	@flutter pub get
	@fluttergen
	@flutter packages pub run build_runner build --delete-conflicting-outputs

format:
	@echo "╠ Formatting the code..."
	@dart format .
	@dart run import_sorter:main
	@dart format .

lint:
	@echo "╠ Verifying code..."
	@dart analyze . || (echo "Error in project"; exit 1)

migrate:
	@flutter migrate

# Dependency Management
upgrade: clean
	@echo "╠ Upgrading dependencies..."
	@flutter pub upgrade

upgrade_major: clean
	@echo "╠ Upgrading major versions of dependencies..."
	@flutter pub upgrade --major-versions

commit: format lint run_unit
	@echo "╠ Committing..."
	git add .
	git commit

# Miscellaneous
analyze:
	@flutter run dart_code_metrics:metrics analyze lib

ditto:
	@echo "hello world"

run_web:
	@flutter run -d chrome --web-renderer html

format_files:
	@dart format .

remove_splash:
	@dart run flutter_native_splash:create --flavor production
	@dart run flutter_native_splash:create --flavor acceptance
	@dart run flutter_native_splash:create --flavor development

generate_icon_fl:
	@flutter clean
	@flutter pub get
	@dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
	@dart run flutter_launcher_icons:main

generate_icon_il:
	@flutter clean
	@flutter pub get
	@dart run icons_launcher:create

clean_pubcache:
	@flutter pub cache clean

repair_pubcache:
	@flutter pub cache repair

fix_ios_boot_issue:
	@sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
	@rm -rf ~/Library/*/CoreSimulator

fix_ios_device_not_found_issue:
	@xcrun simctl shutdown all ; @xcrun simctl erase all

pod_update:
	@cd ios
	@flutter clean
	@pod repo update
	@flutter pub get

