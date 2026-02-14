#!/usr/bin/env bash
APP_HOME=$(dirname "$(realpath "$0")")
APP_BASE_NAME=$(basename "$0")

if [[ -n "$JAVA_HOME" ]]; then
    JAVACMD="$JAVA_HOME/bin/java"
else
    JAVACMD=$(command -v java)
fi

[[ ! -x "$JAVACMD" ]] && echo "ERROR: Java not found. Try 'sudo dnf install java-latest-openjdk'" && exit 1

DEFAULT_JVM_OPTS=("-Xmx64m" "-Xms64m")
CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

exec "$JAVACMD" \
    "${DEFAULT_JVM_OPTS[@]}" \
    "$JAVA_OPTS" \
    "-Dorg.gradle.appname=$APP_BASE_NAME" \
    -classpath "$CLASSPATH" \
    org.gradle.wrapper.GradleWrapperMain "$@"
