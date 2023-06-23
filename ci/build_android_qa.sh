# BUILD_NUMBER=0 sh ci/build_android_qa.sh
# The $BUILD_NUMBER environment variable needs to be a unique value or
# Google Play will reject the upload.
# So the next time you run this command you’ll need to increment the build.
# Also remember, that Codemagic will set a value for this variable for each build.
# If you use a specific number locally, a build with the same number will fail on Codemagic.
# For BUILD_NUMBER (VersionCode) see
# https://docs.flutter.dev/deployment/android#updating-the-apps-version-number
build_number="$1"  # Store the value of the first command-line argument
bundle exec fastlane android deploy build_number:13 build_number:"$build_number"