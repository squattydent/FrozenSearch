# convenience makefile to boostrap & run buildout
# use `make options=-v` to run buildout with extra options

version = 2.7
python = bin/python
options =

all: .installed.cfg

.installed.cfg: bin/buildout buildout.cfg setup.py
	bin/buildout $(options)

bin/buildout: $(python) buildout.cfg bootstrap.py
	$(python) bootstrap.py
	@touch $@

$(python):
	virtualenv -p python$(version) --no-site-packages .
	@touch $@

tests: .installed.cfg
	@bin/test
	@grunt test --gruntfile frozensearch/static/oscar/gruntfile.js

robot: .installed.cfg
	@bin/robot

flake8: .installed.cfg
	@bin/flake8 setup.py
	@bin/flake8 ./frozensearch/

coverage: .installed.cfg
	@bin/coverage run bin/test
	@bin/coverage report
	@bin/coverage html

production: bin/buildout production.cfg setup.py
	bin/buildout -c production.cfg $(options)
	@echo "* Please modify `readlink --canonicalize-missing ./frozensearch/settings.py`"
	@echo "* Hint 1: on production, disable debug mode and change secret_key"
	@echo "* Hint 2: frozensearch will be executed at server startup by crontab"
	@echo "* Hint 3: to run immediatley, execute 'bin/supervisord'"

minimal: bin/buildout minimal.cfg setup.py
	bin/buildout -c minimal.cfg $(options)

styles:
	@lessc -x frozensearch/static/default/less/style.less > frozensearch/static/default/css/style.css
	@lessc -x frozensearch/static/oscar/less/bootstrap/bootstrap.less > frozensearch/static/oscar/css/bootstrap.min.css
	@lessc -x frozensearch/static/oscar/less/oscar/oscar.less > frozensearch/static/oscar/css/oscar.min.css

grunt:
	@grunt --gruntfile frozensearch/static/oscar/gruntfile.js

locales:
	@pybabel compile -d frozensearch/translations

clean:
	@rm -rf .installed.cfg .mr.developer.cfg bin parts develop-eggs \
		frozensearch.egg-info lib include .coverage coverage frozensearch/static/default/css/*.css

.PHONY: all tests robot flake8 coverage production minimal styles locales clean
