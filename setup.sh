#!/bin/bash

re=^[A-Za-z0-9_-]+$

project=""
while ! [[ "${project?}" =~ ${re} ]]
do
  read -p "🔷 Enter the project name (can use letters, numbers, dash or underscore): " project
done

repository=""
currentRepo="https://github.com/edwardramirez31/micro-frontend-root-layout"
read -p "🔷 Enter your GitHub repository URL name to add semantic release: " repository
sed -i "s,$currentRepo,$repository,g" .releaserc

domain=""
read -p "🔷 Enter the domain name where you have deployed the project: " domain
sed -i "s/d1ecqcwx7brud6.cloudfront.net/$domain/g" src/index.ejs


sed -i "s/my-app/$project/g" package.json
sed -i "s/my-app/$project/g" .github/workflows/main.yml
sed -i "s/my-app/$project/g" tsconfig.json
sed -i "s/'my-app'/'$project'/g" webpack.config.js
sed -i "s/my-app/$project/g" src/index.ejs
mv src/my-app-root-config.ts "src/$project-root-config.ts"


echo "🔥🔨 Installing dependencies"
# yarn install
echo "🔥⚙️ Installing Git Hooks"
# yarn husky install
echo "🚀🚀 Project setup complete!"
echo "✔️💡 Run 'yarn start' to boot up your single-spa root config"
