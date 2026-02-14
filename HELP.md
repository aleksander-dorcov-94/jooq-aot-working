gradle clean bootJar
gradle processAot bootJar
java -jar build/libs/jooqshop.jar


gradle processAot bootJar jibBuildTar
docker load --input build/jib-image.tar
docker run -p 8080:8080 -p 5005:5005 jooqshop:local
