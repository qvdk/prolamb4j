# Prolamb4J

Java bootstrap for the AWS Lambda provided runtime with the integration of the SWI-Prolog library.

This allows to handle easily a Java-based lambda that query a prolog engine.

## How to use?

Since Prolamb4J extends AWS lambda base image for Java, you can follow the official documentation on how to [Deploy Java Lambda functions with container images - Using an AWS base image for Java](https://docs.aws.amazon.com/lambda/latest/dg/java-image.html#java-image-instructions)

Then, you have to base your Dockerfile from the Prolamb4J image.

Replace 

```
FROM public.ecr.aws/lambda/java:21 
```
by 
```
FROM qvdk/prolambd4j:9.3.8-java21
```

Add JLP library in your `pom.xml`.

```xml
<dependency>
   <groupId>com.github.SWI-Prolog</groupId>
   <artifactId>packages-jpl</artifactId>
   <version>V9.3.8</version>
</dependency>
```

Write your own handler.

```java
public class App implements RequestHandler<Map<String, String>, Map<String, String>> {

  @Override
  public Map<String, String> handleRequest(Map<String, String> input, Context context) {
    // Consulting the Prolog database from its text file
    Query q1 = new Query("load_files", new Term[] { new Atom("test.pl") });
    System.out.println("Loading test.pl " + (q1.hasSolution() ? "succeeded" : "failed"));

    String who = input.get("payload");

    Variable X = new Variable("X");
    Query q2 = new Query("descendent_of", new Term[] { X, new Atom(who) });

    String output = "The descendents of " + who + ":";
    java.util.Map<String, Term>[] solutions = q2.allSolutions();
    for (int i = 0; i < solutions.length; i++) {
      System.out.println("X = " + solutions[i].get("X"));
      output += " " + solutions[i].get("X");
    }

    // return what you want...
    return Map.of("payload", output);
  }
}
```
See [JLP tutorials](https://jpl7.org/TutorialJavaCallsProlog) for more samples.

Test locally.

```
~ curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"payload":"ralf"}'
{"payload":"The descendents of ralf: joe mary steve"}%
```


