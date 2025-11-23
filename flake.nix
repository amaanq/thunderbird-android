{
  description = "Thunderbird for Android - Privacy-focused email client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        # Android SDK configuration
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          platformVersions = [
            "36"
            "35"
            "34"
          ];
          buildToolsVersions = [
            "36.0.0"
            "35.0.0"
            "34.0.0"
          ];
          includeNDK = true;
          ndkVersions = [ "27.0.12077973" ];
          includeSystemImages = false;
          includeEmulator = false;
          cmakeVersions = [ "3.22.1" ];
        };

        androidSdk = androidComposition.androidsdk;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # Java 21 is required (see settings.gradle.kts:269)
            pkgs.jdk21
            pkgs.gradle
            androidSdk

            # Useful development tools
            pkgs.git
            pkgs.ktlint
          ];

          shellHook = ''
            echo "Thunderbird for Android development environment"
            echo "Java version: $(java -version 2>&1 | head -n 1)"
            echo "Gradle version: $(gradle --version | grep Gradle)"
            echo ""
            echo "Available build commands:"
            echo "  ./gradlew assembleDebug          - Build debug APK"
            echo "  ./gradlew assembleRelease        - Build release APK"
            echo "  ./gradlew app-thunderbird:assembleDebug  - Build Thunderbird debug APK"
            echo "  ./gradlew app-k9mail:assembleDebug       - Build K-9 Mail debug APK"
            echo "  ./gradlew test                   - Run tests"
            echo "  ./gradlew spotlessApply          - Format code"
            echo ""
          '';

          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${androidSdk}/libexec/android-sdk/ndk-bundle";

          # Gradle configuration
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/35.0.0/aapt2";

          # Java configuration
          JAVA_HOME = "${pkgs.jdk21}";
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "thunderbird-android";
          version = "unstable";

          src = ./.;

          nativeBuildInputs = [
            pkgs.jdk21
            pkgs.gradle
            androidSdk
          ];

          buildPhase = ''
            export ANDROID_HOME=${androidSdk}/libexec/android-sdk
            export ANDROID_SDK_ROOT=${androidSdk}/libexec/android-sdk
            export ANDROID_NDK_ROOT=${androidSdk}/libexec/android-sdk/ndk-bundle
            export GRADLE_USER_HOME=$TMPDIR/gradle
            export JAVA_HOME=${pkgs.jdk21}

            # Note: Building requires network access for Gradle dependencies
            # This is a limitation of the Nix build process
            gradle app-thunderbird:assembleRelease --no-daemon
          '';

          installPhase = ''
            mkdir -p $out/share/apk
            find . -name "*.apk" -type f -exec cp {} $out/share/apk/ \;
          '';

          meta = with pkgs.lib; {
            description = "Thunderbird for Android - Privacy-focused email client";
            homepage = "https://github.com/thunderbird/thunderbird-android";
            license = licenses.asl20;
            platforms = platforms.linux;
          };
        };
      }
    );
}
