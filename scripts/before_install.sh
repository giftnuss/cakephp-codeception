#!/bin/bash

set -e

if [ -f .git/shallow ]; then rm .git/shallow; fi
if [ -z "$CAKE_VERSION" ]; then CAKE_VERSION=3.4.* ; fi
if [ -d tests/test_app ]; then rm -rf tests/test_app ; fi
if [ -z "$TRAVIS_BRANCH" ]; then TRAVIS_BRANCH=$(git rev-parse --abbrev-ref HEAD) ; fi
if [ -z "$TRAVIS_COMMIT" ]; then TRAVIS_COMMIT=$(git log --format="%H" -n 1); fi

composer install
composer create-project --prefer-source --stability dev --no-interaction cakephp/app:$CAKE_VERSION tests/test_app
cd tests/test_app

cp ../Fixture/composer.json ./
composer config repositories.local vcs ../../
composer config minimum-stability dev
composer require --prefer-source --dev cakephp/codeception:dev-$TRAVIS_BRANCH#$TRAVIS_COMMIT

rm composer.lock
composer install --prefer-source
vendor/bin/codecept bootstrap
vendor/bin/codecept generate:cest functional Foo
vendor/bin/codecept generate:cept functional Foo
cd ../sample_app
cp ../test_app/composer.json .
cp ../test_app/src/Console/Installer.php src/Console/
composer install --prefer-source
