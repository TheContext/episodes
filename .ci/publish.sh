#!/bin/sh

SLUG="TheContext/episodes"
JDK="oraclejdk8"
BRANCH="master"

if [ "$TRAVIS_REPO_SLUG" != "$SLUG" ]; then
  echo "Skipping deployment: wrong repository. Expected '$SLUG' but was '$TRAVIS_REPO_SLUG'."
elif [ "$TRAVIS_JDK_VERSION" != "$JDK" ]; then
  echo "Skipping deployment: wrong JDK. Expected '$JDK' but was '$TRAVIS_JDK_VERSION'."
elif [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Skipping deployment: was pull request."
elif [ "$TRAVIS_BRANCH" != "$BRANCH" ]; then
  echo "Skipping deployment: wrong branch. Expected '$BRANCH' but was '$TRAVIS_BRANCH'."
else
  
  FEED_USERNAME="artem-zinnatullin"
  FEED_REPO_NAME="TheContext-Podcast"
  FEED_BRANCH="master"

  WEBSITE_USERNAME="TheContext"
  WEBSITE_REPO_NAME="website"
  WEBSITE_BRANCH="master"

  # checkout repos where to push generated things
  git clone https://github.com/$FEED_USERNAME/$FEED_REPO_NAME.git # foldername $FEED_USERNAME
  git clone https://github.com/$WEBSITE_USERNAME/$WEBSITE_REPO_NAME.git # foldername $WEBSITE_REPO_NAME

  # Generate stuff
  java -jar podcaster.jar --input .. --output-feed $FEED_REPO_NAME/feed.rss --output-website $WEBSITE_REPO_NAME/content/episodes

  # Push generated feed.rss
  cd $FEED_REPO_NAME
  git add .
  git commit -am "Autogenerated feed"
  git push https://$ACCESS_TOKEN:x-oauth-basic@github.com/$FEED_USERNAME/$FEED_REPO_NAME.git $FEED_BRANCH

  # Push website
  cd ../$WEBSITE_REPO_NAME
  git add .
  git commit -am "Autogenerated website"
  git push https://$ACCESS_TOKEN:x-oauth-basic@github.com/$WEBSITE_USERNAME/$WEBSITE_REPO_NAME.git $WEBSITE_BRANCH

  # Clean up
  cd ..
  rm -rf $FEED_REPO_NAME
  rm -rf $WEBSITE_REPO_NAME

  echo "Deployed!"
fi