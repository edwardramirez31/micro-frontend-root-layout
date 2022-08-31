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
