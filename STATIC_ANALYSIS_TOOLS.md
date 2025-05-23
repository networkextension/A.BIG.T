# Static Analysis Tools for Swift and Objective-C

This document outlines the installation and usage of SwiftLint for Swift code and Clang Static Analyzer for Objective-C code.

## SwiftLint (for Swift)

SwiftLint is a tool to enforce Swift style and conventions.

### Installation

There are several ways to install SwiftLint. Choose the one that best fits your project setup:

1.  **Homebrew (Recommended for macOS):**
    ```bash
    brew install swiftlint
    ```

2.  **CocoaPods:**
    Add the following to your `Podfile`:
    ```ruby
    pod 'SwiftLint'
    ```
    Then run:
    ```bash
    pod install
    ```
    This will allow you to invoke SwiftLint via `${PODS_ROOT}/SwiftLint/swiftlint`.

3.  **Mint:**
    ```bash
    mint install realm/SwiftLint
    ```

4.  **Swift Package Manager (as a command plugin or build tool plugin):**
    Add the following to your `Package.swift` file's dependencies:
    ```swift
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "<version>") // Replace <version> with desired version e.g., "0.54.0"
    ```
    It's highly recommended to use the `SwiftLintPlugins` repository for easier adoption.
    Then, add the plugin to your target(s):
    ```swift
    .target(
        name: "YourTarget",
        // ...
        plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
    ),
    ```

5.  **Pre-built Package:**
    Download the `SwiftLint.pkg` installer from the [latest GitHub release](https://github.com/realm/SwiftLint/releases/latest) and run it.

6.  **From Source (requires Bazel):**
    Clone the SwiftLint repository and run:
    ```bash
    make install
    ```

### Running SwiftLint

1.  **Command Line:**
    Navigate to your project's root directory and run:
    ```bash
    swiftlint
    ```
    This will print lint warnings and errors based on the rules defined in a `.swiftlint.yml` configuration file (if present in the current directory or parent directories) or default rules.

    Common commands:
    *   `swiftlint lint` or `swiftlint`: Lint files and show violations.
    *   `swiftlint autocorrect` or `swiftlint --fix`: Automatically correct certain violations.
    *   `swiftlint rules`: Display the list of rules and their identifiers.
    *   `swiftlint generate-docs`: Generates markdown documentation for rules.

2.  **Xcode Integration:**

    *   **Build Tool Plugin (with SPM):** If you installed SwiftLint via SPM and configured it as a build tool plugin, it will run automatically when you build your target in Xcode. Make sure to trust and enable the plugin when prompted by Xcode.

    *   **Run Script Build Phase (Manual Setup):**
        In your Xcode target's "Build Phases":
        1.  Add a "New Run Script Phase".
        2.  Paste the following script:
            ```bash
            if command -v swiftlint >/dev/null 2>&1; then
              swiftlint
            elif command -v "${PODS_ROOT}/SwiftLint/swiftlint" >/dev/null 2>&1; then
              "${PODS_ROOT}/SwiftLint/swiftlint"
            else
              echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
            fi
            ```
        3.  (Optional) For Apple Silicon Macs using Homebrew, if SwiftLint is installed in `/opt/homebrew/bin`, you might need to adjust the PATH in the script or create a symlink:
            ```bash
            if [[ "$(uname -m)" == arm64 ]] && [ -x "/opt/homebrew/bin/swiftlint" ]; then
                export PATH="/opt/homebrew/bin:$PATH"
            fi

            if command -v swiftlint >/dev/null 2>&1; then
              swiftlint
            # ... (rest of the script)
            ```

3.  **Configuration:**
    Create a `.swiftlint.yml` file in your project's root directory to customize rules, included/excluded paths, and other options. Refer to the [SwiftLint documentation](https://realm.github.io/SwiftLint/rule-directory.html) for configuration options.

## Clang Static Analyzer (for Objective-C)

The Clang Static Analyzer is a source code analysis tool that finds bugs in C, C++, and Objective-C programs.

### Installation

The primary recommended way to get the Clang Static Analyzer is to build it from source as part of LLVM/Clang.

1.  **Build from Source:**
    *   Follow the official instructions for [building Clang from source code](https://clang.llvm.org/get_started.html#build). This typically involves cloning the LLVM project repository, then building Clang.
    *   Once built, the analyzer tools (like `scan-build` or `clang --analyze`) will be available in your build directory. You'll need to add the directory containing `clang` and related tools (like `scan-build`) to your system's `PATH` environment variable.
    *   Example (conceptual, actual paths will vary based on your build setup):
        ```bash
        # After building LLVM/Clang
        export PATH="/path/to/your/llvm-project/build/bin:$PATH"
        ```

    *Note: Pre-built binaries used to be more common but building from source is the current guidance for up-to-date versions.*

### Running Clang Static Analyzer

There are a few ways to run the analyzer:

1.  **Directly with `clang`:**
    You can invoke the static analyzer directly using the `clang` command with the `--analyze` option.
    ```bash
    clang --analyze -Xanalyzer -analyzer-output=html -o ./analysis_reports file.m
    ```
    This is suitable for analyzing individual files or for integration into custom build scripts.

2.  **Using `scan-build`:**
    `scan-build` is a command-line utility that wraps your build process to run the static analyzer. It's generally easier for whole-project analysis.

    *   **Basic Usage:**
        Prefix your normal build command with `scan-build`:
        ```bash
        scan-build make
        scan-build xcodebuild -target YourObjCTarget -configuration Debug -sdk iphonesimulator
        ```

    *   **Output:**
        `scan-build` generates HTML reports. Use the `-o <directory>` option to specify the output location.
        ```bash
        scan-build -o ./clang_analysis_reports xcodebuild [your_build_options]
        ```
        If `-o` is not specified, reports are usually stored in a temporary directory. Use `-V` to automatically open the reports in a web browser after the build.

    *   **Important `scan-build` options:**
        *   `-o <directory>`: Output directory for HTML reports.
        *   `-V`: View analysis results in a web browser when the build completes.
        *   `-v` (or `-vv`, `-vvv`): Increase verbosity for debugging.
        *   `--use-analyzer [path to clang]`: Specify the `clang` executable to use for analysis if it's not in your default PATH or `scan-build` doesn't find the correct one.
        *   `--status-bugs`: The exit status of `scan-build` will be non-zero if it found potential bugs. Useful for CI.
        *   Always analyze a debug configuration of your project, as assertions can help the analyzer.

    *   **For projects using `configure` scripts:**
        You might need to run `configure` through `scan-build` as well:
        ```bash
        scan-build ./configure
        scan-build --keep-cc make
        ```

3.  **Using `CodeChecker` (Recommended for advanced use and CI):**
    `CodeChecker` is a more advanced tool that uses Clang Static Analyzer (and Clang-Tidy) and provides features like storing results in a database, diffing reports, and a web GUI.

    *   **Installation:** Follow the [CodeChecker Install Guide](https://github.com/Ericsson/codechecker/#Install-guide).
    *   **Workflow:**
        1.  **Log the build** (to create a `compile_commands.json` file):
            ```bash
            # For Makefile-based projects (run after 'make clean'):
            CodeChecker log -b "make YourObjCTarget" -o compile_commands.json

            # For Xcode projects, you can use tools like 'xcpretty' or 'xcodebuild-to-json'
            # to generate compile_commands.json, or use CodeChecker's logging with xcodebuild:
            # xcodebuild clean -target YourObjCTarget
            # CodeChecker log -b "xcodebuild -target YourObjCTarget -configuration Debug -sdk iphonesimulator" -o compile_commands.json
            ```
            (Ensure you are building the Objective-C targets specifically.)
        2.  **Analyze:**
            ```bash
            CodeChecker analyze compile_commands.json -o ./codechecker_reports --analyzers clangsa
            ```
            (The `--analyzers clangsa` flag ensures only Clang Static Analyzer is run, if you also have clang-tidy installed/configured with CodeChecker).
        3.  **View Results:**
            *   Command line:
                ```bash
                CodeChecker parse ./codechecker_reports
                ```
            *   HTML reports:
                ```bash
                CodeChecker parse ./codechecker_reports -e html -o ./codechecker_html_reports
                # Then open ./codechecker_html_reports/index.html in a browser.
                ```
            *   Store and view in CodeChecker Web GUI (for persistent results and team collaboration):
                ```bash
                # Start a CodeChecker server (if not already running)
                # CodeChecker server ...
                CodeChecker store ./codechecker_reports --name YourProject_ObjC --url http://your_codechecker_server/Default
                ```

4.  **Xcode Integration ("Build and Analyze"):**
    Xcode has a built-in "Analyze" feature (Product > Analyze or Shift+Cmd+B) that uses the Clang Static Analyzer. This is often the easiest way to get started for individual developers working within Xcode.
    *   You can configure Xcode to use a specific Clang build (e.g., the one you built from source) by setting the `CC` build setting or by ensuring your custom `clang` is found first in the `PATH` when Xcode launches.

### General Recommendations for Clang Static Analyzer

*   **Analyze Debug Builds:** Build your project in a "Debug" configuration. Assertions (`assert()`, `NSAssert()`) provide valuable information to the analyzer, helping it prune infeasible paths and reduce false positives. `scan-build` has a `--force-analyze-debug-code` flag.
*   **Compilation Database:** For tools like `CodeChecker` or direct `clang --analyze` on multiple files, a [Compilation Database (`compile_commands.json`)](https://clang.llvm.org/docs/JSONCompilationDatabase.html) is highly recommended. Most modern build systems (CMake, newer Xcode versions with certain flags/tools) can generate this.
*   **Checkers:** The analyzer has many checkers, some on by default, some experimental. You can enable specific checkers using `-Xanalyzer -analyzer-checker=checker.name,checker.group` options with `clang --analyze` or via `scan-build` options (`-enable-checker`, `-disable-checker`). `CodeChecker` also allows configuration of checkers.
