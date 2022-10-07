# React Micro Frontend Template

## Getting Started

1. Run the script to initialize the project and install dependencies:

```bash
./setup.sh
```

2. Add your micro frontend apps at `src/index.ejs`

```html
<script type="systemjs-importmap">
  {
    "imports": {
      "react": "https://cdn.jsdelivr.net/npm/react@16.13.0/umd/react.production.min.js",
      "react-dom": "https://cdn.jsdelivr.net/npm/react-dom@16.13.0/umd/react-dom.production.min.js",
      "single-spa": "https://cdn.jsdelivr.net/npm/single-spa@5.3.0/lib/system/single-spa.min.js",
      "@${PROJECT_NAME}/root-config": "//localhost:9000/${PROJECT_NAME}-root-config.js",
      "@${PROJECT_NAME}/{MICRO_FRONTEND_NAME}": "//localhost:${YOUR_PORT}/${PROJECT_NAME}-{MICRO_FRONTEND_NAME}.js"
    }
  }
</script>
```

3. Register your micro frontend apps at `microfrontend-layout.html`. You can read more about the layout API reference [here](https://single-spa.js.org/docs/layout-definition/)

```html
<single-spa-router>
  <main>
    <route default>
      <application name="@single-spa/welcome"></application>
    </route>
    <!-- Registering new micro frontend here (EXAMPLE) -->
    <route path="${YOUR_PATH}">
      <application name="@${PROJECT_NAME}/${MICRO_FRONTEND_NAME}"></application>
    </route>
  </main>
</single-spa-router>
```

4. Execute `yarn start` to run locally

## Important notes

- Maintain consistency for the project name (all micro service and root project should have the same project name)

- It's recommended to setup the micro frontend apps repositories from [this template](https://github.com/edwardramirez31/micro-frontend-template) to be consistent with project naming convention

- This repository uses Semantic Release. If you don't want to use it:

  - Remove the step at `.github` or the entire folder
  - Remove `.releaserc` file
  - Remove `@semantic-release/changelog`, `@semantic-release/git`, `semantic-release` from `package.json`

- Build the project with `yarn build` and deploy the files to a CDN or host to serve those static files.

- You can use the CloudFormation template at `serverless.yml` in order to deploy the whole frontend infrastructure to AWS with the command:

```
serverless deploy --stage ${ENVIRONMENT} \
  --verbose --oidc ${GITHUB_OIDC_ARN} \
  --org ${GITHUB_ORGANIZATION_OR_USERNAME} \
  --repo ${REPOSITORY_NAME} \
  \
```

> `oidc` flag is required if you already have an IAM OpenID connect provider with GitHub. Just pass the Amazon Resource Name ARN next to the option. Everything else is required.

- This will setup:

  - Bucket to store each micro frontend code
    - This will handle CORS from your localhost and the cloudfront distribution URL
  - CloudFront distribution that points to S3 bucket
    - It uses `index.html` as default object
    - Setup custom error pages to avoid error when user goes to a specific route at the app
    - Use custom cache policy that handle CORS headers for local and prod environments
  - Bucket Policy that allows CloudFront to get resources through OAC (Origin Access Control)
  - [GitHub OIDC provider](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) in case you don't want to pass the `oidc` option
  - Create an IAM role that GitHub will assume to deploy new changes to S3 Bucket
    - GitHub will use AWS STS behind scenes at `.github/workflows/main.yml` and use the tokens to authenticate and assume the role
    - The assume role policy document will also check that the token issuer comes from GitHub, the audience was STS and the source comes from the repository and organization that you specified at `org` and `repo` options
      - This way, only your repositories will assume the role. More info about [Open ID](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
  - Create IAM custom policy and attach it to the role created previously
    - It will have permissions to get objects and put new ones in the project bucket

- Don't forget to change the Bucket CORS whitelist with the CloudFront domain result or your Route 53 domain

- Also change service name at `serverless.yml according to your needs`

- It's highly recommended to use [Import Map Deployer](https://github.com/Insta-Graph/import-map-deployer) so that this root repo will get the micro frontend imports from a dynamic import map JSON file. If you don't want to use it, remove the following lines at

```yml
- name: Update import map
  run: curl -u ${USERNAME}:${PASSWORD} -d '{ "service":"@snapify/'"${MICRO_FRONTEND_NAME}"'","url":"https://'"${CLOUDFRONT_HOST}"'/'"${MICRO_FRONTEND_NAME}"'/'"${IDENTIFIER}"'/'snapify-"${MICRO_FRONTEND_NAME}"'.js" }' -X PATCH https://${IMD_HOST}/services/\?env=prod -H "Accept:application/json" -H "Content-Type:application/json"
  env:
    USERNAME: ${{ secrets.IMD_USERNAME }}
    PASSWORD: ${{ secrets.IMD_PASSWORD }}
    MICRO_FRONTEND_NAME: ${{ secrets.MICRO_FRONTEND_NAME }}
    CLOUDFRONT_HOST: ${{ secrets.CLOUDFRONT_HOST }}
    IMD_HOST: ${{ secrets.IMD_HOST }}
    IDENTIFIER: ${{ github.sha }}
```

- Create import-map.json and upload it to S3. Add you import maps source as the first script at `index.ejs`

```html
<script type="systemjs-importmap" src="https://${CLOUDFRONT_HOST}/import-map.json"></script>
```

- `import-map.json` should be similar to:

```json
{
  "imports": {
    "react": "https://cdn.jsdelivr.net/npm/react@17.0.1/umd/react.production.min.js",
    "react-dom": "https://cdn.jsdelivr.net/npm/react-dom@17.0.1/umd/react-dom.production.min.js",
    "single-spa": "https://cdn.jsdelivr.net/npm/single-spa@5.8.2/lib/system/single-spa.min.js",
    "@${YOUR_ORG}/root-config": "https://db8kbjrv5qbv8.cloudfront.net/root-config/${IDENTIFIER}/${YOUR_ORG}-root-config.js",
    "@${YOUR_ORG}/root-config/": "https://db8kbjrv5qbv8.cloudfront.net/root-config/${IDENTIFIER}/",
    "@${YOUR_ORG}/${MICRO_FRONTEND_1}": "https://db8kbjrv5qbv8.cloudfront.net/${MICRO_FRONTEND_1}/${IDENTIFIER_2}/${YOUR_ORG}-${MICRO_FRONTEND_1}.js",
    "@${YOUR_ORG}/${MICRO_FRONTEND_1}/": "https://db8kbjrv5qbv8.cloudfront.net/${MICRO_FRONTEND_1}/${IDENTIFIER_2}/",
    "@${YOUR_ORG}/${MICRO_FRONTEND_2}": "https://db8kbjrv5qbv8.cloudfront.net/${MICRO_FRONTEND_2}/${IDENTIFIER_3}/${YOUR_ORG}-${MICRO_FRONTEND_2}.js",
    "@${YOUR_ORG}/${MICRO_FRONTEND_2}/": "https://db8kbjrv5qbv8.cloudfront.net/${MICRO_FRONTEND_2}/${IDENTIFIER_3}/"
  }
}
```

- Finally, setup secrets for S3 bucket names and roles to deploy to AWS at GitHub actions files. Secrets needed are:

  - `ACTIONS_DEPLOY_ACCESS_TOKEN`: GitHub token used by Semantic Release
  - `ROLE_TO_ASSUME_ARN`: IAM Role ARN
  - `BUCKET_NAME`: S3 Bucket name
  - `MICRO_FRONTEND_NAME`: Micro frontend name. This will be used to create a folder where you will have your micro frontend deployed JS files
  - `IMD_USERNAME`: Username to authenticate in case you are using import map deployer
  - `IMD_PASSWORD`: Password to authenticate in case you are using import map deployer
  - `IMD_HOST`: Import map deployer domain name (without https)
  - `CLOUDFRONT_HOST`: Cloud front domain name (without https). This can also be Route 53, or S3 bucket domain in case you are not using CloudFront to host your import map JSON file.

- Otherwise, you can set up each CloudFormation resource manually. This project uses AWS S3 to host the build files and the root HTML. In order to use this feature properly:

  - Create an IAM role with S3 permissions (get, put S3 object and list bucket) that will be assumed by GitHub on deployment stage. The resulting role custom attached policy

  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        "Resource": "arn:aws:s3:::${BUCKET_NAME}/*",
        "Effect": "Allow"
      }
    ]
  }
  ```

  - The policy document that AWS will use to assume the role should be like

  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${YOUR_IAM_GITHUB_OIDC_ARN}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringLike": {
            "token.actions.githubusercontent.com:sub": "repo:${ORGANIZATION_OR_GH_USERNAME}/${REPOSITORY_NAME_PREFIX}*:*"
          },
          "ForAllValues:StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            "token.actions.githubusercontent.com:iss": "https://token.actions.githubusercontent.com"
          }
        }
      }
    ]
  }
  ```

  - You can also create an IAM user with permissions, but is highly encouraged to setup the role given that is more secure that leaving full access keys. Then, setup `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` at repository secrets. Also setup AWS credentials step as

  ```yml
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v1
    with:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws-region: us-east-1
  ```

  - Type your bucket name when executing `setup.sh`
  - Create an S3 bucket at AWS and change bucket settings according to your needs

    - Enable S3 Static Website Hosting at the bottom of the Properties tab in the AWS Management Console
      - Set the index document as `index.html`
    - Uncheck all options at bucket settings or just whatever is necessary
    - Change bucket policy allowing externals to get your objects if you want to serve content directly from the bucket

    ```
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
      ]
    }
    ```

    - Otherwise, if you want to serve your content through CloudFront:

      - Create a distribution and add `index.html` as the default root object
      - Setup and origin access control like [here](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
      - Create a distribution invalidation that points to the object path `/*` so that CloudFront removes the previous file from cache before it expires. This way, users will get the latest app version when CI/CD process finishes
      - Use your CloudFront distribution to get the micro frontends JS code, favicon and other files needed, instead of using the default URL provided by S3.
      - Add new step at `.github/workflows/main.yml` in order to invalidate cache from CloudFront build files, just in case you are having problems with caching. Setup DISTRIBUTION_ID at repository secrets

      ```yml
        - name: Invalidate cache in CloudFront
        run: aws cloudfront create-invalidation --distribution-id "${DISTRIBUTION_ID}" --paths "/path1" "/example-path-2*" --no-cli-pager
        env:
          DISTRIBUTION_ID: ${{ secrets.DISTRIBUTION_ID }}
      ```

      - Change your bucket policy to make sure users can access the content in the bucket only through the specified CloudFront distribution

    ```
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowCloudFrontServicePrincipalReadOnly",
          "Effect": "Allow",
          "Principal": {
            "Service": "cloudfront.amazonaws.com"
          },
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${YOUR_BUCKET_NAME}/*",
          "Condition": {
            "StringEquals": {
              "AWS:SourceArn": "arn:aws:cloudfront::${AWS_ACCOUNT_ID}:distribution/${CLOUDFRONT_DISTRIBUTION_ID}"
            }
          }
        }
      ]
    }
    ```

    - Add CORS setting so that the root module can fetch your bucket files from local dev machine or production and dev servers

    ```
    [
      {
          "AllowedHeaders": [
              "Authorization"
          ],
          "AllowedMethods": [
              "GET",
              "HEAD"
          ],
          "AllowedOrigins": [
              "http://localhost:9000",
              "http://${BUCKET_NAME}.s3-website-us-east-1.amazonaws.com"",
              "https://{WEB_SERVER_DOMAIN_2}",
          ],
          "ExposeHeaders": [
              "Access-Control-Allow-Origin"
          ]
      }
    ]
    ```

    - Finally, add your compiled root code at the import maps and the micro frontends JS code, according to the environment

    ```html
    <% if (isLocal) { %>
    <script type="systemjs-importmap">
      {
        "imports": {
          "@${PROJECT_NAME}/root-config": "//localhost:9000/${PROJECT_NAME}-root-config.js",
          "@${PROJECT_NAME}/{MICRO_FRONTENDS_NAME}": "//localhost:${YOUR_PORT}/${PROJECT_NAME}-{MICRO_FRONTENDS_NAME}.js"
        }
      }
    </script>
    <% } else { %>
    <script type="systemjs-importmap">
      {
        "imports": {
          "@${PROJECT_NAME}/root-config": "https://{S3_BUCKET_NAME}.s3.amazonaws.com/${PROJECT_NAME}-root-config.js",
          "@${PROJECT_NAME}/{MICRO_FRONTENDS_NAME}": "https://{S3_BUCKET_NAME}.s3.amazonaws.com/${PROJECT_NAME}-{MICRO_FRONTENDS_NAME}.js"
        }
      }
    </script>
    <% } %>
    ```
