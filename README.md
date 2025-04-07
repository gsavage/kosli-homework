# Kosli Take-Home Test

Two different ways of serving a website are included here, using a Cloudfront distribution
in front of an S3 bucket, and an ALB in front of an ECS service.

The Cloudfront CDN option is ideal for static websites; low-latency, localised caching, and
easy to setup/administer.

The ALB-ECS option is more complex to setup, but allows the website to include dynamic
server-side logic, such as reading from a database, or presenting an API. Within this project
there is no server-side logic, it is a static website, however implemented this option to 
allow a comparision of the infrastructure required for the two approaches.

## Cloudfront

Within this solution, an S3 bucket is created per environment.  The terraform code uploads
the HTML and other files into the bucket.  A cloudfront distribution is configured with the
bucket as its one-and-only origin.

Using Terraform to upload the content is easy, but in a real-world environment I would prefer
to have the content uploaded from a CI/CD pipeline, instead.

```mermaid
graph TD;
    U[User] --> C[CloudFront];
    C --> S[S3 Bucket];
    H[Source Files] --> S;
```

| URL | Environment | Notes |
| --- | ----------- | ----- |
| http://dev-kosli-cf.grahamandsarah.com | Dev | Cloudfront distribution, plain-text |
| https://dev-kosli-cf.grahamandsarah.com | Dev | Cloudfront distribution, TLS |
| http://test-kosli-cf.grahamandsarah.com | Test | Cloudfront distribution, plain-text |
| https://test-kosli-cf.grahamandsarah.com | Test | Cloudfront distribution, TLS |

## ECS

Within the ECS solution, the source files are built into a container image that is 
uploaded to an ECR.  I have reused the same ECR for all the logical environments - I
prefer a deployment model where there is an AWS account that holds all the images and
then each environment pulls from this central location.

The ECS Cluster contains a single service, which runs a task - multiple for test and production.
The task is configured to pull the image from the ECR

```mermaid
graph TD;
    U[User] --> A[ALB];
    A --> T[ECS Task];
    S[ECS Service] --contains--> T;
    C[ECS Cluster] --contains--> S;
    F[Fargate] --run--> S;
    T --runs--> I[Container Image];
    H[Source Files] --built into --> I;
```

| URL | Environment | Notes |
| --- | ----------- | ----- |
| http://dev-kosli-app.grahamandsarah.com | Dev | ECS-deployed application, plain-text |
| https://dev-kosli-app.grahamandsarah.com | Dev | ECS-deployed application, TLS |
| http://test-kosli-app.grahamandsarah.com | Test | ECS-deployed application, plain-text |
| https://test-kosli-app.grahamandsarah.com | Test | ECS-deployed application, TLS |


## Points of interest

I'm very aware of the need to implement good security practises.  I've chosen to run the ECS
task in private subnets, I'm avoiding using the VPC Default security group.  I've used a private
S3 bucket with a restrictive policy.  All of these choices slowed down the implementation,
but this sort of thing, protecting our IP, is something that I feel very strongly about.

I haven't implemented them in Terraform here, but this account is my personal account and I do
have billing alerts setup. Please don't run siege or ab against these endpoints!  

## Further Work

There are a number of opportunities to improve these implementations.

* Remove the upload HTML step from Terraform - deploying a website, to my mind, is an 
  operation that should be performed by a CI/CD tool outside of the Terraform code.
  I could imagine wanting to compile the HTML files using a tool like Jekyll and running
  that in a pipeline doesn't smell like it belongs here

* This repo contains two different mechanisms for serving a website.  I would prefer to 
  split them out into separate repositories; perhaps one for the Cloudfront, one for the ECS,
  one for the ECS _service_, and yet another for the HTML.  For the purposes of the homework
  assignment, that felt like overkill.

* I haven't implemented any monitoring or alerting.  I'm aware this wasn't mentioned in the
  requirements, so perhaps it's not something that if of interest, but I'm calling out that
  if this proof-of-concept went any further, or was available to real users, I would most
  definitely implement monitoring and alerting within Cloudwatch.

* I do not have a WAF in front of either the ALB or Cloudfront, again, this was for
  simplicity and to not stretch the brief too far.  There's no way I would put this into
  real production without those protections.

