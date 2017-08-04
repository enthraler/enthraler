package enthralerdotcom;

import monsoon.Monsoon;
import monsoon.middleware.Static;
import monsoon.middleware.Console;
import smalluniverse.SmallUniverse;
import dodrugs.Injector;
import sys.db.*;
import sys.FileSystem;
import sys.io.File;
import ufront.db.migrations.*;
using tink.core.Outcome;

class Server {

	public static var jsLibBase = '/jslib/0.1.1';

	static function main() {
		var cnxSettings = {
			host: Sys.getEnv('DB_HOST'),
			database: Sys.getEnv('DB_DATABASE'),
			user: Sys.getEnv('DB_USERNAME'),
			pass: Sys.getEnv('DB_PASSWORD'),
		};
		if (FileSystem.exists('conf/db.json')) {
			cnxSettings = tink.Json.parse(File.getContent('conf/db.json'));
		}
		#if nodejs
			MysqlJs.connect(cnxSettings, function (err, cnx) {
				if (err != null) {
					throw err;
				}
				if (#if hxnodejs true #else php.Web.isModNeko #end) {
					webMain(cnx);
				} else {
					cliMain(cnx);
				}
			});
		#else
			Manager.cnx = Mysql.connect(cnxSettings);
			if (php.Web.isModNeko) {
				webMain(Manager.cnx);
			} else {
				cliMain(Manager.cnx);
			}
		#end

	}

	static function getInjector(cnx) {
		return Injector.create('enthralerdotcom', [
			var _:AsyncConnection = cnx,
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
			enthralerdotcom.content.ContentViewerPage,
			enthralerdotcom.content.ContentViewerBackendApi,
			enthralerdotcom.homepage.HomePage,
			enthralerdotcom.homepage.HomeBackendApi,
		]);
	}

	static function webMain(cnx) {
		#if client
		Webpack.require('./EnthralerStyles.scss');
		#end

		var app = new Monsoon();
		app.use('/assets/', Static.serve('assets'));
		app.use('$jsLibBase/enthraler.js',  function (req,res) res.send(CompileTime.readFile('bin/enthraler.js')));
		app.use('$jsLibBase/enthralerHost.js', function (req,res) res.send(CompileTime.readFile('bin/enthralerHost.js')));
		app.use('$jsLibBase/frame.html', function (req,res) res.send(CompileTime.readFile('bin/frame.html')));
		app.use('/i/:guid/data/:id?', enthralerdotcom.content.ContentServerRoutes.getDataJson);
		app.use('/i/:guid/embed/:id?', enthralerdotcom.content.ContentServerRoutes.redirectToEmbedFrame);

		var smallUniverse = new SmallUniverse(app);
		smallUniverse.addPage('/templates/:user/:repo', function () return getInjector(cnx).get(enthralerdotcom.templates.ViewTemplatePage));
		smallUniverse.addPage('/templates', function () return getInjector(cnx).get(enthralerdotcom.templates.ManageTemplatesPage));
		smallUniverse.addPage('/i/:guid/edit', function () return getInjector(cnx).get(enthralerdotcom.content.ContentEditorPage));
		smallUniverse.addPage('/i/:guid', function () return getInjector(cnx).get(enthralerdotcom.content.ContentViewerPage));
		smallUniverse.addPage('/', function () return getInjector(cnx).get(enthralerdotcom.homepage.HomePage));
		app.listen(3000);
	}

	static function cliMain(cnx) {
		var injector = getInjector(cnx);
		var migrationApi = injector.get(MigrationApi);
		migrationApi.ensureMigrationsTableExists();
		migrationApi.syncMigrationsUp().sure();
		trace('done');
	}
}
