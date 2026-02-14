import com.google.cloud.tools.jib.gradle.JibTask
import org.springframework.boot.gradle.tasks.bundling.BootJar

plugins {
    java
    id("nu.studer.jooq") version "10.2"
    id("io.freefair.lombok") version "9.1.0"
    id("org.springframework.boot") version "4.0.1"
    id("com.google.cloud.tools.jib") version "3.4.4"
    id("org.graalvm.buildtools.native") version "0.11.4"
    id("io.spring.dependency-management") version "1.1.7"
}

group = "com.alex"
version = "0.0.1-SNAPSHOT"
description = "Demo project for Spring Boot"

java {
    sourceCompatibility = JavaVersion.VERSION_25
    targetCompatibility = JavaVersion.VERSION_25
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}

repositories {
    mavenCentral()
}

val postgresDriverVersion = "42.7.9"

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-restclient")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-jooq")
    implementation("org.springframework.boot:spring-boot-starter-flyway")
    implementation("org.flywaydb:flyway-database-postgresql")
    runtimeOnly("org.postgresql:postgresql:$postgresDriverVersion")
    // test
    testImplementation("org.springframework.boot:spring-boot-starter-flyway-test")
    testImplementation("org.springframework.boot:spring-boot-starter-restclient-test")
    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    // other
    developmentOnly("org.springframework.boot:spring-boot-docker-compose")
    jooqGenerator("org.postgresql:postgresql:$postgresDriverVersion")
    jooqGenerator("jakarta.xml.bind:jakarta.xml.bind-api:4.0.4")
}

springBoot {
    mainClass = "com.alex.jooqshop.JooqshopApplication"
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.named<BootJar>("bootJar") {
    archiveFileName.set("jooqshop.jar")

    dependsOn("processAot")
    dependsOn("compileAotJava")

    into("BOOT-INF/classes") {
        from(sourceSets.named("aot").map { it.output })
    }
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
}

jooq {
    version.set("3.19.29")

    configurations {
        create("main") {
            jooqConfiguration.apply {
                jdbc.apply {
                    driver = "org.postgresql.Driver"
                    url = "jdbc:postgresql://localhost:5432/jooqshop"
                    user = "user"
                    password = "password"
                }
                generator.apply {
                    name = "org.jooq.codegen.DefaultGenerator"
                    database.apply {
                        name = "org.jooq.meta.postgres.PostgresDatabase"
                        inputSchema = "public"
                        excludes = "flyway_schema_history"
                    }
                    target.apply {
                        packageName = "com.alex.jooqshop.db"
                        directory = "build/generated/jooq"
                    }
                    generate.apply {
                        isPojos = true
                        isFluentSetters = true
                    }
                }
            }
        }
    }
}


tasks.withType<JibTask> {
    dependsOn("bootJar")
}

jib {
    from {
        image = "amazoncorretto:25.0.2-alpine"
    }
    to {
        image = "jooqshop:local"
    }
    container {
        mainClass = "com.alex.jooqshop.JooqshopApplication"
        environment = mapOf(
            "SPRING_DATASOURCE_URL" to "jdbc:postgresql://host.docker.internal:5432/jooqshop"
        )
        jvmFlags = listOf(
            "-Dspring.aot.enabled=true",
            "--enable-preview",
            "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
        )
    }
    containerizingMode = "packaged"
}
