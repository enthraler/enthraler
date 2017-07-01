package enthralerdotcom;

import monsoon.Monsoon;
import monsoon.middleware.Console;
import smalluniverse.SmallUniverse;
import dodrugs.Injector;
import sys.db.*;
import ufront.db.migrations.*;
using tink.core.Outcome;

class Server {

	public static var jsLibBase = '/jslib/0.1.1';

	static function main() {

		Manager.cnx = Mysql.connect({
			host: Sys.getEnv('DB_HOST'),
			database: Sys.getEnv('DB_DATABASE'),
			user: Sys.getEnv('DB_USERNAME'),
			pass: Sys.getEnv('DB_PASSWORD'),
		});

		var injector = Injector.create('enthralerdotcom', [
			var _:Connection = Manager.cnx,
			MigrationConnection,
			MigrationManager,
			MigrationApi,
			enthralerdotcom.templates.ManageTemplatesPage,
			enthralerdotcom.templates.ManageTemplatesBackendApi,
			enthralerdotcom.templates.ViewTemplatePage,
			enthralerdotcom.templates.ViewTemplateBackendApi,
			enthralerdotcom.content.ContentEditorPage,
			enthralerdotcom.content.ContentEditorBackendApi,
		]);

		if (php.Web.isModNeko) {
			webMain(injector);
		} else {
			cliMain(injector);
		}
	}

	static function webMain(injector:Injector<'enthralerdotcom'>) {
		Webpack.require('./EnthralerStyles.scss');

		var app = new Monsoon();
		app.use('$jsLibBase/enthraler.js',  function (req,res) res.send(CompileTime.readFile('bin/enthraler.js')));
		app.use('$jsLibBase/enthralerHost.js', function (req,res) res.send(CompileTime.readFile('bin/enthralerHost.js')));
		app.use('$jsLibBase/frame.html', function (req,res) res.send(CompileTime.readFile('bin/frame.html')));
		app.use('/i/:guid/data/:id?', enthralerdotcom.content.ContentJsonApi.getDataJson);

		var smallUniverse = new SmallUniverse(app);
		smallUniverse.addPage('/templates/:user/:repo', function () return injector.get(enthralerdotcom.templates.ViewTemplatePage));
		smallUniverse.addPage('/templates', function () return injector.get(enthralerdotcom.templates.ManageTemplatesPage));
		smallUniverse.addPage('/i/:guid/edit', function () return injector.get(enthralerdotcom.content.ContentEditorPage));
		app.listen(3000);
	}

	static function cliMain(injector:Injector<'enthralerdotcom'>) {
		var migrationApi = injector.get(MigrationApi);
		migrationApi.ensureMigrationsTableExists();
		migrationApi.syncMigrationsUp().sure();
		trace('done');
	}
}
